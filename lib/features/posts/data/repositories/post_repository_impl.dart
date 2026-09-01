import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasource/post_local_datasource.dart';
import '../datasource/post_remote_datasource.dart';
import '../models/post_model.dart';


class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<PostResult> getPosts() async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return _fallbackToCacheOrThrow(const NoConnectionFailure());
    }

    try {
      final freshModels = await remoteDataSource.fetchPosts();
      await localDataSource.cachePosts(freshModels);
      return PostResult(
        posts: freshModels.cast<Post>(),
        isFromCache: false,
      );
    } on Failure {
      return _fallbackToCacheOrThrow(const ServerFailure());
    }
  }

  Future<PostResult> _fallbackToCacheOrThrow(Failure originalFailure) async {
    List<PostModel> cached;
    try {
      cached = await localDataSource.getCachedPosts();
    } catch (_) {
      throw const CacheFailure();
    }

    if (cached.isEmpty) {
      throw originalFailure;
    }

    return PostResult(posts: cached.cast<Post>(), isFromCache: true);
  }
}