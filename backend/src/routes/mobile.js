const express = require('express');
const config = require('../config');

const authRoutes = require('../modules/auth/routes');
const notificationRoutes = require('../modules/notifications/routes');
const productRoutes = require('../modules/products/routes');
const categoryRoutes = require('../modules/categories/routes');
const supplierRoutes = require('../modules/suppliers/routes');
const customerRoutes = require('../modules/customers/routes');
const saleRoutes = require('../modules/sales/routes');
const purchaseRoutes = require('../modules/purchases/routes');
const transactionRoutes = require('../modules/transactions/routes');
const reportRoutes = require('../modules/reports/routes');
const userController = require('../modules/users/user.controller');
const { protect } = require('../shared/middleware/auth');
const validate = require('../shared/middleware/validate');
const { uploadProfileImage, handleMulterError } = require('../shared/middleware/fileUpload');
const { updateProfileValidation } = require('../modules/users/user.validator');

const router = express.Router();
const mobileUserRouter = express.Router();

router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'BhandarX Mobile API is running',
    timestamp: new Date().toISOString(),
    version: config.apiVersion,
  });
});

// Mobile scope only: auth/profile/notifications
router.use('/auth', authRoutes);
router.use('/notifications', notificationRoutes);
router.use('/products', productRoutes);
router.use('/categories', categoryRoutes);
router.use('/suppliers', supplierRoutes);
router.use('/customers', customerRoutes);
router.use('/sales', saleRoutes);
router.use('/purchases', purchaseRoutes);
router.use('/transactions', transactionRoutes);
router.use('/reports', reportRoutes);
mobileUserRouter.get('/profile/me', protect, userController.getMyProfile);
mobileUserRouter.put(
  '/profile/me',
  protect,
  updateProfileValidation,
  validate,
  userController.updateMyProfile
);
mobileUserRouter.post(
  '/profile/image',
  protect,
  uploadProfileImage,
  handleMulterError,
  userController.uploadProfileImage
);
mobileUserRouter.delete('/profile/image', protect, userController.removeProfileImage);
router.use('/users', mobileUserRouter);

router.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found in mobile API scope`,
  });
});

module.exports = router;
