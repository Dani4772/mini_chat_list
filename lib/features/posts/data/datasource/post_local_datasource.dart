import 'package:hive/hive.dart';
import '../../../../core/errors/failures.dart';
import '../models/post_model.dart';

abstract class PostLocalDataSource {

  Future<List<PostModel>> getCachedPosts();

  Future<void> cachePosts(List<PostModel> posts);
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  static const String boxName = 'posts_box';

  Future<Box<PostModel>> _openBox() async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<PostModel>(boxName);
      }
      return await Hive.openBox<PostModel>(boxName);
    } catch (e) {
      throw CacheFailure('Could not open local cache: $e');
    }
  }

  @override
  Future<List<PostModel>> getCachedPosts() async {
    final box = await _openBox();
    return box.values.toList();
  }

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    final box = await _openBox();
    await box.clear();
    await box.addAll(posts);
  }
}