import 'package:firebase_demo/ui/post_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../bloc/post_bloc.dart';
import '../model/post.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(FetchPost());
  }

  Widget _buildList(Stream<List<Post>> post) {
    return StreamBuilder<List<Post>>(
      stream: post,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final postList = snapshot.data!;
          return ListView.builder(
            itemCount: postList.length,
            itemBuilder: (context, index) {
              final post = postList[index];
              return ListTile(
                leading: Container(
                  color: Colors.grey,
                  height: 55.0,
                  width: 55.0,
                  child: post.photoUrl != ''
                      ? Image.network(
                          post.photoUrl ?? '',
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                title: HtmlWidget(post.descriptionHtml ?? ''),
                subtitle: Text('Posted on ${post.timestamp}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => context.read<PostBloc>().add(
                            DeletePost(
                              post: post,
                            ),
                          ),
                    ),
                  ],
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Failed to fetch tasks'));
        } else {
          return _progressIndicator();
        }
      },
    );
  }

  Widget _progressIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  void _reload() {
    context.read<PostBloc>().add(FetchPost());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Post Feeds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _reload,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostLoaded) {
              return _buildList(state.post);
            } else if (state is PostLoading) {
              return _progressIndicator();
            } else if (state is PostError) {
              return Center(
                child: Text(state.message),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PostCreateScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
