import React, { useState, useEffect, useRef } from 'react';
import '../styles/HotspotEditor.css';

/**
 * Hotspot Editor Component
 * Allows sellers to click on 360° image preview to position navigation hotspots
 */
const HotspotEditor = ({ scene, allScenes, onHotspotsChange }) => {
  const [hotspots, setHotspots] = useState([]);
  const [selectedHotspot, setSelectedHotspot] = useState(null);
  const [showTargetSelector, setShowTargetSelector] = useState(false);
  const [clickPosition, setClickPosition] = useState(null);
  const viewerRef = useRef(null);
  const iframeRef = useRef(null);

  // Generate a unique URL for the preview viewer
  const previewUrl = scene.images && scene.images.length > 0
    ? URL.createObjectURL(scene.images[0])
    : null;

  // Handle click on the 360° preview to add hotspot
  const handleImageClick = (e) => {
    if (!viewerRef.current) return;

    const rect = viewerRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    // Calculate yaw and pitch from click position
    // For equirectangular images: 
    // yaw = (x / width) * 2π - π
    // pitch = (y / height) * π - π/2
    const width = rect.width;
    const height = rect.height;
    
    const yaw = ((x / width) * 2 * Math.PI) - Math.PI;
    const pitch = ((y / height) * Math.PI) - (Math.PI / 2);

    // Convert to degrees for display
    const yawDegrees = (yaw * 180 / Math.PI).toFixed(1);
    const pitchDegrees = (pitch * 180 / Math.PI).toFixed(1);

    setClickPosition({ 
      x, 
      y, 
      yaw, 
      pitch,
      yawDegrees,
      pitchDegrees
    });
    setShowTargetSelector(true);
  };

  // Add hotspot with target room
  const addHotspot = (targetSceneId, targetSceneName) => {
    if (!clickPosition) return;

    const newHotspot = {
      id: Date.now(),
      x: clickPosition.x,
      y: clickPosition.y,
      yaw: clickPosition.yaw,
      pitch: clickPosition.pitch,
      targetSceneId,
      targetSceneName,
      title: `Go to ${targetSceneName}`,
    };

    const updatedHotspots = [...hotspots, newHotspot];
    setHotspots(updatedHotspots);
    onHotspotsChange(updatedHotspots);

    // Reset
    setClickPosition(null);
    setShowTargetSelector(false);
  };

  // Remove hotspot
  const removeHotspot = (id) => {
    const updatedHotspots = hotspots.filter(h => h.id !== id);
    setHotspots(updatedHotspots);
    onHotspotsChange(updatedHotspots);
    setSelectedHotspot(null);
  };

  // Get available target scenes (exclude current scene)
  const availableScenes = allScenes.filter(s => s.id !== scene.id);

  return (
    <div className="hotspot-editor">
      <div className="editor-header">
        <h3>🎯 Add Navigation Hotspots for: {scene.name}</h3>
        <p className="editor-help">
          Click on doors or passages in the image below to add navigation arrows to other rooms.
        </p>
      </div>

      {/* 360° Preview Image with Click Capture */}
      <div className="preview-container">
        {previewUrl ? (
          <div
            ref={viewerRef}
            className="image-preview-clickable"
            onClick={handleImageClick}
            style={{ 
              backgroundImage: `url(${previewUrl})`,
              backgroundSize: 'cover',
              backgroundPosition: 'center',
              cursor: 'crosshair',
              position: 'relative'
            }}
          >
            {/* Render existing hotspots as visual markers */}
            {hotspots.map((hotspot) => (
              <div
                key={hotspot.id}
                className={`hotspot-marker ${selectedHotspot === hotspot.id ? 'selected' : ''}`}
                style={{
                  left: `${hotspot.x}px`,
                  top: `${hotspot.y}px`,
                }}
                onClick={(e) => {
                  e.stopPropagation();
                  setSelectedHotspot(hotspot.id);
                }}
              >
                <span className="hotspot-arrow">→</span>
                <div className="hotspot-tooltip">
                  {hotspot.title}
                  <button 
                    className="remove-hotspot"
                    onClick={(e) => {
                      e.stopPropagation();
                      removeHotspot(hotspot.id);
                    }}
                  >
                    ✕
                  </button>
                </div>
              </div>
            ))}

            {/* Show click position preview */}
            {clickPosition && showTargetSelector && (
              <div
                className="hotspot-marker preview"
                style={{
                  left: `${clickPosition.x}px`,
                  top: `${clickPosition.y}px`,
                }}
              >
                <span className="hotspot-arrow">?</span>
              </div>
            )}

            <div className="overlay-instructions">
              💡 Click anywhere to add a navigation hotspot
            </div>
          </div>
        ) : (
          <div className="no-preview">
            <p>📸 Upload a 360° image first to position hotspots</p>
          </div>
        )}
      </div>

      {/* Target Room Selector Modal */}
      {showTargetSelector && clickPosition && (
        <div className="target-selector-modal">
          <div className="modal-content">
            <h3>Select Target Room</h3>
            <p className="coordinates">
              Position: Yaw {clickPosition.yawDegrees}°, Pitch {clickPosition.pitchDegrees}°
            </p>
            
            {availableScenes.length > 0 ? (
              <div className="scene-options">
                {availableScenes.map((targetScene) => (
                  <button
                    key={targetScene.id}
                    className="scene-option"
                    onClick={() => addHotspot(targetScene.id, targetScene.name)}
                  >
                    → Go to {targetScene.name}
                  </button>
                ))}
              </div>
            ) : (
              <p className="no-targets">
                Add more rooms to create navigation between them.
              </p>
            )}

            <button 
              className="cancel-button"
              onClick={() => {
                setClickPosition(null);
                setShowTargetSelector(false);
              }}
            >
              Cancel
            </button>
          </div>
        </div>
      )}

      {/* Hotspot List */}
      <div className="hotspots-list">
        <h4>Navigation Hotspots ({hotspots.length})</h4>
        {hotspots.length === 0 ? (
          <p className="empty-message">No hotspots added yet. Click on the image to add one!</p>
        ) : (
          <ul>
            {hotspots.map((hotspot) => (
              <li 
                key={hotspot.id}
                className={selectedHotspot === hotspot.id ? 'selected' : ''}
              >
                <span className="hotspot-info">
                  → {hotspot.title}
                  <small>
                    (Yaw: {(hotspot.yaw * 180 / Math.PI).toFixed(1)}°, 
                    Pitch: {(hotspot.pitch * 180 / Math.PI).toFixed(1)}°)
                  </small>
                </span>
                <button
                  className="remove-btn"
                  onClick={() => removeHotspot(hotspot.id)}
                  title="Remove hotspot"
                >
                  🗑️
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>

      {/* Instructions Panel */}
      <div className="instructions-panel">
        <h4>📖 How to Add Hotspots:</h4>
        <ol>
          <li>Click on a door or passage in the 360° image above</li>
          <li>Select which room the door leads to</li>
          <li>A navigation arrow will appear at that position</li>
          <li>Repeat for all connections between rooms</li>
        </ol>
        <p className="tip">
          💡 <strong>Tip:</strong> Position hotspots where visitors would naturally look to find doors or passages.
        </p>
      </div>
    </div>
  );
};

export default HotspotEditor;

