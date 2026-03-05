const express = require('express');
const swaggerUi = require('swagger-ui-express');
const setupMiddleware = require('./middleware');
const mobileRoutes = require('../routes/mobile');
const errorHandler = require('../shared/middleware/errorHandler');
const { apiLimiter } = require('../shared/middleware/rateLimiter');
const config = require('../config');
const swaggerSpec = require('../config/swagger');

const createMobileApp = () => {
  const app = express();

  setupMiddleware(app);

  app.use('/api', apiLimiter);

  app.get('/', (req, res) => {
    res.json({
      success: true,
      message: 'Welcome to BhandarX Mobile API',
      version: config.apiVersion,
      documentation: '/api-docs',
    });
  });

  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
    customCss: '.swagger-ui .topbar { display: none }',
    customSiteTitle: 'BhandarX Mobile API Documentation',
  }));

  app.use(`/api/${config.apiVersion}`, mobileRoutes);
  app.use(errorHandler);

  return app;
};

module.exports = createMobileApp;
