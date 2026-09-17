import 'package:dio/dio.dart';

import '../utils/app_error_messages.dart';
import '../utils/json_keys.dart';
import 'state_resource.dart';

StateResource<T> networkErrorHandler<T>(Object error) {
  if (error is DioException) {
    return StateResource<T>.error(_messageForDioException(error));
  }
  return StateResource<T>.error(AppErrorMessages.generic);
}

String _messageForDioException(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return AppErrorMessages.timeout;
    case DioExceptionType.connectionError:
      return AppErrorMessages.noInternet;
    case DioExceptionType.badResponse:
      return _messageForBadResponse(exception.response);
    default:
      return AppErrorMessages.generic;
  }
}

String _messageForBadResponse(Response<dynamic>? response) {
  final int? statusCode = response?.statusCode;
  switch (statusCode) {
    case 400:
      return _apiMessageFrom(response) ?? AppErrorMessages.generic;
    case 401:
      return AppErrorMessages.invalidApiKey;
    case 429:
      return AppErrorMessages.rateLimited;
    case 426:
      return AppErrorMessages.generic;
    default:
      if (statusCode != null && statusCode >= 500) {
        return AppErrorMessages.serverError;
      }
      return AppErrorMessages.generic;
  }
}

String? _apiMessageFrom(Response<dynamic>? response) {
  final Object? data = response?.data;
  if (data is Map<String, dynamic>) {
    final Object? message = data[JsonKeys.message];
    if (message is String && message.isNotEmpty) {
      return message;
    }
  }
  return null;
}
