const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  getPropertyScenes,
  getSceneById,
  createScene,
  uploadSceneImages,
  createHotspot,
  deleteScene
} = require('../controllers/sceneController');
const { authenticate, authorize } = require('../middlewares/auth');
const { upload360Images, handleUploadError } = require('../middlewares/upload');
const { handleValidationErrors } = require('../middlewares/validation');

/**
 * @route   GET /api/properties/:propertyId/scenes
 * @desc    Get all scenes for a property
 * @access  Public
 */
router.get('/properties/:propertyId/scenes', getPropertyScenes);

/**
 * @route   GET /api/scenes/:sceneId
 * @desc    Get single scene with images and hotspots (lazy loaded)
 * @access  Public
 */
router.get('/:sceneId', getSceneById);

/**
 * @route   POST /api/properties/:propertyId/scenes
 * @desc    Create a new scene for a property
 * @access  Private (Seller only)
 */
router.post(
  '/properties/:propertyId/scenes',
  authenticate,
  authorize('seller'),
  upload360Images,
  handleUploadError,
  [
    body('scene_name').notEmpty().withMessage('Scene name is required'),
    body('scene_order').isInt().withMessage('Scene order must be an integer')
  ],
  handleValidationErrors,
  createScene
);

/**
 * @route   POST /api/scenes/:sceneId/images
 * @desc    Upload images for a scene (360 tiles)
 * @access  Private (Seller only)
 */
router.post(
  '/:sceneId/images',
  authenticate,
  authorize('seller'),
  upload360Images,
  handleUploadError,
  uploadSceneImages
);

/**
 * @route   POST /api/scenes/:sceneId/hotspots
 * @desc    Add hotspot to a scene
 * @access  Private (Seller only)
 */
router.post(
  '/:sceneId/hotspots',
  authenticate,
  authorize('seller'),
  [
    body('hotspot_type')
      .isIn(['navigation', 'info'])
      .withMessage('Hotspot type must be navigation or info'),
    body('yaw').isFloat().withMessage('Yaw must be a number'),
    body('pitch').isFloat().withMessage('Pitch must be a number')
  ],
  handleValidationErrors,
  createHotspot
);

/**
 * @route   DELETE /api/scenes/:sceneId
 * @desc    Delete a scene
 * @access  Private (Seller only)
 */
router.delete('/:sceneId', authenticate, authorize('seller'), deleteScene);

module.exports = router;

