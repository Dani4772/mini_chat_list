import 'package:dio/dio.dart';

import '../../../../../core/errors/failures.dart';
import '../models/post_model.dart';


abstract class PostRemoteDataSource {
  Future<List<PostModel>> fetchPosts();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;
  static const String _endpoint =
      'https://jsonplaceholder.typicode.com/posts';

  PostRemoteDataSourceImpl(this.dio);

  @override
  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await dio.get(
        _endpoint,
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      if (response.statusCode != 200) {
        throw ServerFailure('Server returned status ${response.statusCode}');
      }

      final data = response.data as List;
      return data
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network request failed.');
    }
  }
}