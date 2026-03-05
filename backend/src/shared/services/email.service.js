const nodemailer = require('nodemailer');
const config = require('../../config');
const logger = require('../../config/logger');

class EmailService {
  constructor() {
    if (!config.email.host || !config.email.user || !config.email.pass) {
      logger.warn('Email configuration is incomplete. Emails will not be sent.');
      return;
    }
    this.transporter = nodemailer.createTransport({
      host: config.email.host,
      port: config.email.port,
      secure: config.email.port === 465,
      auth: {
        user: config.email.user,
        pass: config.email.pass,
      },
    });
  }

  async sendEmail(options) {
    if (!this.transporter) {
      logger.error('Cannot send email: SMTP transporter not configured.');
      throw new Error('Email service is not configured');
    }
    const mailOptions = {
      from: config.email.from,
      to: options.email,
      subject: options.subject,
      html: options.html,
    };

    try {
      await this.transporter.sendMail(mailOptions);
      logger.info(`Email sent to: ${options.email}`);
    } catch (error) {
      logger.error(`Error sending email: ${error.message}`);
      // In production, you might not want to throw the error to prevent breaking the flow
      // but for password reset, we should know if it failed.
      throw new Error('Email could not be sent');
    }
  }

  async sendPasswordResetEmail(user, resetToken) {
    const resetUrl = `${config.frontendUrl}/reset-password/${resetToken}`;

    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px;">
        <div style="text-align: center; margin-bottom: 20px;">
          <h1 style="color: #16a34a; margin: 0;">BhandarX</h1>
          <p style="color: #666; margin: 5px 0 0;">Inventory Management System</p>
        </div>
        <div style="background-color: #f9f9f9; padding: 20px; border-radius: 5px;">
          <h2 style="color: #333; margin-top: 0;">Password Reset Request</h2>
          <p style="color: #555; line-height: 1.6;">Hello ${user.name},</p>
          <p style="color: #555; line-height: 1.6;">We received a request to reset your password. Please click the button below to set a new password:</p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${resetUrl}" style="background-color: #16a34a; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px;">Reset Password</a>
          </div>
          <p style="color: #666; font-size: 14px; line-height: 1.6;">This link will expire in <strong>15 minutes</strong>.</p>
          <p style="color: #666; font-size: 14px; line-height: 1.6;">If you didn't request this, you can safely ignore this email.</p>
        </div>
        <div style="text-align: center; margin-top: 20px; color: #999; font-size: 12px;">
          <p>© 2025 BhandarX. All rights reserved.</p>
        </div>
      </div>
    `;

    await this.sendEmail({
      email: user.email,
      subject: 'Password Reset Request - BhandarX',
      html,
    });
  }

  async sendPasswordResetOtpEmail(user, otpCode) {
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 560px; margin: 0 auto; padding: 20px; border: 1px solid #e2e8f0; border-radius: 12px;">
        <h1 style="color: #16a34a; margin: 0 0 8px 0;">BhandarX</h1>
        <p style="margin: 0 0 16px 0; color: #475569;">Password Reset OTP</p>
        <p style="color: #334155; line-height: 1.6;">Hello ${user.name}, use this OTP to reset your password in the mobile app:</p>
        <div style="margin: 20px 0; padding: 14px; background: #f1f5f9; border-radius: 8px; text-align: center; letter-spacing: 6px; font-weight: 700; font-size: 28px; color: #0f172a;">${otpCode}</div>
        <p style="color: #64748b; line-height: 1.6;">This OTP expires in <strong>15 minutes</strong>. If you did not request this, you can ignore this email.</p>
      </div>
    `;

    await this.sendEmail({
      email: user.email,
      subject: 'Your Password Reset OTP - BhandarX',
      html,
    });
  }
}

module.exports = new EmailService();
