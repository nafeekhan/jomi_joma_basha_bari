import React, { useEffect, useRef, useState, useMemo, useCallback } from 'react';
import '../styles/PanoramaViewer.css';

const RADIAN = Math.PI / 180;
const DEGREE = 180 / Math.PI;

const generateId = () => `hs-${Date.now()}-${Math.random().toString(16).slice(2, 6)}`;

const clamp = (value, min, max) => Math.max(min, Math.min(max, value));
const createSphereGeometry = (latBands = 40, lonBands = 80, radius = 1) => {
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

      positions.push(-radius * x, radius * y, radius * z);
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
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (far + near) * nf, -1,
    0, 0, (2 * far * near) * nf, 0,
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
    xAxis[0], yAxis[0], zAxis[0], 0,
    xAxis[1], yAxis[1], zAxis[1], 0,
    xAxis[2], yAxis[2], zAxis[2], 0,
    0, 0, 0, 1,
  ]);
};

const transformVector = (matrix, vector) => {
  const out = new Float32Array(4);
  for (let i = 0; i < 4; i += 1) {
    out[i] =
      matrix[i] * vector[0] +
      matrix[i + 4] * vector[1] +
      matrix[i + 8] * vector[2] +
      matrix[i + 12] * vector[3];
  }
  return out;
};

const yawPitchToVector = (yaw, pitch) => {
  const cosPitch = Math.cos(pitch);
  return new Float32Array([
    Math.sin(yaw) * cosPitch,
    Math.sin(pitch),
    Math.cos(yaw) * cosPitch,
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

const PanoramaViewer = ({
  imageSrc,
  hotspots = [],
  onHotspotClick,
  onAddHotspot,
  editing = false,
  hotspotTooltipFormatter,
  pendingHotspot = null,
}) => {
  const containerRef = useRef(null);
  const canvasRef = useRef(null);
  const glRef = useRef(null);
  const programRef = useRef(null);
  const buffersRef = useRef(null);
  const animationRef = useRef(null);
  const textureRef = useRef(null);

  const yawRef = useRef(0);
  const pitchRef = useRef(0);
  const fovRef = useRef(75 * RADIAN);

  const pointerStateRef = useRef({
    dragging: false,
    lastX: 0,
    lastY: 0,
    startX: 0,
    startY: 0,
    moved: false,
  });

  const [error, setError] = useState(null);
  const [loadingTexture, setLoadingTexture] = useState(false);
  const [hotspotPositions, setHotspotPositions] = useState([]);
  const [pendingPosition, setPendingPosition] = useState(null);

  const hotspotsMemo = useMemo(() => hotspots || [], [hotspots]);

  const initialiseGL = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const gl = canvas.getContext('webgl', { antialias: true });
    if (!gl) throw new Error('WebGL is not supported in this browser.');
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

  const projectHotspot = useCallback(
    (hotspot) => {
      const canvas = canvasRef.current;
      const gl = glRef.current;
      const container = containerRef.current;
      if (!canvas || !gl || !container) return null;

      const aspect = canvas.width / canvas.height;
      const projection = createPerspectiveMatrix(fovRef.current, aspect, 0.1, 100.0);
      const view = createViewMatrix(yawRef.current, pitchRef.current);
      const matrix = multiplyMatrices(projection, view);

      const vector = yawPitchToVector(hotspot.yaw, hotspot.pitch);
      const clip = transformVector(matrix, vector);
      const w = clip[3] || 1;
      const ndcX = clip[0] / w;
      const ndcY = clip[1] / w;
      const ndcZ = clip[2] / w;

      const visible =
        w > 0 &&
        ndcZ <= 1 &&
        ndcZ >= -1 &&
        Math.abs(ndcX) <= 1 &&
        Math.abs(ndcY) <= 1;

      const screenX = ((ndcX + 1) / 2) * container.clientWidth;
      const screenY = ((-ndcY + 1) / 2) * container.clientHeight;

      return {
        id: hotspot.id || generateId(),
        x: screenX,
        y: screenY,
        visible,
        hotspot,
      };
    },
    []
  );

  const recalculateHotspotPositions = useCallback(() => {
    const canvas = canvasRef.current;
    const gl = glRef.current;
    const container = containerRef.current;
    if (!canvas || !gl || !container) return [];

    const results = hotspotsMemo
      .map((hotspot) => projectHotspot(hotspot))
      .filter(Boolean);

    setHotspotPositions(results);
    if (editing && pendingHotspot) {
      const projected = projectHotspot(pendingHotspot);
      setPendingPosition(projected);
    } else {
      setPendingPosition(null);
    }
  }, [hotspotsMemo, editing, pendingHotspot, projectHotspot]);

  const renderScene = () => {
    const gl = glRef.current;
    const program = programRef.current;
    const canvas = canvasRef.current;
    const buffers = buffersRef.current;
    const texture = textureRef.current;
    if (!gl || !program || !canvas || !buffers || !texture) {
      animationRef.current = requestAnimationFrame(renderScene);
      return;
    }

    resizeCanvas();

    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    gl.disable(gl.CULL_FACE);

    const aspect = canvas.width / canvas.height;
    const projection = createPerspectiveMatrix(fovRef.current, aspect, 0.1, 100.0);
    const view = createViewMatrix(yawRef.current, pitchRef.current);
    const matrix = multiplyMatrices(projection, view);

    const uMatrix = gl.getUniformLocation(program, 'uMatrix');
    gl.uniformMatrix4fv(uMatrix, false, matrix);

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, texture);
    const uTexture = gl.getUniformLocation(program, 'uTexture');
    gl.uniform1i(uTexture, 0);

    gl.drawElements(gl.TRIANGLES, buffers.indexCount, gl.UNSIGNED_SHORT, 0);

    animationRef.current = requestAnimationFrame(renderScene);
  };

  const handlePointerDown = (event) => {
    if (event.target && event.target.closest('.panorama-hotspot')) {
      pointerStateRef.current = {
        dragging: false,
        lastX: event.clientX,
        lastY: event.clientY,
        startX: event.clientX,
        startY: event.clientY,
        moved: false,
      };
      return;
    }

    const container = containerRef.current;
    if (!container) return;
    container.focus?.();
    pointerStateRef.current = {
      dragging: true,
      lastX: event.clientX,
      lastY: event.clientY,
      startX: event.clientX,
      startY: event.clientY,
      moved: false,
    };
    container.setPointerCapture?.(event.pointerId);
  };

  const handlePointerMove = (event) => {
    const pointerState = pointerStateRef.current;
    if (!pointerState.dragging) return;

    const deltaX = event.clientX - pointerState.lastX;
    const deltaY = event.clientY - pointerState.lastY;
    pointerState.lastX = event.clientX;
    pointerState.lastY = event.clientY;

    if (Math.abs(deltaX) > 1 || Math.abs(deltaY) > 1) {
      pointerState.moved = true;
    }

    yawRef.current -= deltaX * 0.0025;
    pitchRef.current = clamp(pitchRef.current - deltaY * 0.0025, -Math.PI / 2 + 0.05, Math.PI / 2 - 0.05);

    recalculateHotspotPositions();
  };

  const screenPointToYawPitch = (clientX, clientY) => {
    const container = containerRef.current;
    const canvas = canvasRef.current;
    if (!container || !canvas) return null;

    const rect = container.getBoundingClientRect();
    const xNdc = ((clientX - rect.left) / rect.width) * 2 - 1;
    const yNdc = 1 - ((clientY - rect.top) / rect.height) * 2;

    const aspect = canvas.width / canvas.height;
    const tanHalfFov = Math.tan(fovRef.current / 2);

    let dirCam = [
      xNdc * tanHalfFov * aspect,
      yNdc * tanHalfFov,
      1,
    ];

    const length = Math.hypot(dirCam[0], dirCam[1], dirCam[2]);
    dirCam = dirCam.map((value) => value / (length || 1));

    const cosYaw = Math.cos(yawRef.current);
    const sinYaw = Math.sin(yawRef.current);
    const cosPitch = Math.cos(pitchRef.current);
    const sinPitch = Math.sin(pitchRef.current);

    const xAxis = [cosYaw, 0, -sinYaw];
    const yAxis = [sinYaw * sinPitch, cosPitch, cosYaw * sinPitch];
    const zAxis = [sinYaw * cosPitch, -sinPitch, cosPitch * cosYaw];

    const worldX =
      dirCam[0] * xAxis[0] + dirCam[1] * yAxis[0] + dirCam[2] * zAxis[0];
    const worldY =
      dirCam[0] * xAxis[1] + dirCam[1] * yAxis[1] + dirCam[2] * zAxis[1];
    const worldZ =
      dirCam[0] * xAxis[2] + dirCam[1] * yAxis[2] + dirCam[2] * zAxis[2];

    const yaw = Math.atan2(worldX, worldZ);
    const pitch = Math.asin(clamp(worldY, -1, 1));
    return { yaw, pitch };
  };

  const handlePointerUp = (event) => {
    const pointerState = pointerStateRef.current;
    if (!pointerState.dragging) return;
    pointerState.dragging = false;
    containerRef.current?.releasePointerCapture?.(event.pointerId);

    if (!pointerState.moved && editing && typeof onAddHotspot === 'function') {
      const result = screenPointToYawPitch(event.clientX, event.clientY);
      if (result) {
        onAddHotspot(result);
      }
    }
  };

  const handleWheel = (event) => {
    event.preventDefault();
    fovRef.current = clamp(fovRef.current + event.deltaY * 0.001, 35 * RADIAN, 100 * RADIAN);
    recalculateHotspotPositions();
  };

  useEffect(() => {
    try {
      initialiseGL();
      setError(null);
    } catch (err) {
      console.error(err);
      setError(err.message);
      return () => {};
    }

    const handleResize = () => {
      resizeCanvas();
      recalculateHotspotPositions();
    };

    window.addEventListener('resize', handleResize);
    resizeCanvas();
    recalculateHotspotPositions();
    animationRef.current = requestAnimationFrame(renderScene);

    return () => {
      window.removeEventListener('resize', handleResize);
      if (animationRef.current) cancelAnimationFrame(animationRef.current);
      const gl = glRef.current;
      if (gl && textureRef.current) {
        gl.deleteTexture(textureRef.current);
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    const gl = glRef.current;
    if (!gl || !imageSrc) {
      return;
    }
    setLoadingTexture(true);
    loadTexture(gl, imageSrc)
      .then((texture) => {
        if (textureRef.current) {
          gl.deleteTexture(textureRef.current);
        }
        textureRef.current = texture;
        setError(null);
      })
      .catch((err) => {
        console.error(err);
        setError(err.message);
      })
      .finally(() => {
        setLoadingTexture(false);
      });
  }, [imageSrc]);

  useEffect(() => {
    recalculateHotspotPositions();
  }, [hotspotsMemo, pendingHotspot, recalculateHotspotPositions]);
  return (
    <div
      ref={containerRef}
      className={`panorama-viewer ${editing ? 'editing' : ''}`}
      tabIndex={0}
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      onPointerLeave={handlePointerUp}
      onWheel={handleWheel}
      role="application"
      aria-label="360 degree viewer"
    >
      <div className="panorama-canvas" role="presentation">
        <canvas ref={canvasRef} />
      </div>

      {(loadingTexture || error) && (
        <div className={`panorama-overlay ${error ? 'error' : ''}`}>
          {error ? <span>{error}</span> : (
            <>
              <div className="spinner" />
              <span>Loading panorama…</span>
            </>
          )}
        </div>
      )}

      {editing && pendingPosition?.visible && (
        <div
          className="panorama-hotspot pending"
          style={{ transform: `translate(-50%, -50%) translate(${pendingPosition.x}px, ${pendingPosition.y}px)` }}
        >
          <span className="panorama-hotspot-icon">?</span>
        </div>
      )}

      {hotspotPositions.map(({ id, x, y, visible, hotspot }) => {
        if (!visible) return null;
        const label = hotspotTooltipFormatter
          ? hotspotTooltipFormatter(hotspot)
          : hotspot.label || 'Navigate';
        return (
          <button
            key={id}
            type="button"
            className="panorama-hotspot"
            style={{ transform: `translate(-50%, -50%) translate(${x}px, ${y}px)` }}
            onClick={(event) => {
              event.stopPropagation();
              if (typeof onHotspotClick === 'function') {
                onHotspotClick(hotspot);
              }
            }}
          >
            <span className="panorama-hotspot-icon">➜</span>
            {label && <span className="panorama-hotspot-label">{label}</span>}
          </button>
        );
      })}
    </div>
  );
};

export const createHotspotFromClick = ({ yaw, pitch, label }) => ({
  id: generateId(),
  yaw,
  pitch,
  label,
});

export const radToDeg = (rad) => rad * DEGREE;
export const degToRad = (deg) => deg * RADIAN;

export default PanoramaViewer;
