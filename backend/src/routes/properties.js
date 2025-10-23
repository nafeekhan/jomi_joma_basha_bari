const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  getAllProperties,
  getPropertyById,
  createProperty,
  updateProperty,
  deleteProperty
} = require('../controllers/propertyController');
const { authenticate, authorize } = require('../middlewares/auth');
const { handleValidationErrors } = require('../middlewares/validation');

/**
 * @route   GET /api/properties
 * @desc    Get all properties with filters
 * @access  Public
 */
router.get('/', getAllProperties);

/**
 * @route   GET /api/properties/:id
 * @desc    Get single property by ID
 * @access  Public
 */
router.get('/:id', getPropertyById);

/**
 * @route   POST /api/properties
 * @desc    Create a new property
 * @access  Private (Seller only)
 */
router.post(
  '/',
  authenticate,
  authorize('seller'),
  [
    body('title').notEmpty().withMessage('Title is required'),
    body('property_type')
      .isIn(['buy', 'rent'])
      .withMessage('Property type must be buy or rent'),
    body('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
    body('address_line').notEmpty().withMessage('Address is required'),
    body('city').notEmpty().withMessage('City is required'),
    body('country').notEmpty().withMessage('Country is required')
  ],
  handleValidationErrors,
  createProperty
);

/**
 * @route   PUT /api/properties/:id
 * @desc    Update property
 * @access  Private (Seller - own properties only)
 */
router.put('/:id', authenticate, authorize('seller'), updateProperty);

/**
 * @route   DELETE /api/properties/:id
 * @desc    Delete property
 * @access  Private (Seller - own properties only, or Admin)
 */
router.delete('/:id', authenticate, authorize('seller', 'admin'), deleteProperty);

module.exports = router;

