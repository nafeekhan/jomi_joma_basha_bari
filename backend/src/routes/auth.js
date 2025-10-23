const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { register, login, getMe } = require('../controllers/authController');
const { authenticate } = require('../middlewares/auth');
const { handleValidationErrors } = require('../middlewares/validation');

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post(
  '/register',
  [
    body('email').isEmail().withMessage('Please provide a valid email'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters'),
    body('full_name').notEmpty().withMessage('Full name is required'),
    body('user_type')
      .isIn(['buyer', 'seller', 'admin'])
      .withMessage('User type must be buyer, seller, or admin'),
    body('company_name')
      .if(body('user_type').equals('seller'))
      .notEmpty()
      .withMessage('Company name is required for sellers')
  ],
  handleValidationErrors,
  register
);

/**
 * @route   POST /api/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Please provide a valid email'),
    body('password').notEmpty().withMessage('Password is required')
  ],
  handleValidationErrors,
  login
);

/**
 * @route   GET /api/auth/me
 * @desc    Get current user info
 * @access  Private
 */
router.get('/me', authenticate, getMe);

module.exports = router;

