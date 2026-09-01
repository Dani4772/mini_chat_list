
class Post {
  final int id;
  final String title;
  final String body;
  final DateTime fetchedAt;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.fetchedAt,
  });
}