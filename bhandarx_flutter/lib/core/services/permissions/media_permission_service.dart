import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';

class MediaPermissionService {
  const MediaPermissionService._();

  static Future<bool> requestCameraPermission(BuildContext context) async {
    if (kIsWeb) {
      return true;
    }
    return _requestPermission(
      context: context,
      permission: Permission.camera,
    );
  }

  static Future<bool> requestPhotoPermission(BuildContext context) async {
    if (kIsWeb) {
      return true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _requestPermission(
        context: context,
        permission: Permission.photos,
      );
    }
    return _requestAnyPermission(
      context: context,
      permissions: const [Permission.photos, Permission.storage],
    );
  }

  static Future<bool> requestVideoLibraryPermission(
    BuildContext context,
  ) async {
    if (kIsWeb) {
      return true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _requestPermission(
        context: context,
        permission: Permission.videos,
      );
    }
    return _requestAnyPermission(
      context: context,
      permissions: const [Permission.videos, Permission.storage],
    );
  }

  static Future<bool> requestVideoCapturePermissions(
    BuildContext context,
  ) async {
    if (kIsWeb) {
      return true;
    }
    final hasCamera = await _requestPermission(
      context: context,
      permission: Permission.camera,
    );
    if (!hasCamera) {
      return false;
    }
    if (!context.mounted) {
      return false;
    }
    return _requestPermission(
      context: context,
      permission: Permission.microphone,
    );
  }

  static Future<bool> _requestPermission({
    required BuildContext context,
    required Permission permission,
  }) async {
    final status = await permission.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(context);
      }
      return false;
    }

    final result = await permission.request();
    if (result.isGranted || result.isLimited) {
      return true;
    }

    if (result.isPermanentlyDenied || result.isRestricted) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(context);
      }
    }
    return false;
  }

  static Future<bool> _requestAnyPermission({
    required BuildContext context,
    required List<Permission> permissions,
  }) async {
    for (final permission in permissions) {
      final granted = await _requestPermission(
        context: context,
        permission: permission,
      );
      if (granted) {
        return true;
      }
    }
    return false;
  }

  static Future<void> _showPermissionDeniedDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.tr('permission_required') ?? 'Permission Required'),
        content: Text(
          l10n?.tr('permission_denied_message') ??
              'Camera or media permission is denied. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n?.tr('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await openAppSettings();
            },
            child: Text(l10n?.tr('open_settings') ?? 'Open Settings'),
          ),
        ],
      ),
    );
  }
}
