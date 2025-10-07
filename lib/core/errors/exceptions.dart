class AppException implements Exception {
	final String message;
	final Object? cause;
	final StackTrace? stackTrace;

	const AppException(this.message, {this.cause, this.stackTrace});

	@override
	String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
	const NetworkException(super.message, {super.cause, super.stackTrace});
}

class AuthException extends AppException {
	const AuthException(super.message, {super.cause, super.stackTrace});
}

class NotFoundException extends AppException {
	const NotFoundException(super.message, {super.cause, super.stackTrace});
}

