import '../entities/post.dart';


class PostResult {
  final List<Post> posts;
  final bool isFromCache;

  const PostResult({required this.posts, required this.isFromCache});
}

abstract class PostRepository {
  Future<PostResult> getPosts();
}