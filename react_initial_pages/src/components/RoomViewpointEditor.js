import React, { useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { readFileAsDataUrl } from '../utils/file';
import '../styles/RoomViewpointEditor.css';

/**
 * Room Viewpoint Editor Component
 * Allows sellers to add rooms and multiple viewpoints for each room
 */
const RoomViewpointEditor = ({ rooms, onRoomsChange }) => {
  const [expandedRoom, setExpandedRoom] = useState(null);

  const addRoom = () => {
    const newRoom = {
      id: Date.now(),
      name: `Room ${rooms.length + 1}`,
      order: rooms.length,
      viewpoints: []
    };
    onRoomsChange([...rooms, newRoom]);
    setExpandedRoom(newRoom.id);
  };

  const updateRoomName = (roomId, name) => {
    onRoomsChange(rooms.map(r => 
      r.id === roomId ? { ...r, name } : r
    ));
  };

  const removeRoom = (roomId) => {
    onRoomsChange(rooms.filter(r => r.id !== roomId));
    if (expandedRoom === roomId) {
      setExpandedRoom(null);
    }
  };

  const addViewpoint = (roomId) => {
    onRoomsChange(rooms.map((room) => {
      if (room.id !== roomId) return room;
      const isFirst = room.viewpoints.length === 0;
      const newViewpoint = {
        id: `vp-${Date.now()}-${Math.random().toString(16).slice(2, 6)}`,
        name: `Viewpoint ${room.viewpoints.length + 1}`,
        panoramaDataUrl: null,
        isDefault: isFirst,
        hotspots: [],
      };
      return {
        ...room,
        defaultViewpointId: isFirst ? newViewpoint.id : room.defaultViewpointId,
        viewpoints: [
          ...room.viewpoints.map((vp) => ({
            ...vp,
            hotspots: vp.hotspots || [],
          })),
          newViewpoint,
        ],
      };
    }));
  };

  const updateViewpointName = (roomId, viewpointId, name) => {
    onRoomsChange(rooms.map(r => {
      if (r.id === roomId) {
        return {
          ...r,
          viewpoints: r.viewpoints.map(v =>
            v.id === viewpointId ? { ...v, name } : v
          )
        };
      }
      return r;
    }));
  };

  const setDefaultViewpoint = (roomId, viewpointId) => {
    onRoomsChange(rooms.map(r => {
      if (r.id === roomId) {
        return {
          ...r,
          defaultViewpointId: viewpointId,
          viewpoints: r.viewpoints.map((v) => ({
            ...v,
            hotspots: v.hotspots || [],
            isDefault: v.id === viewpointId,
          })),
        };
      }
      return r;
    }));
  };

  const removeViewpoint = (roomId, viewpointId) => {
    onRoomsChange(rooms.map((room) => {
      if (room.id !== roomId) return room;
      const removedViewpoint = room.viewpoints.find((v) => v.id === viewpointId);
      const updatedViewpoints = room.viewpoints
        .filter((v) => v.id !== viewpointId)
        .map((vp) => ({ ...vp, hotspots: vp.hotspots || [] }));

      let defaultViewpointId = room.defaultViewpointId;
      if (removedViewpoint?.isDefault) {
        if (updatedViewpoints.length > 0) {
          defaultViewpointId = updatedViewpoints[0].id;
          updatedViewpoints[0] = { ...updatedViewpoints[0], isDefault: true };
          for (let i = 1; i < updatedViewpoints.length; i += 1) {
            updatedViewpoints[i] = { ...updatedViewpoints[i], isDefault: false };
          }
        } else {
          defaultViewpointId = null;
        }
      }

      return {
        ...room,
        defaultViewpointId,
        viewpoints: updatedViewpoints,
      };
    }));
  };

  const handleImageDrop = async (roomId, viewpointId, acceptedFiles) => {
    if (!acceptedFiles || acceptedFiles.length === 0) return;
    const file = acceptedFiles[0];
    try {
      const dataUrl = await readFileAsDataUrl(file);
      onRoomsChange(rooms.map((room) => {
        if (room.id !== roomId) return room;
        return {
          ...room,
          viewpoints: room.viewpoints.map((viewpoint) =>
            viewpoint.id === viewpointId
              ? { ...viewpoint, panoramaDataUrl: dataUrl, imageName: file.name }
              : viewpoint
          ),
        };
      }));
    } catch (error) {
      console.error('Failed to read panorama image', error);
      alert('Failed to read image file. Please try again with a valid 360° image.');
    }
  };

  return (
    <div className="room-viewpoint-editor">
      <div className="editor-header">
        <h2>🏠 Add Rooms & Viewpoints</h2>
        <p className="editor-description">
          Create rooms and add multiple 360° viewpoints for each room. 
          Each room should have at least one viewpoint (entrance is recommended as default).
        </p>
      </div>

      {rooms.length === 0 && (
        <div className="empty-state">
          <div className="empty-icon">🏠</div>
          <p>No rooms added yet</p>
          <button className="btn-primary" onClick={addRoom}>
            ➕ Add Your First Room
          </button>
        </div>
      )}

      <div className="rooms-list">
        {rooms.map((room, index) => (
          <div key={room.id} className="room-card">
            <div className="room-header">
              <div className="room-header-left">
                <span className="room-number">#{index + 1}</span>
                <input
                  type="text"
                  value={room.name}
                  onChange={(e) => updateRoomName(room.id, e.target.value)}
                  className="room-name-input"
                  placeholder="e.g., Living Room, Master Bedroom"
                />
              </div>
              <div className="room-header-actions">
                <button
                  className="btn-icon"
                  onClick={() => setExpandedRoom(expandedRoom === room.id ? null : room.id)}
                  title={expandedRoom === room.id ? "Collapse" : "Expand"}
                >
                  {expandedRoom === room.id ? '▼' : '▶'}
                </button>
                <button
                  className="btn-icon btn-danger"
                  onClick={() => removeRoom(room.id)}
                  title="Remove room"
                >
                  🗑️
                </button>
              </div>
            </div>

            {expandedRoom === room.id && (
              <div className="room-content">
                <div className="viewpoints-section">
                  <div className="section-header">
                    <h4>📸 Viewpoints ({room.viewpoints.length})</h4>
                    <button
                      className="btn-secondary"
                      onClick={() => addViewpoint(room.id)}
                    >
                      ➕ Add Viewpoint
                    </button>
                  </div>

                  {room.viewpoints.length === 0 ? (
                    <div className="no-viewpoints">
                      <p>No viewpoints added. Add at least one viewpoint for this room.</p>
                    </div>
                  ) : (
                    <div className="viewpoints-grid">
                      {room.viewpoints.map((viewpoint) => (
                        <ViewpointCard
                          key={viewpoint.id}
                          viewpoint={viewpoint}
                          onNameChange={(name) => updateViewpointName(room.id, viewpoint.id, name)}
                          onSetDefault={() => setDefaultViewpoint(room.id, viewpoint.id)}
                          onRemove={() => removeViewpoint(room.id, viewpoint.id)}
                          onImageDrop={(files) => handleImageDrop(room.id, viewpoint.id, files)}
                          isOnlyViewpoint={room.viewpoints.length === 1}
                        />
                      ))}
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      {rooms.length > 0 && (
        <button className="btn-add-room" onClick={addRoom}>
          ➕ Add Another Room
        </button>
      )}

      <div className="info-panel">
        <h4>💡 Tips:</h4>
        <ul>
          <li>Add a room name that clearly identifies the space (e.g., "Living Room", "Master Bedroom")</li>
          <li>Add at least one viewpoint per room (the entrance view is recommended)</li>
          <li>Add multiple viewpoints for larger rooms to show different angles</li>
          <li>Mark the entrance or main viewpoint as "default" - this is where visitors arrive</li>
          <li>Upload equirectangular 360° images for each viewpoint</li>
        </ul>
      </div>
    </div>
  );
};

/**
 * Viewpoint Card Component
 */
const ViewpointCard = ({ viewpoint, onNameChange, onSetDefault, onRemove, onImageDrop, isOnlyViewpoint }) => {
  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop: onImageDrop,
    accept: {
      'image/jpeg': ['.jpg', '.jpeg'],
      'image/png': ['.png']
    },
    maxFiles: 1,
    multiple: false
  });

  return (
    <div className={`viewpoint-card ${viewpoint.isDefault ? 'default-viewpoint' : ''}`}>
      <div className="viewpoint-header">
        <input
          type="text"
          value={viewpoint.name}
          onChange={(e) => onNameChange(e.target.value)}
          className="viewpoint-name-input"
          placeholder="e.g., Center, Door, Window"
        />
        {!isOnlyViewpoint && (
          <button
            className="btn-icon btn-danger-small"
            onClick={onRemove}
            title="Remove viewpoint"
          >
            ✕
          </button>
        )}
      </div>

      <div {...getRootProps()} className={`image-dropzone ${isDragActive ? 'drag-active' : ''}`}>
        <input {...getInputProps()} />
        {viewpoint.panoramaDataUrl ? (
          <div className="image-preview">
            <img src={viewpoint.panoramaDataUrl} alt={viewpoint.name} />
            <div className="image-overlay">
              <span>✓ {viewpoint.imageName || 'Panorama image selected'}</span>
              <small>Click or drag to replace</small>
            </div>
          </div>
        ) : (
          <div className="dropzone-placeholder">
            <div className="upload-icon">📸</div>
            <p>Drop 360° image here</p>
            <small>or click to browse</small>
          </div>
        )}
      </div>

      <div className="viewpoint-footer">
        {viewpoint.isDefault ? (
          <span className="default-badge">⭐ Default (Entrance)</span>
        ) : (
          <button
            className="btn-set-default"
            onClick={onSetDefault}
          >
            Set as Default
          </button>
        )}
      </div>
    </div>
  );
};

export default RoomViewpointEditor;
