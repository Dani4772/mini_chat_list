import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/post_providers.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/post_list_item.dart';

class PostListScreen extends ConsumerStatefulWidget {
  const PostListScreen({super.key});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListProvider);
    final filteredPosts = ref.watch(filteredPostsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    if (_searchController.text != searchQuery) {
      _searchController.text = searchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Chat List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => ref
                      .read(searchQueryProvider.notifier)
                      .state = '',
                )
                    : null,
              ),
              onChanged: (value) =>
              ref.read(searchQueryProvider.notifier).state = value,
            ),
          ),
          if (state is PostListLoaded && state.isFromCache)
            _OfflineBanner(),
          Expanded(
            child: switch (state) {
              PostListLoading() => const LoadingView(),
              PostListError(:final message) => ErrorView(
                message: message,
                onRetry: () => ref.read(postListProvider.notifier).load(),
              ),
              PostListLoaded() => filteredPosts.isEmpty
                  ? EmptyView(
                message: searchQuery.isEmpty
                    ? 'No posts available yet.'
                    : 'No posts match "$searchQuery".',
                icon: searchQuery.isEmpty
                    ? Icons.inbox_outlined
                    : Icons.search_off,
              )
                  : RefreshIndicator(
                onRefresh: () =>
                    ref.read(postListProvider.notifier).refresh(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: filteredPosts.length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      PostListItem(post: filteredPosts[index]),
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber[100],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: Colors.amber[900]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline — showing last saved data',
              style: TextStyle(color: Colors.amber[900], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}