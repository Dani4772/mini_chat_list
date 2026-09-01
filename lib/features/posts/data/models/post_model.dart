import 'package:hive/hive.dart';
import '../../domain/entities/post.dart';

part 'post_model.g.dart';


@HiveType(typeId: 0)
class PostModel extends Post {
  @HiveField(0)
  final int hiveId;

  @HiveField(1)
  final String hiveTitle;

  @HiveField(2)
  final String hiveBody;

  @HiveField(3)
  final DateTime hiveFetchedAt;

  PostModel({
    required this.hiveId,
    required this.hiveTitle,
    required this.hiveBody,
    required this.hiveFetchedAt,
  }) : super(id: hiveId, title: hiveTitle, body: hiveBody, fetchedAt: hiveFetchedAt);

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      hiveId: json['id'] as int,
      hiveTitle: json['title'] as String,
      hiveBody: json['body'] as String,
      hiveFetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': hiveId,
    'title': hiveTitle,
    'body': hiveBody,
  };
}