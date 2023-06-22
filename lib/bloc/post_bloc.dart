import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/post.dart';
import '../repository/post_repository.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostBloc({
    required this.postRepository,
  }) : super(PostInitial()) {
    on<FetchPost>(
      (event, emit) async {
        try {
          emit(PostLoading());
          emit(PostLoaded(post: postRepository.getPost()));
        } catch (error) {
          emit(PostError(message: 'Failed to fetch post: $error'));
        }
      },
    );
    on<UploadPhoto>(
      (event, emit) async {
        final reference = postRepository.getReference(event.file);
        final uploadTask = postRepository.getUploadTask(
          reference,
          event.file,
        );

        uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
          switch (taskSnapshot.state) {
            case TaskState.running:
              final progress =
                  taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
              emit(PostUploading(progress: progress));
              break;
            case TaskState.paused:
              emit(const PostError(message: 'Uploading has paused.'));
              break;
            case TaskState.canceled:
              emit(const PostError(message: 'Uploading was canceled.'));
              break;
            case TaskState.error:
              emit(const PostError(message: 'Uploading failed.'));
              break;
            case TaskState.success:
              break;
          }
        });

        try {
          await uploadTask;
          final split = reference.fullPath.split('.');
          emit(
            PostUploadDone(
              post: Post(
                description: event.post.description,
                descriptionHtml: event.post.descriptionHtml,
                photoReference: reference.fullPath,
                thumbnailReference: '${split.first}_200x200.${split.last}',
              ),
            ),
          );
        } catch (error) {
          emit(const PostError(message: 'Upload task failed.'));
        }
      },
    );
    on<AddPost>(
      (event, emit) async {
        try {
          await postRepository.addPost(event.post);
          emit(PostDone());
        } catch (error) {
          emit(PostError(message: 'Failed to add post $error'));
        }
      },
    );
    on<DeletePost>(
      (event, emit) async {
        try {
          emit(PostLoading());
          await postRepository.deletePost(event.post);
          emit(PostLoaded(post: postRepository.getPost()));
        } catch (error) {
          emit(PostError(message: 'Failed to delete post $error'));
        }
      },
    );
  }
}
