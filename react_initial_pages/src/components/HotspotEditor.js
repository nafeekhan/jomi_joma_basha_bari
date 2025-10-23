import React, { useEffect, useMemo, useState } from 'react';
import PanoramaViewer from './PanoramaViewer';
import '../styles/HotspotEditor.css';

const buildViewpointOptions = (rooms, excludeViewpointId) =>
  rooms.flatMap((room) =>
    (room.viewpoints || [])
      .filter((viewpoint) => viewpoint.id !== excludeViewpointId && viewpoint.panoramaDataUrl)
      .map((viewpoint) => ({
        roomId: room.id,
        roomName: room.name,
        viewpointId: viewpoint.id,
        viewpointName: viewpoint.name,
      }))
  );

const HotspotEditor = ({ rooms, onRoomsChange }) => {
  const [selectedRoomId, setSelectedRoomId] = useState(rooms[0]?.id || null);
  const [selectedViewpointId, setSelectedViewpointId] = useState(
    rooms[0]?.defaultViewpointId || rooms[0]?.viewpoints?.[0]?.id || null
  );
  const [pendingHotspot, setPendingHotspot] = useState(null);

  useEffect(() => {
    if (!selectedRoomId && rooms.length > 0) {
      setSelectedRoomId(rooms[0].id);
      setSelectedViewpointId(rooms[0].defaultViewpointId || rooms[0].viewpoints?.[0]?.id || null);
    }
  }, [rooms, selectedRoomId]);

  const currentRoom = useMemo(
    () => rooms.find((room) => room.id === selectedRoomId) || rooms[0],
    [rooms, selectedRoomId]
  );

  const currentViewpoint = useMemo(() => {
    if (!currentRoom) return null;
    const fallbackId = currentRoom.defaultViewpointId || currentRoom.viewpoints?.[0]?.id;
    const viewpoint = currentRoom.viewpoints?.find((vp) => vp.id === (selectedViewpointId || fallbackId));
    return viewpoint || null;
  }, [currentRoom, selectedViewpointId]);

  useEffect(() => {
    if (!currentRoom) return;
    if (!currentViewpoint && currentRoom.viewpoints?.length) {
      setSelectedViewpointId(currentRoom.defaultViewpointId || currentRoom.viewpoints[0].id);
    }
  }, [currentRoom, currentViewpoint]);

  const handleRoomChange = (roomId) => {
    setSelectedRoomId(roomId);
    const room = rooms.find((r) => r.id === roomId);
    if (room) {
      setSelectedViewpointId(room.defaultViewpointId || room.viewpoints?.[0]?.id || null);
    }
  };

  const handleViewpointChange = (viewpointId) => {
    setSelectedViewpointId(viewpointId);
  };

  const handleAddHotspot = ({ yaw, pitch }) => {
    setPendingHotspot({ yaw, pitch });
  };

  const commitHotspot = (targetViewpointId) => {
    if (!currentRoom || !currentViewpoint || !pendingHotspot) return;

    onRoomsChange(
      rooms.map((room) => {
        if (room.id !== currentRoom.id) return room;
        return {
          ...room,
          viewpoints: room.viewpoints.map((viewpoint) => {
            if (viewpoint.id !== currentViewpoint.id) return viewpoint;
            const newHotspot = {
              id: `hotspot-${Date.now()}-${Math.random().toString(16).slice(2, 6)}`,
              yaw: pendingHotspot.yaw,
              pitch: pendingHotspot.pitch,
              targetViewpointId,
            };
            return {
              ...viewpoint,
              hotspots: [...(viewpoint.hotspots || []), newHotspot],
            };
          }),
        };
      })
    );

    setPendingHotspot(null);
  };

  const removeHotspot = (hotspotId) => {
    if (!currentRoom || !currentViewpoint) return;

    onRoomsChange(
      rooms.map((room) => {
        if (room.id !== currentRoom.id) return room;
        return {
          ...room,
          viewpoints: room.viewpoints.map((viewpoint) =>
            viewpoint.id === currentViewpoint.id
              ? {
                  ...viewpoint,
                  hotspots: (viewpoint.hotspots || []).filter((hotspot) => hotspot.id !== hotspotId),
                }
              : viewpoint
          ),
        };
      })
    );
  };

  const globalViewpointOptions = useMemo(() => buildViewpointOptions(rooms), [rooms]);

  const viewpointOptions = useMemo(() => {
    if (!currentViewpoint) return [];
    return globalViewpointOptions.filter((option) => option.viewpointId !== currentViewpoint.id);
  }, [currentViewpoint, globalViewpointOptions]);

  const hotspotWithLabels = useMemo(() => {
    if (!currentViewpoint) return [];
    return (currentViewpoint.hotspots || []).map((hotspot) => {
      const target = globalViewpointOptions.find((option) => option.viewpointId === hotspot.targetViewpointId);
      return {
        ...hotspot,
        targetLabel: target ? `${target.roomName} • ${target.viewpointName}` : 'Unknown target',
      };
    });
  }, [currentViewpoint, globalViewpointOptions]);

  if (!currentRoom || !currentViewpoint) {
    return (
      <div className="hotspot-editor">
        <h3>Navigation Hotspots</h3>
        <p className="empty-state">Add at least one room and viewpoint to configure hotspots.</p>
      </div>
    );
  }

  return (
    <div className="hotspot-editor">
      <div className="hotspot-split">
        <div className="hotspot-config">
          <h3>Navigation Hotspots</h3>
          <p className="hotspot-help">
            Click within the 360° viewer to add navigation arrows. Select the viewpoint the arrow should navigate to.
          </p>

          <div className="selector-group">
            <label htmlFor="room-selector">Room</label>
            <div className="selector-row">
              {rooms.map((room) => (
                <button
                  key={room.id}
                  type="button"
                  className={`selector-pill ${room.id === currentRoom.id ? 'active' : ''}`}
                  onClick={() => handleRoomChange(room.id)}
                >
                  {room.name}
                </button>
              ))}
            </div>
          </div>

          <div className="selector-group">
            <label htmlFor="viewpoint-selector">Viewpoints in {currentRoom.name}</label>
            <div className="selector-row">
              {currentRoom.viewpoints.map((viewpoint) => (
                <button
                  key={viewpoint.id}
                  type="button"
                  className={`selector-chip ${viewpoint.id === currentViewpoint.id ? 'active' : ''}`}
                  onClick={() => handleViewpointChange(viewpoint.id)}
                >
                  {viewpoint.name}
                  {viewpoint.isDefault && <span className="chip-badge">Default</span>}
                </button>
              ))}
            </div>
          </div>

          <div className="hotspot-list">
            <h4>Existing Hotspots</h4>
            {hotspotWithLabels.length === 0 ? (
              <p className="empty-state">No hotspots yet. Click inside the viewer to add one.</p>
            ) : (
              <ul>
                {hotspotWithLabels.map((hotspot) => (
                  <li key={hotspot.id}>
                    <div>
                      <strong>{hotspot.targetLabel}</strong>
                      <span className="coordinates">
                        Yaw {hotspot.yaw.toFixed(2)}, Pitch {hotspot.pitch.toFixed(2)}
                      </span>
                    </div>
                    <button
                      type="button"
                      className="btn-icon btn-danger-small"
                      onClick={() => removeHotspot(hotspot.id)}
                    >
                      ✕
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>

        <div className="hotspot-viewer">
          <div className="viewer-header">
            <h4>
              {currentRoom.name} • {currentViewpoint.name}
            </h4>
          </div>
          <PanoramaViewer
            imageSrc={currentViewpoint.panoramaDataUrl}
            hotspots={(currentViewpoint.hotspots || []).map((hotspot) => ({
              ...hotspot,
              label:
                globalViewpointOptions.find((option) => option.viewpointId === hotspot.targetViewpointId)?.viewpointName ||
                'View',
            }))}
            editing
            onAddHotspot={handleAddHotspot}
          />
        </div>
      </div>

      {pendingHotspot && (
        <div className="hotspot-modal" role="dialog" aria-modal="true">
          <div className="hotspot-modal-content">
            <h3>Select navigation target</h3>
            <p>
              Yaw {pendingHotspot.yaw.toFixed(2)} • Pitch {pendingHotspot.pitch.toFixed(2)}
            </p>

            {viewpointOptions.length === 0 ? (
              <p className="empty-state">Add more viewpoints to connect this hotspot.</p>
            ) : (
              <div className="modal-options">
                {viewpointOptions.map((option) => (
                  <button
                    key={option.viewpointId}
                    type="button"
                    className="modal-option"
                    onClick={() => commitHotspot(option.viewpointId)}
                  >
                    <strong>{option.roomName}</strong>
                    <span>{option.viewpointName}</span>
                  </button>
                ))}
              </div>
            )}

            <button type="button" className="cancel-button" onClick={() => setPendingHotspot(null)}>
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default HotspotEditor;
