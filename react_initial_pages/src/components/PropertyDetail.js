import React, { useEffect, useMemo, useState } from 'react';
import PanoramaViewer from './PanoramaViewer';
import { SAMPLE_PROPERTY, extractCoverImage } from '../data/sampleProperty';
import { apiGet } from '../api/client';
import '../styles/PropertyDetail.css';

const mapSampleProperty = (sample) => ({
  id: sample.id,
  title: sample.title,
  description: sample.description,
  propertyType: sample.propertyType,
  price: sample.price,
  bedrooms: sample.bedrooms,
  bathrooms: sample.bathrooms,
  sizeSqft: sample.sizeSqft,
  furnished: sample.furnished,
  addressLine: sample.addressLine,
  city: sample.city,
  state: sample.state,
  country: sample.country,
  postalCode: sample.postalCode,
  tags: sample.tags,
  rooms: sample.rooms.map((room) => ({
    id: room.id,
    name: room.name,
    defaultViewpointId: room.defaultViewpointId,
    viewpoints: room.viewpoints.map((vp) => ({
      id: vp.id,
      name: vp.name,
      panoramaDataUrl: vp.panoramaDataUrl,
      preview_image_url: vp.panoramaDataUrl,
      isDefault: vp.isDefault,
      hotspots: vp.hotspots || [],
    })),
  })),
});

const mapBackendProperty = (property) => ({
  id: property.id,
  title: property.title,
  description: property.description,
  propertyType: property.property_type,
  price: Number(property.price) || 0,
  bedrooms: property.bedrooms,
  bathrooms: property.bathrooms,
  sizeSqft: property.size_sqft,
  furnished: property.furnished,
  addressLine: property.address_line,
  city: property.city,
  state: property.state,
  country: property.country,
  postalCode: property.postal_code,
  tags: property.tags || [],
  sellerName: property.seller_name,
  sellerEmail: property.seller_email,
  rooms: (property.rooms || []).map((room) => ({
    id: room.id,
    name: room.room_name,
    defaultViewpointId: room.default_viewpoint_id,
    viewpoints: (room.viewpoints || []).map((viewpoint) => ({
      id: viewpoint.id,
      name: viewpoint.viewpoint_name || viewpoint.scene_name,
      panoramaDataUrl: viewpoint.preview_image_url,
      preview_image_url: viewpoint.preview_image_url,
      isDefault: viewpoint.is_default_viewpoint,
      hotspots: (viewpoint.hotspots || []).map((hotspot) => ({
        id: hotspot.id,
        yaw: hotspot.yaw,
        pitch: hotspot.pitch,
        targetViewpointId: hotspot.target_scene_id,
        label: hotspot.title,
      })),
    })),
  })),
});

const findViewpointById = (rooms, viewpointId) => {
  for (const room of rooms || []) {
    const match = room.viewpoints?.find((vp) => vp.id === viewpointId);
    if (match) {
      return { room, viewpoint: match };
    }
  }
  return null;
};

const buildHotspotsWithLabels = (rooms, hotspots = []) =>
  hotspots.map((hotspot) => {
    const target = findViewpointById(rooms, hotspot.targetViewpointId);
    return {
      ...hotspot,
      label:
        hotspot.label ||
        (target ? `${target.room.name.split(' ')[0]} → ${target.viewpoint.name}` : 'Navigate'),
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
    const fetchProperty = async () => {
      try {
        setLoading(true);
        const params = new URLSearchParams(window.location.search);
        const queryId = params.get('propertyId');
        const storedId = localStorage.getItem('jjbb_last_property_id');
        const targetId = queryId || storedId;

        if (targetId) {
          const response = await apiGet(`/api/properties/${targetId}`);
          const propertyData = response?.data?.property;
          if (propertyData) {
            setProperty(mapBackendProperty(propertyData));
            localStorage.setItem('jjbb_last_property_id', targetId);
            setError(null);
            return;
          }
        }

        setProperty(mapSampleProperty(SAMPLE_PROPERTY));
        setError(null);
      } catch (err) {
        console.error('Failed to load property details', err);
        setError('Unable to load property from the server. Showing demo property instead.');
        setProperty(mapSampleProperty(SAMPLE_PROPERTY));
      } finally {
        setLoading(false);
      }
    };

    fetchProperty();
  }, []);

  useEffect(() => {
    if (!property?.rooms?.length) return;
    const firstRoom = property.rooms[0];
    const firstViewpoint =
      firstRoom.viewpoints.find((vp) => vp.id === firstRoom.defaultViewpointId) ||
      firstRoom.viewpoints[0];
    setCurrentRoomId(firstRoom.id);
    setCurrentViewpointId(firstViewpoint?.id || null);
  }, [property]);

  const rooms = useMemo(() => property?.rooms || [], [property]);

  const currentRoom = useMemo(
    () => rooms.find((room) => room.id === currentRoomId) || rooms[0],
    [rooms, currentRoomId]
  );

  const currentViewpoint = useMemo(() => {
    if (!currentRoom) return null;
    const fallbackId = currentRoom.defaultViewpointId || currentRoom.viewpoints?.[0]?.id;
    return (
      currentRoom.viewpoints?.find((viewpoint) => viewpoint.id === (currentViewpointId || fallbackId)) ||
      null
    );
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

  if (error && !property) {
    return (
      <div className="error-container">
        <h2>⚠️ Error</h2>
        <p>{error}</p>
      </div>
    );
  }

  if (!property) {
    return null;
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
