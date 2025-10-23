import React, { useEffect, useMemo, useState } from 'react';
import PanoramaViewer from './PanoramaViewer';
import {
  loadPropertyFromStorage,
  normaliseRooms,
  findViewpointById,
} from '../models/property';
import { SAMPLE_PROPERTY, extractCoverImage } from '../data/sampleProperty';
import '../styles/PropertyDetail.css';

const buildHotspotsWithLabels = (rooms, hotspots = []) =>
  hotspots.map((hotspot) => {
    const target = findViewpointById(rooms, hotspot.targetViewpointId);
    return {
      ...hotspot,
      label: target ? `${target.room.name.split(' ')[0]} → ${target.viewpoint.name}` : 'Navigate',
    };
  });

const PropertyDetail = () => {
  const [property, setProperty] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showTour, setShowTour] = useState(false);
  const [currentRoomId, setCurrentRoomId] = useState(null);
  const [currentViewpointId, setCurrentViewpointId] = useState(null);

  useEffect(() => {
    try {
      const stored = loadPropertyFromStorage();
      const baseProperty = stored ? { ...stored } : { ...SAMPLE_PROPERTY };
      baseProperty.rooms = normaliseRooms(baseProperty.rooms || []);
      setProperty(baseProperty);

      const firstRoom = baseProperty.rooms[0];
      if (firstRoom) {
        setCurrentRoomId(firstRoom.id);
        setCurrentViewpointId(firstRoom.defaultViewpointId || firstRoom.viewpoints?.[0]?.id || null);
      }
      setLoading(false);
    } catch (err) {
      console.error(err);
      setError('Failed to load property details');
      setLoading(false);
    }
  }, []);

  const rooms = useMemo(() => property?.rooms || [], [property]);

  const currentRoom = useMemo(
    () => rooms.find((room) => room.id === currentRoomId) || rooms[0],
    [rooms, currentRoomId]
  );

  const currentViewpoint = useMemo(() => {
    if (!currentRoom) return null;
    const fallbackId = currentRoom.defaultViewpointId || currentRoom.viewpoints?.[0]?.id;
    return currentRoom.viewpoints?.find((viewpoint) => viewpoint.id === (currentViewpointId || fallbackId)) || null;
  }, [currentRoom, currentViewpointId]);

  const handleSelectRoom = (roomId) => {
    const room = rooms.find((r) => r.id === roomId);
    if (!room) return;
    setCurrentRoomId(roomId);
    setCurrentViewpointId(room.defaultViewpointId || room.viewpoints?.[0]?.id || null);
  };

  const handleSelectViewpoint = (viewpointId) => {
    setCurrentViewpointId(viewpointId);
  };

  const handleHotspotClick = (hotspot) => {
    if (!hotspot?.targetViewpointId) return;
    const target = findViewpointById(rooms, hotspot.targetViewpointId);
    if (target) {
      setCurrentRoomId(target.room.id);
      setCurrentViewpointId(target.viewpoint.id);
    }
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner" />
        <p>Loading property details…</p>
      </div>
    );
  }

  if (error || !property) {
    return (
      <div className="error-container">
        <h2>⚠️ Error</h2>
        <p>{error || 'Property not available.'}</p>
      </div>
    );
  }

  const coverImage = extractCoverImage(property);

  return (
    <div className="property-detail-container">
      {showTour && currentViewpoint && (
        <div className="tour-modal">
          <div className="tour-modal-content">
            <button className="close-btn" onClick={() => setShowTour(false)}>
              ✕
            </button>
            <h2>360° Virtual Tour • {currentRoom?.name}</h2>

            <div className="tour-viewer">
              <PanoramaViewer
                imageSrc={currentViewpoint.panoramaDataUrl}
                hotspots={buildHotspotsWithLabels(rooms, currentViewpoint.hotspots || [])}
                onHotspotClick={handleHotspotClick}
              />
            </div>

            <div className="tour-scene-selector">
              <div className="room-selector">
                {rooms.map((room) => (
                  <button
                    key={room.id}
                    type="button"
                    className={`selector-pill ${room.id === currentRoom.id ? 'active' : ''}`}
                    onClick={() => handleSelectRoom(room.id)}
                  >
                    {room.name}
                  </button>
                ))}
              </div>
              <div className="viewpoint-selector">
                {currentRoom?.viewpoints?.map((viewpoint) => (
                  <button
                    key={viewpoint.id}
                    type="button"
                    className={`selector-chip ${viewpoint.id === currentViewpoint.id ? 'active' : ''}`}
                    onClick={() => handleSelectViewpoint(viewpoint.id)}
                  >
                    {viewpoint.name}
                    {viewpoint.isDefault && <span className="chip-badge">Default</span>}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}

      <div className="property-images">
        <div className="main-image">
          <img src={coverImage} alt={property.title} />
        </div>
      </div>

      {rooms.length > 0 && (
        <div className="tour-button-container">
          <button className="tour-button" onClick={() => setShowTour(true)}>
            🌐 View 360° Virtual Tour
          </button>
        </div>
      )}

      <div className="property-info">
        <div className="property-header">
          <div>
            <h1>{property.title}</h1>
            <p className="address">
              📍 {property.addressLine}, {property.city}, {property.state} {property.postalCode}
            </p>
          </div>
          <div className="price">${Number(property.price || 0).toLocaleString()}</div>
        </div>

        <div className="property-stats">
          <div className="stat">
            <span className="stat-icon">🛏️</span>
            <span>{property.bedrooms} Beds</span>
          </div>
          <div className="stat">
            <span className="stat-icon">🛁</span>
            <span>{property.bathrooms} Baths</span>
          </div>
          <div className="stat">
            <span className="stat-icon">📐</span>
            <span>{property.sizeSqft} sqft</span>
          </div>
          <div className="stat">
            <span className="stat-icon">🛋️</span>
            <span>{property.furnished ? 'Furnished' : 'Unfurnished'}</span>
          </div>
        </div>

        <div className="tabs">
          <div className="tab-content">
            <h3>Description</h3>
            <p>{property.description}</p>

            <h3>Features</h3>
            <div className="features">
              {property.tags?.map((tag) => (
                <span key={tag} className="feature-tag">
                  {tag}
                </span>
              ))}
            </div>

            <h3>360° Rooms</h3>
            <div className="room-summary">
              {rooms.map((room) => (
                <div key={room.id} className="room-summary-card">
                  <h4>{room.name}</h4>
                  <p>{room.viewpoints.length} viewpoint(s)</p>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="action-buttons">
          <button className="btn-primary">📞 Contact Seller</button>
          <button className="btn-primary">📅 Schedule Visit</button>
        </div>
      </div>
    </div>
  );
};

export default PropertyDetail;
