import 'package:equatable/equatable.dart';

enum _Status { init, loading, success, error }

class StateResource<T> extends Equatable {
  const StateResource.init() : _status = _Status.init, data = null, error = null;

  const StateResource.loading()
    : _status = _Status.loading,
      data = null,
      error = null;

  const StateResource.success(T value)
    : _status = _Status.success,
      data = value,
      error = null;

  const StateResource.error(String message)
    : _status = _Status.error,
      data = null,
      error = message;

  final _Status _status;
  final T? data;
  final String? error;

  bool get isInit => _status == _Status.init;

  bool get isLoading => _status == _Status.loading;

  bool get isSuccess => _status == _Status.success;

  bool get isError => _status == _Status.error;

  @override
  List<Object?> get props => <Object?>[_status, data, error];
}
