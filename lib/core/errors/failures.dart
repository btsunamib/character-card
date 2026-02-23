import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = '服务器错误']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = '网络连接失败']) : super(message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = '请求超时']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = '缓存错误']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = '输入验证失败']) : super(message);
}

class ApiKeyFailure extends Failure {
  const ApiKeyFailure([String message = 'API密钥无效或未设置']) : super(message);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([String message = '请求频率超限，请稍后重试']) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = '发生未知错误']) : super(message);
}
