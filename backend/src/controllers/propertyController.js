const pool = require('../config/database');
const path = require('path');
const fs = require('fs').promises;

/**
 * @route   GET /api/properties
 * @desc    Get all properties with filters
 * @access  Public
 */
const getAllProperties = async (req, res) => {
  try {
    const {
      search,
      property_type,
      min_price,
      max_price,
      min_size,
      max_size,
      bedrooms,
      bathrooms,
      furnished,
      tags,
      latitude,
      longitude,
      radius, // in kilometers
      sort_by,
      page = 1,
      limit = 20
    } = req.query;

    let query = `
      SELECT DISTINCT p.*,
             u.full_name as seller_name,
             u.company_name,
             u.email as seller_email,
             (SELECT json_agg(pi ORDER BY pi.image_order)
              FROM property_images pi
              WHERE pi.property_id = p.id) as images,
             (SELECT json_agg(DISTINCT pt.tag_name)
              FROM property_tags pt
              WHERE pt.property_id = p.id) as tags
      FROM properties p
      LEFT JOIN users u ON p.seller_id = u.id
      WHERE p.status = 'available'
    `;

    const params = [];
    let paramIndex = 1;

    // Search filter
    if (search) {
      query += ` AND (p.title ILIKE $${paramIndex} OR p.description ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    // Property type filter
    if (property_type) {
      query += ` AND p.property_type = $${paramIndex}`;
      params.push(property_type);
      paramIndex++;
    }

    // Price filters
    if (min_price) {
      query += ` AND p.price >= $${paramIndex}`;
      params.push(min_price);
      paramIndex++;
    }
    if (max_price) {
      query += ` AND p.price <= $${paramIndex}`;
      params.push(max_price);
      paramIndex++;
    }

    // Size filters
    if (min_size) {
      query += ` AND p.size_sqft >= $${paramIndex}`;
      params.push(min_size);
      paramIndex++;
    }
    if (max_size) {
      query += ` AND p.size_sqft <= $${paramIndex}`;
      params.push(max_size);
      paramIndex++;
    }

    // Bedrooms filter
    if (bedrooms) {
      query += ` AND p.bedrooms >= $${paramIndex}`;
      params.push(bedrooms);
      paramIndex++;
    }

    // Bathrooms filter
    if (bathrooms) {
      query += ` AND p.bathrooms >= $${paramIndex}`;
      params.push(bathrooms);
      paramIndex++;
    }

    // Furnished filter
    if (furnished !== undefined) {
      query += ` AND p.furnished = $${paramIndex}`;
      params.push(furnished === 'true');
      paramIndex++;
    }

    // Tags filter
    if (tags) {
      const tagArray = tags.split(',');
      query += ` AND EXISTS (
        SELECT 1 FROM property_tags pt
        WHERE pt.property_id = p.id AND pt.tag_name = ANY($${paramIndex})
      )`;
      params.push(tagArray);
      paramIndex++;
    }

    // Location-based search (using Haversine formula for distance)
    if (latitude && longitude && radius) {
      query += ` AND (
        6371 * acos(
          cos(radians($${paramIndex})) * cos(radians(p.latitude)) *
          cos(radians(p.longitude) - radians($${paramIndex + 1})) +
          sin(radians($${paramIndex})) * sin(radians(p.latitude))
        )
      ) <= $${paramIndex + 2}`;
      params.push(parseFloat(latitude), parseFloat(longitude), parseFloat(radius));
      paramIndex += 3;
    }

    // Sorting
    const sortOptions = {
      'price_asc': 'p.price ASC',
      'price_desc': 'p.price DESC',
      'rating': 'p.average_rating DESC',
      'newest': 'p.created_at DESC',
      'size_asc': 'p.size_sqft ASC',
      'size_desc': 'p.size_sqft DESC'
    };
    query += ` ORDER BY ${sortOptions[sort_by] || 'p.created_at DESC'}`;

    // Pagination
    const offset = (page - 1) * limit;
    query += ` LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    // Get total count for pagination
    let countQuery = `SELECT COUNT(DISTINCT p.id) FROM properties p WHERE p.status = 'available'`;
    const countResult = await pool.query(countQuery);
    const total = parseInt(countResult.rows[0].count);

    res.status(200).json({
      success: true,
      data: {
        properties: result.rows,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get properties error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching properties'
    });
  }
};

/**
 * @route   GET /api/properties/:id
 * @desc    Get single property by ID with full details including 360 scenes
 * @access  Public
 */
const getPropertyById = async (req, res) => {
  try {
    const { id } = req.params;

    // Get property details
    const propertyResult = await pool.query(
      `SELECT p.*,
              u.full_name as seller_name,
              u.company_name,
              u.email as seller_email,
              u.phone as seller_phone
       FROM properties p
       LEFT JOIN users u ON p.seller_id = u.id
       WHERE p.id = $1`,
      [id]
    );

    if (propertyResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Property not found'
      });
    }

    const property = propertyResult.rows[0];

    // Get property images
    const imagesResult = await pool.query(
      `SELECT * FROM property_images WHERE property_id = $1 ORDER BY image_order`,
      [id]
    );

    // Get tags
    const tagsResult = await pool.query(
      `SELECT tag_name FROM property_tags WHERE property_id = $1`,
      [id]
    );

    // Get reviews
    const reviewsResult = await pool.query(
      `SELECT r.*, u.full_name as reviewer_name
       FROM reviews r
       LEFT JOIN users u ON r.buyer_id = u.id
       WHERE r.property_id = $1
       ORDER BY r.created_at DESC`,
      [id]
    );

    // Increment view count
    await pool.query(
      `UPDATE properties SET views_count = views_count + 1 WHERE id = $1`,
      [id]
    );

    property.images = imagesResult.rows;
    property.tags = tagsResult.rows.map(t => t.tag_name);
    property.reviews = reviewsResult.rows;

    res.status(200).json({
      success: true,
      data: { property }
    });
  } catch (error) {
    console.error('Get property error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching property'
    });
  }
};

/**
 * @route   POST /api/properties
 * @desc    Create a new property
 * @access  Private (Seller only)
 */
const createProperty = async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    const {
      title,
      description,
      property_type,
      price,
      size_sqft,
      bedrooms,
      bathrooms,
      furnished,
      address_line,
      city,
      state,
      country,
      postal_code,
      latitude,
      longitude,
      google_maps_url,
      tags
    } = req.body;

    const seller_id = req.user.id;

    // Insert property
    const propertyResult = await client.query(
      `INSERT INTO properties (
        seller_id, title, description, property_type, price, size_sqft,
        bedrooms, bathrooms, furnished, address_line, city, state, country,
        postal_code, latitude, longitude, google_maps_url
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)
      RETURNING *`,
      [
        seller_id, title, description, property_type, parseFloat(price),
        parseFloat(size_sqft) || null, parseInt(bedrooms) || null,
        parseInt(bathrooms) || null, furnished === 'true' || furnished === true,
        address_line, city, state || null, country, postal_code || null,
        parseFloat(latitude) || null, parseFloat(longitude) || null,
        google_maps_url || null
      ]
    );

    const property = propertyResult.rows[0];

    // Insert tags if provided
    if (tags && Array.isArray(tags)) {
      for (const tag of tags) {
        await client.query(
          `INSERT INTO property_tags (property_id, tag_name) VALUES ($1, $2)`,
          [property.id, tag]
        );
      }
    }

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Property created successfully',
      data: { property }
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Create property error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating property'
    });
  } finally {
    client.release();
  }
};

/**
 * @route   PUT /api/properties/:id
 * @desc    Update property
 * @access  Private (Seller - own properties only)
 */
const updateProperty = async (req, res) => {
  try {
    const { id } = req.params;
    const seller_id = req.user.id;

    // Check if property exists and belongs to seller
    const checkResult = await pool.query(
      'SELECT id FROM properties WHERE id = $1 AND seller_id = $2',
      [id, seller_id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Property not found or you do not have permission to update it'
      });
    }

    const {
      title,
      description,
      property_type,
      price,
      size_sqft,
      bedrooms,
      bathrooms,
      furnished,
      address_line,
      city,
      state,
      country,
      postal_code,
      latitude,
      longitude,
      google_maps_url,
      status
    } = req.body;

    const result = await pool.query(
      `UPDATE properties SET
        title = COALESCE($1, title),
        description = COALESCE($2, description),
        property_type = COALESCE($3, property_type),
        price = COALESCE($4, price),
        size_sqft = COALESCE($5, size_sqft),
        bedrooms = COALESCE($6, bedrooms),
        bathrooms = COALESCE($7, bathrooms),
        furnished = COALESCE($8, furnished),
        address_line = COALESCE($9, address_line),
        city = COALESCE($10, city),
        state = COALESCE($11, state),
        country = COALESCE($12, country),
        postal_code = COALESCE($13, postal_code),
        latitude = COALESCE($14, latitude),
        longitude = COALESCE($15, longitude),
        google_maps_url = COALESCE($16, google_maps_url),
        status = COALESCE($17, status),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $18
      RETURNING *`,
      [
        title, description, property_type, price, size_sqft, bedrooms,
        bathrooms, furnished, address_line, city, state, country,
        postal_code, latitude, longitude, google_maps_url, status, id
      ]
    );

    res.status(200).json({
      success: true,
      message: 'Property updated successfully',
      data: { property: result.rows[0] }
    });
  } catch (error) {
    console.error('Update property error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating property'
    });
  }
};

/**
 * @route   DELETE /api/properties/:id
 * @desc    Delete property
 * @access  Private (Seller - own properties only, or Admin)
 */
const deleteProperty = async (req, res) => {
  try {
    const { id } = req.params;
    const user_id = req.user.id;
    const user_type = req.user.user_type;

    // Check if property exists
    const checkResult = await pool.query(
      'SELECT id, seller_id FROM properties WHERE id = $1',
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Property not found'
      });
    }

    const property = checkResult.rows[0];

    // Check permission (seller must own property, or user must be admin)
    if (property.seller_id !== user_id && user_type !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to delete this property'
      });
    }

    // Delete property (CASCADE will handle related records)
    await pool.query('DELETE FROM properties WHERE id = $1', [id]);

    res.status(200).json({
      success: true,
      message: 'Property deleted successfully'
    });
  } catch (error) {
    console.error('Delete property error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting property'
    });
  }
};

module.exports = {
  getAllProperties,
  getPropertyById,
  createProperty,
  updateProperty,
  deleteProperty
};

