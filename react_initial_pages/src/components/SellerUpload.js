import React, { useState } from 'react';
import { Tooltip } from 'react-tooltip';
import RoomViewpointEditor from './RoomViewpointEditor';
import HotspotEditor from './HotspotEditor';
import { normaliseRooms } from '../models/property';
import { extractCoverImage, SAMPLE_PROPERTY } from '../data/sampleProperty';
import { apiPost, apiPut } from '../api/client';
import { dataUrlToBlob } from '../utils/file';
import '../styles/SellerUpload.css';

const initialFormState = {
  title: SAMPLE_PROPERTY.title,
  description: SAMPLE_PROPERTY.description,
  propertyType: SAMPLE_PROPERTY.propertyType,
  price: SAMPLE_PROPERTY.price,
  bedrooms: SAMPLE_PROPERTY.bedrooms,
  bathrooms: SAMPLE_PROPERTY.bathrooms,
  sizeSqft: SAMPLE_PROPERTY.sizeSqft,
  furnished: SAMPLE_PROPERTY.furnished,
  addressLine: SAMPLE_PROPERTY.addressLine,
  city: SAMPLE_PROPERTY.city,
  state: SAMPLE_PROPERTY.state,
  country: SAMPLE_PROPERTY.country,
  postalCode: SAMPLE_PROPERTY.postalCode,
  tags: SAMPLE_PROPERTY.tags,
};

const SellerUpload = () => {
  const [currentStep, setCurrentStep] = useState(0);
  const [loading, setLoading] = useState(false);

  const [formData, setFormData] = useState(initialFormState);

  const [rooms, setRooms] = useState(() => normaliseRooms(SAMPLE_PROPERTY.rooms));
  const [showResetConfirmation, setShowResetConfirmation] = useState(false);

  const handleInputChange = (event) => {
    const { name, value, type, checked } = event.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }));
  };

  const goToNextStep = () => {
    setCurrentStep((step) => Math.min(step + 1, steps.length - 1));
  };

  const goToPrevStep = () => {
    setCurrentStep((step) => Math.max(step - 1, 0));
  };

  const handleSave = async () => {
    const token = localStorage.getItem('authToken');
    if (!token) {
      alert('Please log in and store your auth token in localStorage under "authToken".');
      return;
    }

    setLoading(true);
    try {
      const propertyPayload = {
        title: formData.title,
        description: formData.description,
        property_type: formData.propertyType || 'buy',
        price: Number(formData.price) || 0,
        size_sqft: formData.sizeSqft ? Number(formData.sizeSqft) : null,
        bedrooms: formData.bedrooms ? Number(formData.bedrooms) : null,
        bathrooms: formData.bathrooms ? Number(formData.bathrooms) : null,
        furnished: !!formData.furnished,
        address_line: formData.addressLine,
        city: formData.city,
        state: formData.state,
        country: formData.country,
        postal_code: formData.postalCode,
        tags: Array.isArray(formData.tags) ? formData.tags : [],
      };

      const propertyResponse = await apiPost('/api/properties', propertyPayload);
      const propertyId = propertyResponse?.data?.property?.id;

      if (!propertyId) {
        throw new Error('Failed to create property');
      }

      const normalisedRooms = normaliseRooms(rooms);
      const roomIdMap = new Map();
      const viewpointIdMap = new Map();
      const hotspotQueue = [];

      for (let roomIndex = 0; roomIndex < normalisedRooms.length; roomIndex += 1) {
        const room = normalisedRooms[roomIndex];
        const roomResponse = await apiPost(`/api/rooms/properties/${propertyId}/rooms`, {
          room_name: room.name,
          room_order: roomIndex,
        });

        const roomId = roomResponse?.data?.room?.id;
        if (!roomId) {
          throw new Error(`Failed to create room: ${room.name}`);
        }
        roomIdMap.set(room.id, roomId);

        let defaultSceneId = null;

        for (let vpIndex = 0; vpIndex < room.viewpoints.length; vpIndex += 1) {
          const viewpoint = room.viewpoints[vpIndex];
          const blob = await dataUrlToBlob(viewpoint.panoramaDataUrl);

          const form = new FormData();
          form.append('scene_name', `${room.name} • ${viewpoint.name}`);
          form.append('scene_order', vpIndex);
          form.append('room_id', roomId);
          form.append('viewpoint_name', viewpoint.name);
          form.append('is_default_viewpoint', viewpoint.isDefault ? 'true' : 'false');
          form.append('initial_view_yaw', viewpoint.initialViewYaw || 0);
          form.append('initial_view_pitch', viewpoint.initialViewPitch || 0);
          form.append('initial_view_fov', viewpoint.initialViewFov || 1.5708);
          form.append('scene_images', blob, `${viewpoint.name.replace(/\s+/g, '_')}.jpg`);

          const sceneResponse = await apiPost(
            `/api/scenes/properties/${propertyId}/scenes`,
            form
          );

          const sceneId = sceneResponse?.data?.scene?.id;
          if (!sceneId) {
            throw new Error(`Failed to create viewpoint: ${viewpoint.name}`);
          }

          viewpointIdMap.set(viewpoint.id, sceneId);

          if (viewpoint.isDefault && !defaultSceneId) {
            defaultSceneId = sceneId;
          }

          for (const hotspot of viewpoint.hotspots || []) {
            hotspotQueue.push({
              sourceSceneId: sceneId,
              targetLocalId: hotspot.targetViewpointId,
              yaw: hotspot.yaw,
              pitch: hotspot.pitch,
              title: hotspot.label || null,
            });
          }
        }

        if (defaultSceneId) {
          await apiPut(`/api/rooms/${roomId}/default-viewpoint`, {
            viewpoint_id: defaultSceneId,
          });
        }
      }

      for (const hotspot of hotspotQueue) {
        const targetSceneId = viewpointIdMap.get(hotspot.targetLocalId);
        if (!targetSceneId) {
          console.warn('Unable to resolve hotspot target viewpoint', hotspot);
          continue;
        }

        await apiPost(`/api/scenes/${hotspot.sourceSceneId}/hotspots`, {
          hotspot_type: 'navigation',
          target_scene_id: targetSceneId,
          yaw: hotspot.yaw,
          pitch: hotspot.pitch,
          title: hotspot.title,
        });
      }

      localStorage.setItem('jjbb_last_property_id', propertyId);
      alert('Property uploaded successfully! You can now preview it on the Property Detail page.');
      setCurrentStep(0);
    } catch (error) {
      console.error('Failed to upload property', error);
      alert(`Failed to upload property: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setRooms(normaliseRooms(SAMPLE_PROPERTY.rooms));
    setFormData(initialFormState);
    setShowResetConfirmation(false);
  };

  const steps = ['Basic Information', 'Add Rooms & Viewpoints', 'Add Navigation Hotspots', 'Review & Save'];

  const canContinueFromStep = (step) => {
    if (step === 0) {
      return Boolean(formData.title && formData.price);
    }
    if (step === 1) {
      const hasRoom = rooms.length > 0;
      const allViewpointsHaveImages = rooms.every((room) =>
        room.viewpoints.length > 0 && room.viewpoints.every((viewpoint) => viewpoint.panoramaDataUrl)
      );
      return hasRoom && allViewpointsHaveImages;
    }
    if (step === 2) {
      return rooms.some((room) => room.viewpoints.some((viewpoint) => (viewpoint.hotspots || []).length > 0));
    }
    return true;
  };

  const coverImage = extractCoverImage({ rooms });

  return (
    <div className="seller-upload-container">
      <div className="upload-header">
        <h1>Upload Property</h1>
        <div className="header-actions">
          <button
            className="help-btn"
            data-tooltip-id="general-help"
            data-tooltip-content="This wizard guides you through preparing a property with a 360° virtual tour."
          >
            ❓ Help
          </button>
          <button className="reset-btn" onClick={() => setShowResetConfirmation(true)}>
            Reset
          </button>
        </div>
        <Tooltip id="general-help" />
      </div>

      <div className="stepper">
        {steps.map((step, index) => (
          <div
            key={step}
            className={`step ${currentStep >= index ? 'active' : ''} ${currentStep === index ? 'current' : ''}`}
          >
            <div className="step-number">{index + 1}</div>
            <div className="step-label">{step}</div>
          </div>
        ))}
      </div>

      <div className="step-content">
        {currentStep === 0 && (
          <div className="basic-info-step">
            <h2>Basic Property Information</h2>
            <p className="step-intro">
              Fill in the essential information for your property. This appears on the detail page alongside the virtual tour.
            </p>

            <div className="two-column-grid">
              <div className="form-group">
                <label>Property Title *</label>
                <input
                  type="text"
                  name="title"
                  value={formData.title}
                  onChange={handleInputChange}
                  required
                />
              </div>
              <div className="form-group">
                <label>Price *</label>
                <input
                  type="number"
                  name="price"
                  value={formData.price}
                  onChange={handleInputChange}
                  min="0"
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label>Description</label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleInputChange}
                rows={4}
              />
            </div>

            <div className="two-column-grid">
              <div className="form-group">
                <label>Bedrooms</label>
                <input
                  type="number"
                  name="bedrooms"
                  value={formData.bedrooms}
                  onChange={handleInputChange}
                  min="0"
                />
              </div>
              <div className="form-group">
                <label>Bathrooms</label>
                <input
                  type="number"
                  name="bathrooms"
                  value={formData.bathrooms}
                  onChange={handleInputChange}
                  min="0"
                />
              </div>
            </div>

            <div className="two-column-grid">
              <div className="form-group">
                <label>Square Footage</label>
                <input
                  type="number"
                  name="sizeSqft"
                  value={formData.sizeSqft}
                  onChange={handleInputChange}
                  min="0"
                />
              </div>
              <div className="form-checkbox">
                <label>
                  <input
                    type="checkbox"
                    name="furnished"
                    checked={!!formData.furnished}
                    onChange={handleInputChange}
                  />
                  Furnished
                </label>
              </div>
            </div>

            <div className="address-grid">
              <div className="form-group">
                <label>Address Line</label>
                <input
                  type="text"
                  name="addressLine"
                  value={formData.addressLine}
                  onChange={handleInputChange}
                />
              </div>
              <div className="form-group">
                <label>City</label>
                <input
                  type="text"
                  name="city"
                  value={formData.city}
                  onChange={handleInputChange}
                />
              </div>
              <div className="form-group">
                <label>State/Region</label>
                <input
                  type="text"
                  name="state"
                  value={formData.state}
                  onChange={handleInputChange}
                />
              </div>
              <div className="form-group">
                <label>Country</label>
                <input
                  type="text"
                  name="country"
                  value={formData.country}
                  onChange={handleInputChange}
                />
              </div>
              <div className="form-group">
                <label>Postal Code</label>
                <input
                  type="text"
                  name="postalCode"
                  value={formData.postalCode}
                  onChange={handleInputChange}
                />
              </div>
            </div>
          </div>
        )}

        {currentStep === 1 && (
          <RoomViewpointEditor rooms={rooms} onRoomsChange={setRooms} />
        )}

        {currentStep === 2 && (
          <HotspotEditor rooms={rooms} onRoomsChange={setRooms} />
        )}

        {currentStep === 3 && (
          <div className="review-step">
            <h2>Review & Save</h2>
            <p className="step-intro">
              Review the property information and ensure the rooms, viewpoints, and hotspots look correct.
            </p>

            <div className="review-grid">
              <div className="review-card">
                <img src={coverImage} alt="Cover" className="review-cover" />
                <div className="review-info">
                  <h3>{formData.title || 'Untitled Property'}</h3>
                  <p>{formData.description}</p>
                  <div className="review-stats">
                    <span>💲 {Number(formData.price || 0).toLocaleString()}</span>
                    <span>🛏️ {formData.bedrooms || 0}</span>
                    <span>🛁 {formData.bathrooms || 0}</span>
                    <span>📐 {formData.sizeSqft || 0} sqft</span>
                  </div>
                </div>
              </div>

              <div className="review-rooms">
                <h3>Rooms & Viewpoints</h3>
                {rooms.map((room) => (
                  <div key={room.id} className="review-room">
                    <h4>{room.name}</h4>
                    <ul>
                      {room.viewpoints.map((viewpoint) => (
                        <li key={viewpoint.id}>
                          <strong>{viewpoint.name}</strong>
                          {viewpoint.isDefault && <span className="chip-badge">Default</span>}
                          <span className="review-hotspot-count">
                            {(viewpoint.hotspots || []).length} hotspots
                          </span>
                        </li>
                      ))}
                    </ul>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      <div className="step-footer">
        <button className="btn-secondary" onClick={goToPrevStep} disabled={currentStep === 0}>
          ← Back
        </button>
        {currentStep < steps.length - 1 ? (
          <button
            className="btn-primary"
            onClick={goToNextStep}
            disabled={!canContinueFromStep(currentStep)}
          >
            Next →
          </button>
        ) : (
          <button className="btn-primary" onClick={handleSave} disabled={loading}>
            {loading ? 'Saving…' : 'Save Property'}
          </button>
        )}
      </div>

      {showResetConfirmation && (
        <div className="hotspot-modal" role="dialog" aria-modal="true">
          <div className="hotspot-modal-content">
            <h3>Reset wizard?</h3>
            <p>All progress will be lost and replaced with the default demo property.</p>
            <div className="modal-options">
              <button type="button" className="modal-option" onClick={handleReset}>
                <strong>Reset Now</strong>
                <span>This will clear stored property data.</span>
              </button>
            </div>
            <button type="button" className="cancel-button" onClick={() => setShowResetConfirmation(false)}>
              Cancel
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default SellerUpload;
