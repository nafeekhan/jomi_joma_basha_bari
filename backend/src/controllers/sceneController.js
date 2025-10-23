const pool = require('../config/database');
const path = require('path');
const fs = require('fs').promises;

/**
 * @route   GET /api/properties/:propertyId/scenes
 * @desc    Get all scenes for a property (for lazy loading)
 * @access  Public
 */
const getPropertyScenes = async (req, res) => {
  try {
    const { propertyId } = req.params;

    // Get scenes with basic info and room information (no images yet for lazy loading)
    const result = await pool.query(
      `SELECT s.id, s.scene_name, s.viewpoint_name, s.scene_order, s.room_id,
              s.is_default_viewpoint, s.initial_view_yaw, s.initial_view_pitch, s.initial_view_fov,
              r.room_name, r.room_order
       FROM scenes s
       LEFT JOIN rooms r ON s.room_id = r.id
       WHERE s.property_id = $1
       ORDER BY r.room_order ASC NULLS LAST, s.scene_order ASC`,
      [propertyId]
    );

    res.status(200).json({
      success: true,
      data: { scenes: result.rows }
    });
  } catch (error) {
    console.error('Get scenes error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching scenes'
    });
  }
};

/**
 * @route   GET /api/scenes/:sceneId
 * @desc    Get single scene with images and hotspots (lazy loaded)
 * @access  Public
 */
const getSceneById = async (req, res) => {
  try {
    const { sceneId } = req.params;

    // Get scene details with room information
    const sceneResult = await pool.query(
      `SELECT s.*, p.id as property_id, r.room_name, r.id as room_id
       FROM scenes s
       LEFT JOIN properties p ON s.property_id = p.id
       LEFT JOIN rooms r ON s.room_id = r.id
       WHERE s.id = $1`,
      [sceneId]
    );

    if (sceneResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Scene not found'
      });
    }

    const scene = sceneResult.rows[0];

    // Get scene images
    const imagesResult = await pool.query(
      `SELECT id, image_type, resolution_level, face, tile_x, tile_y, file_path
       FROM scene_images
       WHERE scene_id = $1
       ORDER BY resolution_level, face, tile_y, tile_x`,
      [sceneId]
    );

    // Get hotspots
    const hotspotsResult = await pool.query(
      `SELECT h.*, ts.scene_name as target_scene_name
       FROM hotspots h
       LEFT JOIN scenes ts ON h.target_scene_id = ts.id
       WHERE h.scene_id = $1`,
      [sceneId]
    );

    scene.images = imagesResult.rows;
    scene.hotspots = hotspotsResult.rows;

    res.status(200).json({
      success: true,
      data: { scene }
    });
  } catch (error) {
    console.error('Get scene error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching scene'
    });
  }
};

/**
 * @route   POST /api/properties/:propertyId/scenes
 * @desc    Create a new scene for a property
 * @access  Private (Seller only - must own property)
 */
const createScene = async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    const { propertyId } = req.params;
    const { 
      scene_name, 
      scene_order, 
      room_id, 
      viewpoint_name,
      is_default_viewpoint,
      initial_view_yaw, 
      initial_view_pitch, 
      initial_view_fov 
    } = req.body;

    // Check if property exists and belongs to seller
    const propertyCheck = await client.query(
      'SELECT id FROM properties WHERE id = $1 AND seller_id = $2',
      [propertyId, req.user.id]
    );

    if (propertyCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Property not found or you do not have permission'
      });
    }

    // Insert scene (viewpoint)
    const sceneResult = await client.query(
      `INSERT INTO scenes (
        property_id, 
        room_id,
        scene_name, 
        viewpoint_name,
        scene_order, 
        is_default_viewpoint,
        initial_view_yaw, 
        initial_view_pitch, 
        initial_view_fov
      )
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [
        propertyId,
        room_id || null,
        scene_name,
        viewpoint_name || 'Main View',
        parseInt(scene_order),
        is_default_viewpoint || false,
        parseFloat(initial_view_yaw) || 0,
        parseFloat(initial_view_pitch) || 0,
        parseFloat(initial_view_fov) || 1.5708
      ]
    );

    const scene = sceneResult.rows[0];

    // Handle uploaded images if any
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        // Parse metadata from filename or request
        const image_type = req.body.image_type || 'tile';
        const resolution_level = parseInt(req.body.resolution_level) || 0;
        const face = req.body.face || 'f';

        await client.query(
          `INSERT INTO scene_images (scene_id, image_type, resolution_level, face, file_path, file_size)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [scene.id, image_type, resolution_level, face, file.path, file.size]
        );
      }
    }

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Scene created successfully',
      data: { scene }
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Create scene error:', error);
    console.error('Error details:', error.message);
    console.error('Error stack:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Server error while creating scene',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  } finally {
    client.release();
  }
};

/**
 * @route   POST /api/scenes/:sceneId/images
 * @desc    Upload images for a scene (360 tiles)
 * @access  Private (Seller only)
 */
const uploadSceneImages = async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    const { sceneId } = req.params;
    const { image_type, resolution_level, face, tile_x, tile_y } = req.body;

    // Check if scene exists and user has permission
    const sceneCheck = await client.query(
      `SELECT s.id FROM scenes s
       LEFT JOIN properties p ON s.property_id = p.id
       WHERE s.id = $1 AND p.seller_id = $2`,
      [sceneId, req.user.id]
    );

    if (sceneCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Scene not found or you do not have permission'
      });
    }

    // Handle uploaded files
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No images uploaded'
      });
    }

    const uploadedImages = [];

    for (const file of req.files) {
      const imageResult = await client.query(
        `INSERT INTO scene_images (scene_id, image_type, resolution_level, face, tile_x, tile_y, file_path, file_size)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING *`,
        [
          sceneId,
          image_type || 'tile',
          parseInt(resolution_level) || 0,
          face || null,
          parseInt(tile_x) || null,
          parseInt(tile_y) || null,
          file.path,
          file.size
        ]
      );

      uploadedImages.push(imageResult.rows[0]);
    }

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Images uploaded successfully',
      data: { images: uploadedImages }
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Upload scene images error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while uploading images'
    });
  } finally {
    client.release();
  }
};

/**
 * @route   POST /api/scenes/:sceneId/hotspots
 * @desc    Add hotspot to a scene (navigation or info)
 * @access  Private (Seller only)
 */
const createHotspot = async (req, res) => {
  try {
    const { sceneId } = req.params;
    const { hotspot_type, target_scene_id, yaw, pitch, title, description, icon_url } = req.body;

    // Check if scene exists and user has permission
    const sceneCheck = await pool.query(
      `SELECT s.id FROM scenes s
       LEFT JOIN properties p ON s.property_id = p.id
       WHERE s.id = $1 AND p.seller_id = $2`,
      [sceneId, req.user.id]
    );

    if (sceneCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Scene not found or you do not have permission'
      });
    }

    // Insert hotspot
    const result = await pool.query(
      `INSERT INTO hotspots (scene_id, hotspot_type, target_scene_id, yaw, pitch, title, description, icon_url)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [
        sceneId,
        hotspot_type,
        target_scene_id || null,
        parseFloat(yaw),
        parseFloat(pitch),
        title || null,
        description || null,
        icon_url || null
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Hotspot created successfully',
      data: { hotspot: result.rows[0] }
    });
  } catch (error) {
    console.error('Create hotspot error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating hotspot'
    });
  }
};

/**
 * @route   DELETE /api/scenes/:sceneId
 * @desc    Delete a scene
 * @access  Private (Seller only)
 */
const deleteScene = async (req, res) => {
  try {
    const { sceneId } = req.params;

    // Check if scene exists and user has permission
    const sceneCheck = await pool.query(
      `SELECT s.id FROM scenes s
       LEFT JOIN properties p ON s.property_id = p.id
       WHERE s.id = $1 AND p.seller_id = $2`,
      [sceneId, req.user.id]
    );

    if (sceneCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Scene not found or you do not have permission'
      });
    }

    // Delete scene (CASCADE will handle related records)
    await pool.query('DELETE FROM scenes WHERE id = $1', [sceneId]);

    res.status(200).json({
      success: true,
      message: 'Scene deleted successfully'
    });
  } catch (error) {
    console.error('Delete scene error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting scene'
    });
  }
};

module.exports = {
  getPropertyScenes,
  getSceneById,
  createScene,
  uploadSceneImages,
  createHotspot,
  deleteScene
};

