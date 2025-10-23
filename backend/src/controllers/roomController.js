const pool = require('../config/database');
const { v4: uuidv4 } = require('uuid');

/**
 * Room Controller
 * Handles CRUD operations for rooms (which contain multiple viewpoints/scenes)
 */

/**
 * Create a new room for a property
 */
const createRoom = async (req, res) => {
  try {
    const { propertyId } = req.params;
    const { room_name, room_order, default_viewpoint_id } = req.body;

    const roomId = uuidv4();

    const result = await pool.query(
      `INSERT INTO rooms (id, property_id, room_name, room_order, default_viewpoint_id)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [roomId, propertyId, room_name, room_order, default_viewpoint_id || null]
    );

    res.status(201).json({
      success: true,
      message: 'Room created successfully',
      data: { room: result.rows[0] }
    });
  } catch (error) {
    console.error('Error creating room:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create room',
      error: error.message
    });
  }
};

/**
 * Get all rooms for a property with their viewpoints
 */
const getRoomsByProperty = async (req, res) => {
  try {
    const { propertyId } = req.params;

    // Get rooms with their viewpoints (scenes)
    const roomsQuery = await pool.query(
      `SELECT 
        r.id,
        r.property_id,
        r.room_name,
        r.room_order,
        r.default_viewpoint_id,
        r.created_at
       FROM rooms r
       WHERE r.property_id = $1
       ORDER BY r.room_order ASC`,
      [propertyId]
    );

    const rooms = roomsQuery.rows;

    // For each room, fetch its viewpoints (scenes)
    for (const room of rooms) {
      const viewpointsQuery = await pool.query(
        `SELECT 
          s.id,
          s.scene_name,
          s.viewpoint_name,
          s.scene_order,
          s.is_default_viewpoint,
          s.initial_view_yaw,
          s.initial_view_pitch,
          s.initial_view_fov,
          s.created_at
         FROM scenes s
         WHERE s.room_id = $1
         ORDER BY s.scene_order ASC`,
        [room.id]
      );

      room.viewpoints = viewpointsQuery.rows;
    }

    res.json({
      success: true,
      data: { rooms }
    });
  } catch (error) {
    console.error('Error fetching rooms:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch rooms',
      error: error.message
    });
  }
};

/**
 * Get a single room by ID with its viewpoints
 */
const getRoomById = async (req, res) => {
  try {
    const { roomId } = req.params;

    const roomQuery = await pool.query(
      `SELECT * FROM rooms WHERE id = $1`,
      [roomId]
    );

    if (roomQuery.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Room not found'
      });
    }

    const room = roomQuery.rows[0];

    // Fetch viewpoints for this room
    const viewpointsQuery = await pool.query(
      `SELECT 
        s.id,
        s.scene_name,
        s.viewpoint_name,
        s.scene_order,
        s.is_default_viewpoint,
        s.initial_view_yaw,
        s.initial_view_pitch,
        s.initial_view_fov,
        s.created_at
       FROM scenes s
       WHERE s.room_id = $1
       ORDER BY s.scene_order ASC`,
      [roomId]
    );

    room.viewpoints = viewpointsQuery.rows;

    res.json({
      success: true,
      data: { room }
    });
  } catch (error) {
    console.error('Error fetching room:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch room',
      error: error.message
    });
  }
};

/**
 * Update a room
 */
const updateRoom = async (req, res) => {
  try {
    const { roomId } = req.params;
    const { room_name, room_order, default_viewpoint_id } = req.body;

    const updates = [];
    const values = [];
    let paramCount = 1;

    if (room_name !== undefined) {
      updates.push(`room_name = $${paramCount++}`);
      values.push(room_name);
    }

    if (room_order !== undefined) {
      updates.push(`room_order = $${paramCount++}`);
      values.push(room_order);
    }

    if (default_viewpoint_id !== undefined) {
      updates.push(`default_viewpoint_id = $${paramCount++}`);
      values.push(default_viewpoint_id);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update'
      });
    }

    values.push(roomId);

    const result = await pool.query(
      `UPDATE rooms 
       SET ${updates.join(', ')}
       WHERE id = $${paramCount}
       RETURNING *`,
      values
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Room not found'
      });
    }

    res.json({
      success: true,
      message: 'Room updated successfully',
      data: { room: result.rows[0] }
    });
  } catch (error) {
    console.error('Error updating room:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update room',
      error: error.message
    });
  }
};

/**
 * Delete a room (and all its viewpoints/scenes)
 */
const deleteRoom = async (req, res) => {
  try {
    const { roomId } = req.params;

    const result = await pool.query(
      `DELETE FROM rooms WHERE id = $1 RETURNING *`,
      [roomId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Room not found'
      });
    }

    res.json({
      success: true,
      message: 'Room deleted successfully',
      data: { room: result.rows[0] }
    });
  } catch (error) {
    console.error('Error deleting room:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete room',
      error: error.message
    });
  }
};

/**
 * Set the default viewpoint for a room
 */
const setDefaultViewpoint = async (req, res) => {
  try {
    const { roomId } = req.params;
    const { viewpoint_id } = req.body;

    // Verify the viewpoint belongs to this room
    const viewpointCheck = await pool.query(
      `SELECT id FROM scenes WHERE id = $1 AND room_id = $2`,
      [viewpoint_id, roomId]
    );

    if (viewpointCheck.rows.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Viewpoint does not belong to this room'
      });
    }

    // Update all viewpoints in this room to not be default
    await pool.query(
      `UPDATE scenes SET is_default_viewpoint = false WHERE room_id = $1`,
      [roomId]
    );

    // Set the specified viewpoint as default
    await pool.query(
      `UPDATE scenes SET is_default_viewpoint = true WHERE id = $1`,
      [viewpoint_id]
    );

    // Update the room's default_viewpoint_id
    const result = await pool.query(
      `UPDATE rooms SET default_viewpoint_id = $1 WHERE id = $2 RETURNING *`,
      [viewpoint_id, roomId]
    );

    res.json({
      success: true,
      message: 'Default viewpoint set successfully',
      data: { room: result.rows[0] }
    });
  } catch (error) {
    console.error('Error setting default viewpoint:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to set default viewpoint',
      error: error.message
    });
  }
};

module.exports = {
  createRoom,
  getRoomsByProperty,
  getRoomById,
  updateRoom,
  deleteRoom,
  setDefaultViewpoint
};

