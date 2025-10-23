import React, { useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { Tooltip } from 'react-tooltip';
import HotspotEditor from './HotspotEditor';
import RoomViewpointEditor from './RoomViewpointEditor';
import '../styles/SellerUpload.css';

/**
 * Seller Upload Component (PRIORITY-1)
 * Allows sellers to upload properties with 360° images
 * Includes tooltips and helpful hints
 */
const SellerUpload = () => {
  const [currentStep, setCurrentStep] = useState(0);
  const [loading, setLoading] = useState(false);

  // Form state
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    propertyType: 'buy',
    price: '',
    bedrooms: '',
    bathrooms: '',
    sizeSqft: '',
    furnished: false,
    addressLine: '',
    city: '',
    state: '',
    country: '',
    postalCode: '',
    tags: [],
  });

  const [scenes, setScenes] = useState([]);
  const [rooms, setRooms] = useState([]); // NEW: Rooms with viewpoints

  const handleInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const addScene = () => {
    setScenes([...scenes, {
      id: Date.now(),
      name: `Room ${scenes.length + 1}`,
      images: [],
      hotspots: [] // Add hotspots array for each scene
    }]);
  };

  const removeScene = (sceneId) => {
    setScenes(scenes.filter(s => s.id !== sceneId));
  };

  const handleHotspotsChange = (sceneId, hotspots) => {
    setScenes(scenes.map(s => 
      s.id === sceneId ? { ...s, hotspots } : s
    ));
  };

  const updateSceneName = (sceneId, name) => {
    setScenes(scenes.map(s => 
      s.id === sceneId ? { ...s, name } : s
    ));
  };

  const handleSceneImages = (sceneId, files) => {
    setScenes(scenes.map(s => 
      s.id === sceneId ? { ...s, images: [...s.images, ...files] } : s
    ));
  };

  const removeSceneImage = (sceneId, imageIndex) => {
    setScenes(scenes.map(s => {
      if (s.id === sceneId) {
        const newImages = [...s.images];
        newImages.splice(imageIndex, 1);
        return { ...s, images: newImages };
      }
      return s;
    }));
  };

  const handleSubmit = async () => {
    setLoading(true);

    try {
      // In production, this would upload to the backend
      console.log('Property Data:', formData);
      console.log('360° Scenes:', scenes);

      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));

      alert('Property uploaded successfully!');
      
      // Reset form
      setFormData({
        title: '',
        description: '',
        propertyType: 'buy',
        price: '',
        bedrooms: '',
        bathrooms: '',
        sizeSqft: '',
        furnished: false,
        addressLine: '',
        city: '',
        state: '',
        country: '',
        postalCode: '',
        tags: [],
      });
      setScenes([]);
      setCurrentStep(0);
    } catch (error) {
      alert('Error uploading property: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const steps = ['Basic Information', 'Add Rooms & Viewpoints', 'Add Hotspots', 'Review & Submit'];

  return (
    <div className="seller-upload-container">
      <div className="upload-header">
        <h1>Upload Property</h1>
        <button 
          className="help-btn"
          data-tooltip-id="general-help"
          data-tooltip-content="This wizard will guide you through uploading your property with 360° virtual tour"
        >
          ❓ Help
        </button>
        <Tooltip id="general-help" />
      </div>

      {/* Progress Steps */}
      <div className="stepper">
        {steps.map((step, index) => (
          <div 
            key={index} 
            className={`step ${currentStep >= index ? 'active' : ''} ${currentStep === index ? 'current' : ''}`}
          >
            <div className="step-number">{index + 1}</div>
            <div className="step-label">{step}</div>
          </div>
        ))}
      </div>

      {/* Step Content */}
      <div className="step-content">
        {currentStep === 0 && (
          <div className="basic-info-step">
            <h2>Basic Property Information</h2>

            <div className="form-group">
              <label>
                Property Title *
                <span 
                  className="info-icon"
                  data-tooltip-id="title-tooltip"
                  data-tooltip-content="Enter an attractive, descriptive title for your property"
                >
                  ℹ️
                </span>
              </label>
              <input
                type="text"
                name="title"
                value={formData.title}
                onChange={handleInputChange}
                placeholder="e.g., Modern 3BR Apartment in Downtown"
                required
              />
              <Tooltip id="title-tooltip" />
            </div>

            <div className="form-group">
              <label>Description</label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleInputChange}
                placeholder="Describe your property features and amenities..."
                rows={4}
              />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Type *</label>
                <select
                  name="propertyType"
                  value={formData.propertyType}
                  onChange={handleInputChange}
                >
                  <option value="buy">For Sale</option>
                  <option value="rent">For Rent</option>
                </select>
              </div>

              <div className="form-group">
                <label>
                  Price (USD) *
                  <span 
                    className="info-icon"
                    data-tooltip-id="price-tooltip"
                    data-tooltip-content="Enter the price in USD"
                  >
                    ℹ️
                  </span>
                </label>
                <input
                  type="number"
                  name="price"
                  value={formData.price}
                  onChange={handleInputChange}
                  placeholder="450000"
                  required
                />
                <Tooltip id="price-tooltip" />
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Bedrooms</label>
                <input
                  type="number"
                  name="bedrooms"
                  value={formData.bedrooms}
                  onChange={handleInputChange}
                  placeholder="3"
                />
              </div>

              <div className="form-group">
                <label>Bathrooms</label>
                <input
                  type="number"
                  name="bathrooms"
                  value={formData.bathrooms}
                  onChange={handleInputChange}
                  placeholder="2"
                />
              </div>

              <div className="form-group">
                <label>Size (sqft)</label>
                <input
                  type="number"
                  name="sizeSqft"
                  value={formData.sizeSqft}
                  onChange={handleInputChange}
                  placeholder="1500"
                />
              </div>
            </div>

            <div className="form-group checkbox-group">
              <label>
                <input
                  type="checkbox"
                  name="furnished"
                  checked={formData.furnished}
                  onChange={handleInputChange}
                />
                <span>Furnished</span>
              </label>
            </div>

            <h3>Address</h3>

            <div className="form-group">
              <label>Street Address *</label>
              <input
                type="text"
                name="addressLine"
                value={formData.addressLine}
                onChange={handleInputChange}
                placeholder="123 Main Street"
                required
              />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>City *</label>
                <input
                  type="text"
                  name="city"
                  value={formData.city}
                  onChange={handleInputChange}
                  placeholder="New York"
                  required
                />
              </div>

              <div className="form-group">
                <label>State/Province</label>
                <input
                  type="text"
                  name="state"
                  value={formData.state}
                  onChange={handleInputChange}
                  placeholder="NY"
                />
              </div>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>Country *</label>
                <input
                  type="text"
                  name="country"
                  value={formData.country}
                  onChange={handleInputChange}
                  placeholder="USA"
                  required
                />
              </div>

              <div className="form-group">
                <label>Postal Code</label>
                <input
                  type="text"
                  name="postalCode"
                  value={formData.postalCode}
                  onChange={handleInputChange}
                  placeholder="10001"
                />
              </div>
            </div>
          </div>
        )}

        {currentStep === 1 && (
          <div className="rooms-viewpoints-step">
            <RoomViewpointEditor 
              rooms={rooms}
              onRoomsChange={setRooms}
            />
          </div>
        )}

        {currentStep === 2 && (
          <div className="tour-step">
            <h2>360° Virtual Tour (Legacy - Optional)</h2>

            <div className="info-box">
              <strong>📸 360° Tour Instructions</strong>
              <p>
                This step is optional if you've added rooms and viewpoints in the previous step.
                Upload panoramic 360° images for each room. These should be equirectangular format images.
                Buyers can navigate between rooms using interactive hotspots!
              </p>
            </div>

            {scenes.map((scene, index) => (
              <SceneCard
                key={scene.id}
                scene={scene}
                index={index}
                onRemove={() => removeScene(scene.id)}
                onNameChange={(name) => updateSceneName(scene.id, name)}
                onImagesAdd={(files) => handleSceneImages(scene.id, files)}
                onImageRemove={(imgIndex) => removeSceneImage(scene.id, imgIndex)}
              />
            ))}

            <button className="add-scene-btn" onClick={addScene}>
              ➕ Add Another Room/Scene
            </button>
          </div>
        )}

        {currentStep === 3 && (
          <div className="hotspots-step">
            <h2>Add Navigation Hotspots</h2>
            
            <div className="info-box">
              <strong>🎯 Connect Your Rooms</strong>
              <p>
                Add navigation arrows on doors and passages so visitors can walk through your property naturally.
                This creates an immersive experience where clicking on a door takes you to the next room!
              </p>
            </div>

            {rooms.length === 0 && scenes.length === 0 ? (
              <div className="no-scenes-message">
                <p>📸 Please add rooms in the previous step before adding hotspots.</p>
                <button 
                  className="btn-secondary"
                  onClick={() => setCurrentStep(1)}
                >
                  ← Go Back to Add Rooms
                </button>
              </div>
            ) : (
              <>
                {scenes.map((scene, index) => (
                  <HotspotEditor
                    key={scene.id}
                    scene={scene}
                    allScenes={scenes}
                    onHotspotsChange={(hotspots) => handleHotspotsChange(scene.id, hotspots)}
                  />
                ))}
                
                {scenes.length < 2 && (
                  <div className="tip-box">
                    💡 <strong>Tip:</strong> You need at least 2 rooms to create navigation hotspots between them.
                    Add more rooms in the previous step!
                  </div>
                )}
              </>
            )}
          </div>
        )}

        {currentStep === 4 && (
          <div className="review-step">
            <h2>Review Your Property</h2>

            <div className="review-section">
              <h3>Property Details</h3>
              <div className="review-item">
                <strong>Title:</strong> {formData.title || 'Not provided'}
              </div>
              <div className="review-item">
                <strong>Type:</strong> {formData.propertyType === 'buy' ? 'For Sale' : 'For Rent'}
              </div>
              <div className="review-item">
                <strong>Price:</strong> ${formData.price || '0'}
              </div>
              <div className="review-item">
                <strong>Address:</strong> {formData.addressLine || 'Not provided'}
              </div>
              <div className="review-item">
                <strong>City:</strong> {formData.city || 'Not provided'}
              </div>
            </div>

            <div className="review-section">
              <h3>360° Virtual Tour</h3>
              {rooms.length > 0 ? (
                <>
                  <div className="review-item">
                    <strong>Rooms:</strong> {rooms.length} room(s)
                  </div>
                  {rooms.map((room, index) => (
                    <div key={room.id} className="review-item">
                      <strong>{room.name}:</strong> {room.viewpoints?.length || 0} viewpoint(s)
                      {room.viewpoints && room.viewpoints.map((vp, vpIndex) => (
                        <div key={vp.id} style={{ marginLeft: '20px', fontSize: '0.9em' }}>
                          → {vp.name}: {vp.images?.length || 0} image(s) {vp.isDefault && '⭐ (Default)'}
                        </div>
                      ))}
                    </div>
                  ))}
                </>
              ) : scenes.length > 0 ? (
                <>
                  <div className="review-item">
                    <strong>Scenes (Legacy):</strong> {scenes.length} scene(s)
                  </div>
                  {scenes.map((scene, index) => (
                    <div key={scene.id} className="review-item">
                      <strong>Scene {index + 1}:</strong> {scene.name} ({scene.images.length} image(s), {scene.hotspots?.length || 0} hotspot(s))
                    </div>
                  ))}
                </>
              ) : (
                <div className="review-item">
                  <strong>No rooms or scenes added</strong>
                </div>
              )}
            </div>

            <button 
              className="submit-btn" 
              onClick={handleSubmit}
              disabled={loading}
            >
              {loading ? '⏳ Uploading...' : '✅ Submit Property'}
            </button>
          </div>
        )}
      </div>

      {/* Navigation Buttons */}
      <div className="step-navigation">
        {currentStep > 0 && (
          <button 
            className="btn-secondary"
            onClick={() => setCurrentStep(currentStep - 1)}
          >
            ← Previous
          </button>
        )}
        
        {currentStep < steps.length - 1 && (
          <button 
            className="btn-primary"
            onClick={() => setCurrentStep(currentStep + 1)}
          >
            Next →
          </button>
        )}
      </div>
    </div>
  );
};

// Scene Card Component
const SceneCard = ({ scene, index, onRemove, onNameChange, onImagesAdd, onImageRemove }) => {
  const { getRootProps, getInputProps } = useDropzone({
    accept: {'image/*': []},
    onDrop: onImagesAdd
  });

  return (
    <div className="scene-card">
      <div className="scene-header">
        <div className="scene-number">{index + 1}</div>
        <input
          type="text"
          className="scene-name-input"
          value={scene.name}
          onChange={(e) => onNameChange(e.target.value)}
          placeholder="Room name (e.g., Living Room)"
        />
        <button className="remove-scene-btn" onClick={onRemove}>
          🗑️
        </button>
      </div>

      <div className="tip-box">
        💡 Upload 360° panoramic images (equirectangular format) for best results
      </div>

      {scene.images.length > 0 && (
        <div className="images-grid">
          {scene.images.map((img, imgIndex) => (
            <div key={imgIndex} className="image-preview">
              <img src={URL.createObjectURL(img)} alt={`Scene ${imgIndex}`} />
              <button 
                className="remove-image-btn"
                onClick={() => onImageRemove(imgIndex)}
              >
                ✕
              </button>
            </div>
          ))}
        </div>
      )}

      <div {...getRootProps({ className: 'dropzone' })}>
        <input {...getInputProps()} />
        <p>📤 {scene.images.length === 0 ? 'Upload 360° Images' : 'Add More Images'}</p>
        <small>Drag & drop or click to select files</small>
      </div>

      {scene.images.length > 0 && (
        <div className="image-count">
          ✓ {scene.images.length} image(s) uploaded
        </div>
      )}
    </div>
  );
};

export default SellerUpload;
