import React, { useState, useEffect } from 'react';
import axios from 'axios';
import '../styles/PropertyDetail.css';

/**
 * Property Detail Component (PRIORITY-1)
 * Displays property details with 360° virtual tour using Marzipano
 */
const PropertyDetail = () => {
  const [property, setProperty] = useState(null);
  const [scenes, setScenes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [show360Tour, setShow360Tour] = useState(false);

  // Test property ID - simple 3-scene tour
  const propertyId = '762f8ee2-c205-4061-af76-3e2b20fae106';
  const API_BASE_URL = 'http://localhost:3001';

  useEffect(() => {
    loadPropertyDetails();
  }, []);

  const loadPropertyDetails = async () => {
    try {
      setLoading(true);
      
      // In production, these would be actual API calls
      // For demo, using mock data
      const mockProperty = {
        id: '1',
        title: 'Modern 3BR Apartment in Downtown',
        description: 'Beautiful modern apartment with stunning city views. Features include hardwood floors, stainless steel appliances, and floor-to-ceiling windows.',
        price: 450000,
        bedrooms: 3,
        bathrooms: 2,
        sizeSqft: 1500,
        address: '123 Main Street, New York, NY 10001',
        furnished: true,
        propertyType: 'buy',
        averageRating: 4.5,
        totalReviews: 12,
        sellerName: 'Premium Real Estate Co.',
        sellerEmail: 'contact@premiumrealty.com',
        images: [
          '/api/placeholder/800/600',
          '/api/placeholder/800/600',
        ],
        tags: ['Modern', 'Downtown', 'Parking', 'Gym'],
      };

      const mockScenes = [
        { id: '1', name: 'Living Room', order: 0 },
        { id: '2', name: 'Kitchen', order: 1 },
        { id: '3', name: 'Master Bedroom', order: 2 },
      ];

      setProperty(mockProperty);
      setScenes(mockScenes);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const openGoogleMaps = () => {
    const mapsUrl = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(property.address)}`;
    window.open(mapsUrl, '_blank');
  };

  const copyAddress = () => {
    navigator.clipboard.writeText(property.address);
    alert('Address copied to clipboard!');
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner"></div>
        <p>Loading property details...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="error-container">
        <h2>⚠️ Error</h2>
        <p>{error}</p>
        <button onClick={loadPropertyDetails}>Retry</button>
      </div>
    );
  }

  if (!property) {
    return <div className="error-container">Property not found</div>;
  }

  return (
    <div className="property-detail-container">
      {/* 360° Virtual Tour Modal */}
      {show360Tour && (
        <div className="tour-modal">
          <div className="tour-modal-content">
            <button className="close-btn" onClick={() => setShow360Tour(false)}>
              ✕
            </button>
            <h2>360° Virtual Tour - {property.title}</h2>
            <div className="tour-viewer">
              <iframe
                src={`${API_BASE_URL}/viewer?propertyId=${propertyId}`}
                title="360° Virtual Tour"
                width="100%"
                height="100%"
                frameBorder="0"
                allowFullScreen
              ></iframe>
            </div>
            <div className="tour-controls">
              <span>🖱️ Drag to rotate</span>
              <span>🔍 Scroll to zoom</span>
              <span>👆 Click arrows to navigate</span>
            </div>
          </div>
        </div>
      )}

      {/* Property Images */}
      <div className="property-images">
        <div className="main-image">
          <img src={property.images[0]} alt={property.title} />
        </div>
      </div>

      {/* 360 Tour Button */}
      {scenes.length > 0 && (
        <div className="tour-button-container">
          <button className="tour-button" onClick={() => setShow360Tour(true)}>
            🌐 View 360° Virtual Tour
          </button>
        </div>
      )}

      {/* Property Info */}
      <div className="property-info">
        <div className="property-header">
          <div>
            <h1>{property.title}</h1>
            <p className="address">📍 {property.address}</p>
          </div>
          <div className="price">${property.price.toLocaleString()}</div>
        </div>

        <div className="property-stats">
          <div className="stat">
            <span className="stat-icon">🛏️</span>
            <span>{property.bedrooms} Beds</span>
          </div>
          <div className="stat">
            <span className="stat-icon">🚿</span>
            <span>{property.bathrooms} Baths</span>
          </div>
          <div className="stat">
            <span className="stat-icon">📐</span>
            <span>{property.sizeSqft} sqft</span>
          </div>
          <div className="stat">
            <span className="stat-icon">⭐</span>
            <span>{property.averageRating} ({property.totalReviews} reviews)</span>
          </div>
        </div>

        {/* Tabs */}
        <div className="tabs">
          <div className="tab-content">
            <h3>Description</h3>
            <p>{property.description}</p>

            <h3>Features</h3>
            <div className="features">
              {property.tags.map((tag, index) => (
                <span key={index} className="feature-tag">{tag}</span>
              ))}
              <span className="feature-tag">
                {property.furnished ? 'Furnished' : 'Unfurnished'}
              </span>
            </div>

            <h3>Location</h3>
            <p>{property.address}</p>
            <div className="location-actions">
              <button className="btn-secondary" onClick={openGoogleMaps}>
                🗺️ Open in Google Maps
              </button>
              <button className="btn-secondary" onClick={copyAddress}>
                📋 Copy Address
              </button>
            </div>

            <h3>Seller Information</h3>
            <div className="seller-info">
              <p><strong>{property.sellerName}</strong></p>
              <p>{property.sellerEmail}</p>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="action-buttons">
          <button className="btn-primary">📞 Contact Seller</button>
          <button className="btn-primary">📅 Schedule Visit</button>
        </div>
      </div>
    </div>
  );
};

export default PropertyDetail;

