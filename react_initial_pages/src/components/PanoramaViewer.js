import React, { useEffect, useRef, useState } from 'react';
import '../styles/PanoramaViewer.css';

export const PANORAMAS = [
  {
    id: 'living-room',
    name: 'Living Room',
    imageUrl: `${process.env.PUBLIC_URL}/test_360_images/living-room.jpg`,
  },
  {
    id: 'kitchen',
    name: 'Kitchen',
    imageUrl: `${process.env.PUBLIC_URL}/test_360_images/kitchen.jpg`,
  },
  {
    id: 'bedroom',
    name: 'Bedroom',
    imageUrl: `${process.env.PUBLIC_URL}/test_360_images/bedroom.jpg`,
  },
];

const RADIAN = Math.PI / 180;
const clamp = (value, min, max) => Math.max(min, Math.min(max, value));

const createSphereGeometry = (latBands = 32, lonBands = 64, radius = 1) => {
  const positions = [];
  const uvs = [];
  const indices = [];

  for (let lat = 0; lat <= latBands; lat += 1) {
    const theta = (lat * Math.PI) / latBands;
    const sinTheta = Math.sin(theta);
    const cosTheta = Math.cos(theta);

    for (let lon = 0; lon <= lonBands; lon += 1) {
      const phi = (lon * 2 * Math.PI) / lonBands;
      const sinPhi = Math.sin(phi);
      const cosPhi = Math.cos(phi);

      const x = cosPhi * sinTheta;
      const y = cosTheta;
      const z = sinPhi * sinTheta;

      positions.push(-radius * x, radius * y, radius * z); // invert X to look from inside
      uvs.push(1 - lon / lonBands, lat / latBands);
    }
  }

  for (let lat = 0; lat < latBands; lat += 1) {
    for (let lon = 0; lon < lonBands; lon += 1) {
      const first = lat * (lonBands + 1) + lon;
      const second = first + lonBands + 1;

      indices.push(first, second, first + 1);
      indices.push(second, second + 1, first + 1);
    }
  }

  return {
    positions: new Float32Array(positions),
    uvs: new Float32Array(uvs),
    indices: new Uint16Array(indices),
  };
};

const vertexShaderSource = `
  attribute vec3 aPosition;
  attribute vec2 aUV;
  uniform mat4 uMatrix;
  varying vec2 vUV;
  void main() {
    vUV = aUV;
    gl_Position = uMatrix * vec4(aPosition, 1.0);
  }
`;

const fragmentShaderSource = `
  precision mediump float;
  varying vec2 vUV;
  uniform sampler2D uTexture;
  void main() {
    gl_FragColor = texture2D(uTexture, vec2(vUV.s, vUV.t));
  }
`;

const createShader = (gl, type, source) => {
  const shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    const info = gl.getShaderInfoLog(shader);
    gl.deleteShader(shader);
    throw new Error(`Shader compile failed: ${info}`);
  }
  return shader;
};

const createProgram = (gl, vertexSource, fragmentSource) => {
  const program = gl.createProgram();
  const vert = createShader(gl, gl.VERTEX_SHADER, vertexSource);
  const frag = createShader(gl, gl.FRAGMENT_SHADER, fragmentSource);
  gl.attachShader(program, vert);
  gl.attachShader(program, frag);
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    const info = gl.getProgramInfoLog(program);
    gl.deleteProgram(program);
    throw new Error(`Program link failed: ${info}`);
  }
  return program;
};

const createPerspectiveMatrix = (fov, aspect, near, far) => {
  const f = 1.0 / Math.tan(fov / 2);
  const nf = 1 / (near - far);

  return new Float32Array([
    f / aspect,
    0,
    0,
    0,
    0,
    f,
    0,
    0,
    0,
    0,
    (far + near) * nf,
    -1,
    0,
    0,
    (2 * far * near) * nf,
    0,
  ]);
};

const multiplyMatrices = (a, b) => {
  const out = new Float32Array(16);
  for (let i = 0; i < 4; i += 1) {
    const ai0 = a[i];
    const ai1 = a[i + 4];
    const ai2 = a[i + 8];
    const ai3 = a[i + 12];
    out[i] = ai0 * b[0] + ai1 * b[1] + ai2 * b[2] + ai3 * b[3];
    out[i + 4] = ai0 * b[4] + ai1 * b[5] + ai2 * b[6] + ai3 * b[7];
    out[i + 8] = ai0 * b[8] + ai1 * b[9] + ai2 * b[10] + ai3 * b[11];
    out[i + 12] = ai0 * b[12] + ai1 * b[13] + ai2 * b[14] + ai3 * b[15];
  }
  return out;
};

const createViewMatrix = (yaw, pitch) => {
  const cosPitch = Math.cos(pitch);
  const sinPitch = Math.sin(pitch);
  const cosYaw = Math.cos(yaw);
  const sinYaw = Math.sin(yaw);

  const xAxis = [cosYaw, 0, -sinYaw];
  const yAxis = [sinYaw * sinPitch, cosPitch, cosYaw * sinPitch];
  const zAxis = [sinYaw * cosPitch, -sinPitch, cosPitch * cosYaw];

  return new Float32Array([
    xAxis[0],
    yAxis[0],
    zAxis[0],
    0,
    xAxis[1],
    yAxis[1],
    zAxis[1],
    0,
    xAxis[2],
    yAxis[2],
    zAxis[2],
    0,
    0,
    0,
    0,
    1,
  ]);
};

const isPowerOfTwo = (value) => (value & (value - 1)) === 0;

const loadTexture = (gl, url) =>
  new Promise((resolve, reject) => {
    const texture = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texImage2D(
      gl.TEXTURE_2D,
      0,
      gl.RGBA,
      1,
      1,
      0,
      gl.RGBA,
      gl.UNSIGNED_BYTE,
      new Uint8Array([0, 0, 0, 255])
    );

    const image = new Image();
    image.crossOrigin = 'anonymous';
    image.onload = () => {
      gl.bindTexture(gl.TEXTURE_2D, texture);
      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, false);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);

      if (isPowerOfTwo(image.width) && isPowerOfTwo(image.height)) {
        gl.generateMipmap(gl.TEXTURE_2D);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
      } else {
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      }

      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
      resolve(texture);
    };
    image.onerror = () => reject(new Error(`Failed to load image: ${url}`));
    image.src = url;
  });

/**
 * Custom WebGL panorama viewer.
 */
const PanoramaViewer = () => {
  const containerRef = useRef(null);
  const canvasRef = useRef(null);
  const glRef = useRef(null);
  const programRef = useRef(null);
  const buffersRef = useRef(null);
  const animationRef = useRef(null);
  const texturesRef = useRef({});

  const [currentSceneId, setCurrentSceneId] = useState(PANORAMAS[0].id);
  const [yaw, setYaw] = useState(0);
  const [pitch, setPitch] = useState(0);
  const [fov, setFov] = useState(75 * RADIAN);
  const [loadingScene, setLoadingScene] = useState(PANORAMAS[0].id);
  const [error, setError] = useState(null);

  const yawRef = useRef(0);
  const pitchRef = useRef(0);
  const fovRef = useRef(75 * RADIAN);

  const initialiseGL = () => {
    const canvas = canvasRef.current;
    if (!canvas) {
      return;
    }
    const gl = canvas.getContext('webgl', { antialias: true });
    if (!gl) {
      throw new Error('WebGL is not supported in this browser.');
    }
    glRef.current = gl;

    const program = createProgram(gl, vertexShaderSource, fragmentShaderSource);
    gl.useProgram(program);
    programRef.current = program;

    const geometry = createSphereGeometry();

    const positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, geometry.positions, gl.STATIC_DRAW);

    const uvBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, uvBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, geometry.uvs, gl.STATIC_DRAW);

    const indexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, geometry.indices, gl.STATIC_DRAW);

    const aPosition = gl.getAttribLocation(program, 'aPosition');
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    gl.enableVertexAttribArray(aPosition);
    gl.vertexAttribPointer(aPosition, 3, gl.FLOAT, false, 0, 0);

    const aUV = gl.getAttribLocation(program, 'aUV');
    gl.bindBuffer(gl.ARRAY_BUFFER, uvBuffer);
    gl.enableVertexAttribArray(aUV);
    gl.vertexAttribPointer(aUV, 2, gl.FLOAT, false, 0, 0);

    buffersRef.current = {
      indexCount: geometry.indices.length,
    };

    gl.clearColor(0, 0, 0, 1);
  };

  const resizeCanvas = () => {
    const canvas = canvasRef.current;
    const gl = glRef.current;
    const container = containerRef.current;
    if (!canvas || !gl || !container) return;

    const pixelRatio = window.devicePixelRatio || 1;
    const width = container.clientWidth * pixelRatio;
    const height = container.clientHeight * pixelRatio;

    if (canvas.width !== width || canvas.height !== height) {
      canvas.width = width;
      canvas.height = height;
    }
    gl.viewport(0, 0, canvas.width, canvas.height);
  };

  const renderScene = () => {
    const gl = glRef.current;
    const program = programRef.current;
    const canvas = canvasRef.current;
    const buffers = buffersRef.current;
    if (!gl || !program || !canvas || !buffers) return;

    resizeCanvas();

    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.disable(gl.CULL_FACE);

    const aspect = canvas.width / canvas.height;
    const projection = createPerspectiveMatrix(fovRef.current, aspect, 0.1, 100.0);
    const view = createViewMatrix(yawRef.current, pitchRef.current);
    const matrix = multiplyMatrices(projection, view);

    const uMatrix = gl.getUniformLocation(program, 'uMatrix');
    gl.uniformMatrix4fv(uMatrix, false, matrix);

    const texture = texturesRef.current[currentSceneId];
    if (texture) {
      const uTexture = gl.getUniformLocation(program, 'uTexture');
      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, texture);
      gl.uniform1i(uTexture, 0);
      gl.drawElements(gl.TRIANGLES, buffers.indexCount, gl.UNSIGNED_SHORT, 0);
    }

    animationRef.current = requestAnimationFrame(renderScene);
  };

  const loadSceneTexture = async (scene) => {
    const gl = glRef.current;
    if (!gl) return;

    if (texturesRef.current[scene.id]) {
      texturesRef.current = { ...texturesRef.current };
      return;
    }

    setLoadingScene(scene.id);
    setError(null);
    try {
      const texture = await loadTexture(gl, scene.imageUrl);
      texturesRef.current = {
        ...texturesRef.current,
        [scene.id]: texture,
      };
      setLoadingScene((current) => (current === scene.id ? null : current));
      return texture;
    } catch (err) {
      setError(err.message || 'Failed to load panorama image.');
      setLoadingScene((current) => (current === scene.id ? null : current));
      throw err;
    }
  };

  useEffect(() => {
    if (typeof window === 'undefined') {
      return () => {};
    }

    try {
      initialiseGL();
    } catch (err) {
      setError(err.message);
      return () => {};
    }

    const handleResize = () => resizeCanvas();
    window.addEventListener('resize', handleResize);
    resizeCanvas();

    loadSceneTexture(PANORAMAS[0])
      .catch(() => {
        // leave error message visible; render loop still runs for future retries
      })
      .finally(() => {
        renderScene();
      });

    return () => {
      window.removeEventListener('resize', handleResize);
      if (animationRef.current) cancelAnimationFrame(animationRef.current);
      const gl = glRef.current;
      if (gl) {
        Object.values(texturesRef.current).forEach((texture) => gl.deleteTexture(texture));
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (!glRef.current) {
      return;
    }
    const scene = PANORAMAS.find((item) => item.id === currentSceneId);
    if (!scene) return;
    if (!texturesRef.current[currentSceneId]) {
      loadSceneTexture(scene);
    }
  }, [currentSceneId]);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    let isDragging = false;
    let lastX = 0;
    let lastY = 0;

    const handlePointerDown = (event) => {
      isDragging = true;
      lastX = event.clientX;
      lastY = event.clientY;
      container.setPointerCapture(event.pointerId);
    };

    const handlePointerMove = (event) => {
      if (!isDragging) return;

      const deltaX = event.clientX - lastX;
      const deltaY = event.clientY - lastY;
      lastX = event.clientX;
      lastY = event.clientY;

      setYaw((prev) => {
        const next = prev - deltaX * 0.0025;
        yawRef.current = next;
        return next;
      });
      setPitch((prev) => {
        const next = clamp(prev - deltaY * 0.0025, -Math.PI / 2 + 0.05, Math.PI / 2 - 0.05);
        pitchRef.current = next;
        return next;
      });
    };

    const handlePointerUp = (event) => {
      isDragging = false;
      container.releasePointerCapture(event.pointerId);
    };

    const handleWheel = (event) => {
      event.preventDefault();
      setFov((prev) => {
        const next = clamp(prev + event.deltaY * 0.001, 40 * RADIAN, 100 * RADIAN);
        fovRef.current = next;
        return next;
      });
    };

    container.addEventListener('pointerdown', handlePointerDown);
    container.addEventListener('pointermove', handlePointerMove);
    container.addEventListener('pointerup', handlePointerUp);
    container.addEventListener('pointerleave', handlePointerUp);
    container.addEventListener('wheel', handleWheel, { passive: false });

    return () => {
      container.removeEventListener('pointerdown', handlePointerDown);
      container.removeEventListener('pointermove', handlePointerMove);
      container.removeEventListener('pointerup', handlePointerUp);
      container.removeEventListener('pointerleave', handlePointerUp);
      container.removeEventListener('wheel', handleWheel);
    };
  }, []);

  useEffect(() => {
    yawRef.current = yaw;
  }, [yaw]);

  useEffect(() => {
    pitchRef.current = pitch;
  }, [pitch]);

  useEffect(() => {
    fovRef.current = fov;
  }, [fov]);

  useEffect(() => {
    if (!glRef.current) return;
    requestAnimationFrame(renderScene);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentSceneId]);

  return (
    <div className="panorama-viewer">
      <div ref={containerRef} className="panorama-canvas" role="presentation">
        <canvas ref={canvasRef} />
      </div>

      {(loadingScene || error) && (
        <div className={`panorama-overlay ${error ? 'error' : ''}`}>
          {error ? (
            <span>{error}</span>
          ) : (
            <>
              <div className="spinner" />
              <span>Loading panorama…</span>
            </>
          )}
        </div>
      )}

      <div className="panorama-scene-selector">
        {PANORAMAS.map((scene) => (
          <button
            key={scene.id}
            type="button"
            className={`scene-button ${scene.id === currentSceneId ? 'active' : ''}`}
            onClick={() => setCurrentSceneId(scene.id)}
          >
            {scene.name}
          </button>
        ))}
      </div>
    </div>
  );
};

export default PanoramaViewer;
