const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { 
  createRoom, 
  getRoomsByProperty, 
  getRoomById,
  updateRoom, 
  deleteRoom,
  setDefaultViewpoint
} = require('../controllers/roomController');
const { authenticate, authorize } = require('../middlewares/auth');
const { handleValidationErrors } = require('../middlewares/validation');

/**
 * Room Routes
 * Endpoints for managing rooms (containers for viewpoints)
 */

// Get all rooms for a property (with viewpoints)
router.get(
  '/properties/:propertyId/rooms',
  getRoomsByProperty
);

// Get a single room by ID
router.get(
  '/:roomId',
  getRoomById
);

// Create a new room
router.post(
  '/properties/:propertyId/rooms',
  authenticate,
  authorize('seller'),
  [
    body('room_name').notEmpty().withMessage('Room name is required'),
    body('room_order').isInt().withMessage('Room order must be an integer')
  ],
  handleValidationErrors,
  createRoom
);

// Update a room
router.put(
  '/:roomId',
  authenticate,
  authorize('seller'),
  updateRoom
);

// Delete a room
router.delete(
  '/:roomId',
  authenticate,
  authorize('seller'),
  deleteRoom
);

// Set default viewpoint for a room
router.put(
  '/:roomId/default-viewpoint',
  authenticate,
  authorize('seller'),
  [
    body('viewpoint_id').notEmpty().withMessage('Viewpoint ID is required')
  ],
  handleValidationErrors,
  setDefaultViewpoint
);

module.exports = router;

