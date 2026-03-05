require('dotenv').config({ path: process.env.ENV_FILE || '.env.mobile' });
const createMobileApp = require('./app/mobile');
const connectDB = require('./config/database');
const config = require('./config');
const logger = require('./config/logger');
const socketService = require('./shared/services/socket.service');

process.on('uncaughtException', (err) => {
  logger.error('UNCAUGHT EXCEPTION! Shutting down mobile server...');
  logger.error('Error:', err);
  process.exit(1);
});

const app = createMobileApp();
connectDB();

const mobilePort = Number(process.env.MOBILE_PORT || process.env.PORT || 5002);

const server = app.listen(mobilePort, () => {
  logger.info(`BhandarX Mobile API running at http://localhost:${mobilePort}`);
});

socketService.initialize(server);

process.on('unhandledRejection', (err) => {
  logger.error('UNHANDLED REJECTION! Shutting down mobile server...');
  logger.error(err.name, err.message);
  server.close(() => {
    process.exit(1);
  });
});
