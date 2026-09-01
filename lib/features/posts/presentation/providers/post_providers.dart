import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../data/datasource/post_local_datasource.dart';
import '../../data/datasource/post_remote_datasource.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';



final dioProvider = Provider<Dio>((ref) => Dio());

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>(
      (ref) => NetworkInfoImpl(ref.read(connectivityProvider)),
);

final remoteDataSourceProvider = Provider<PostRemoteDataSource>(
      (ref) => PostRemoteDataSourceImpl(ref.read(dioProvider)),
);

final localDataSourceProvider = Provider<PostLocalDataSource>(
      (ref) => PostLocalDataSourceImpl(),
);

final postRepositoryProvider = Provider<PostRepository>(
      (ref) => PostRepositoryImpl(
    remoteDataSource: ref.read(remoteDataSourceProvider),
    localDataSource: ref.read(localDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);


sealed class PostListState {
  const PostListState();
}

class PostListLoading extends PostListState {
  const PostListLoading();
}

class PostListLoaded extends PostListState {
  final List<Post> posts;
  final bool isFromCache;
  const PostListLoaded({required this.posts, required this.isFromCache});
}

class PostListError extends PostListState {
  final String message;
  const PostListError(this.message);
}


class PostListNotifier extends StateNotifier<PostListState> {
  final PostRepository repository;

  PostListNotifier(this.repository) : super(const PostListLoading()) {
    load();
  }

  Future<void> load() async {
    state = const PostListLoading();
    await _fetch();
  }

  Future<void> refresh() async {
    if (state is! PostListLoaded) {
      state = const PostListLoading();
    }
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final result = await repository.getPosts();
      state = PostListLoaded(
        posts: result.posts,
        isFromCache: result.isFromCache,
      );
    } on Failure catch (f) {
      state = PostListError(f.message);
    } catch (e) {
      state = PostListError('Unexpected error: $e');
    }
  }
}

final postListProvider =
StateNotifierProvider<PostListNotifier, PostListState>(
      (ref) => PostListNotifier(ref.read(postRepositoryProvider)),
);


final searchQueryProvider = StateProvider<String>((ref) => '');


final filteredPostsProvider = Provider<List<Post>>((ref) {
  final state = ref.watch(postListProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  if (state is! PostListLoaded) return const [];
  if (query.isEmpty) return state.posts;

  return state.posts
      .where((p) =>
  p.title.toLowerCase().contains(query) ||
      p.body.toLowerCase().contains(query))
      .toList();
});