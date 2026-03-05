const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const compression = require('compression');
const mongoSanitize = require('express-mongo-sanitize');
const path = require('path');
const config = require('../config');
const logger = require('../config/logger');

const setupMiddleware = (app) => {
  // Security middleware
  app.use(helmet());

  // CORS configuration
  const configuredOrigins = (config.cors.origin || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  app.use(
    cors({
      origin(origin, callback) {
        if (!origin) {
          return callback(null, true);
        }

        const isLocalhost = /^https?:\/\/localhost(?::\d+)?$/.test(origin);
        if (config.env === 'development' && isLocalhost) {
          return callback(null, true);
        }

        if (configuredOrigins.includes('*') || configuredOrigins.includes(origin)) {
          return callback(null, true);
        }

        return callback(new Error(`CORS blocked for origin: ${origin}`));
      },
      credentials: true,
    })
  );

  // Body parser middleware
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // Serve static files (uploaded files)
  app.use('/uploads', express.static(path.join(__dirname, '../../uploads')));

  // MongoDB sanitization
  app.use(mongoSanitize());

  // Compression middleware
  app.use(compression());

  // HTTP request logger
  if (config.env === 'development') {
    app.use(morgan('dev'));
  } else {
    app.use(morgan('combined', {
      stream: {
        write: (message) => logger.info(message.trim()),
      },
    }));
  }

  // Request logging
  app.use((req, res, next) => {
    logger.info(`${req.method} ${req.originalUrl}`);
    next();
  });
};

module.exports = setupMiddleware;
