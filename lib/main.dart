import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/posts/data/models/post_model.dart';
import 'features/posts/presentation/screens/post_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PostModelAdapter());

  runApp(const ProviderScope(child: MiniChatListApp()));
}

class MiniChatListApp extends StatelessWidget {
  const MiniChatListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Chat List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PostListScreen(),
    );
  }
}
