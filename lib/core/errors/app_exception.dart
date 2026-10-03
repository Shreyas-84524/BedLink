import 'error_codes.dart';

/// Base exception class for BedLink application errors with typed error codes.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code = ErrorCodes.unknownError,
    this.cause,
  });

  final String message;
  final String code;
  final Object? cause;

  @override
  String toString() => 'AppException(code: $code, message: $message, cause: $cause)';
}

class AuthException extends AppException {
  const AuthException(
    String message, {
    super.code = ErrorCodes.authRequired,
    super.cause,
  }) : super(message: message);
}

class ValidationException extends AppException {
  const ValidationException(
    String message, {
    super.code = ErrorCodes.unknownError,
    super.cause,
  }) : super(message: message);
}

class NetworkException extends AppException {
  const NetworkException(
    String message, {
    super.code = ErrorCodes.networkError,
    super.cause,
  }) : super(message: message);
}

class HospitalRepositoryException extends AppException {
  const HospitalRepositoryException(
    String message, {
    super.code = ErrorCodes.repositoryError,
    this.isRlsBlock = false,
    super.cause,
  }) : super(message: message);

  final bool isRlsBlock;
}

class BedRepositoryException extends AppException {
  const BedRepositoryException(
    String message, {
    super.code = ErrorCodes.repositoryError,
    this.isRlsBlock = false,
    super.cause,
  }) : super(message: message);

  final bool isRlsBlock;
}

class LocationException extends AppException {
  const LocationException(
    String message, {
    super.code = ErrorCodes.noLocation,
    this.isServiceDisabled = false,
    this.isPermissionDenied = false,
    this.isPermanentlyDenied = false,
    super.cause,
  }) : super(message: message);

  final bool isServiceDisabled;
  final bool isPermissionDenied;
  final bool isPermanentlyDenied;
}

class RoutingException extends AppException {
  const RoutingException(
    String message, {
    super.code = ErrorCodes.networkError,
    this.isRateLimited = false,
    this.isAuthError = false,
    this.isNoRoute = false,
    super.cause,
  }) : super(message: message);

  final bool isRateLimited;
  final bool isAuthError;
  final bool isNoRoute;
}

