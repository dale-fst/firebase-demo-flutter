part of 'post_bloc.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostDone extends PostState {}

class PostUploading extends PostState {
  final double progress;

  const PostUploading({
    required this.progress,
  });

  @override
  List<Object> get props => [
        progress,
      ];
}

class PostUploadDone extends PostState {
  final Post post;

  const PostUploadDone({
    required this.post,
  });

  @override
  List<Object> get props => [
        post,
      ];
}

class PostLoaded extends PostState {
  final Stream<List<Post>> post;

  const PostLoaded({
    required this.post,
  });

  @override
  List<Object> get props => [
        post,
      ];
}

class PostError extends PostState {
  final String message;

  const PostError({
    required this.message,
  });

  @override
  List<Object> get props => [
        message,
      ];
}
