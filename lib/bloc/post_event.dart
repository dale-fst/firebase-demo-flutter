part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class FetchPost extends PostEvent {}

class UploadPhoto extends PostEvent {
  final Post post;
  final File file;

  const UploadPhoto({
    required this.post,
    required this.file,
  });

  @override
  List<Object> get props => [
        post,
        file,
      ];
}

class AddPost extends PostEvent {
  final Post post;

  const AddPost({
    required this.post,
  });

  @override
  List<Object> get props => [
        post,
      ];
}

class DeletePost extends PostEvent {
  final Post post;

  const DeletePost({
    required this.post,
  });

  @override
  List<Object> get props => [
        post,
      ];
}
