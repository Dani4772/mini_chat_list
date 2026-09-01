abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure([
    super.message = 'No internet connection and no cached data available.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read local cache.']);
}
