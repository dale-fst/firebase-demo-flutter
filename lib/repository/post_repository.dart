import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../global/constants.dart';
import '../model/post.dart';

class PostRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  PostRepository({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  Stream<List<Post>> getPost() {
    return firebaseFirestore
        .collection(Constants.post)
        .orderBy(Constants.timestamp, descending: true)
        .snapshots()
        .asyncMap(
      (snapshot) async {
        final reference = firebaseStorage.ref();
        final posts = <Post>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as dynamic;

          Post post = Post(
            id: doc.id,
            description: data[Constants.description],
            descriptionHtml: data[Constants.descriptionHtml],
            thumbnailReference: data[Constants.thumbnailReference],
            photoReference: data[Constants.photoReference],
            photoUrl: data[Constants.photoUrl],
            uid: data[Constants.uid],
            timestamp: DateFormat('yyyy/MM/dd HH:mm:ss')
                .format(data[Constants.timestamp].toDate())
                .toString(),
          );

          // Get url for photo.
          String photoUrl = post.photoUrl ?? '';
          if (photoUrl.isEmpty) {
            try {
              photoUrl = await reference
                  .child(post.thumbnailReference!)
                  .getDownloadURL();
            } catch (e) {
              debugPrint('$e');
            }

            if (photoUrl.isEmpty) {
              try {
                photoUrl = await firebaseStorage
                    .ref()
                    .child(post.photoReference!)
                    .getDownloadURL();
              } catch (e) {
                debugPrint('$e');
              }
            }
            post.photoUrl = photoUrl;
          }

          posts.add(post);
        }

        return posts;
      },
    );
  }

  Future<void> addPost(Post post) {
    return firebaseFirestore.collection(Constants.post).add({
      Constants.description: post.description,
      Constants.descriptionHtml: post.descriptionHtml,
      Constants.photoReference: post.photoReference,
      Constants.thumbnailReference: post.thumbnailReference,
      Constants.uid: firebaseAuth.currentUser!.uid,
      Constants.timestamp: FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePost(Post post) {
    return firebaseFirestore.collection(Constants.post).doc(post.id!).delete();
  }

  Reference getReference(File file) {
    final guid = const Uuid().v4();
    return firebaseStorage.ref().child(
          'post/${guid}_${file.path.split('/').last}',
        );
  }

  UploadTask getUploadTask(Reference reference, File file) {
    return reference.putFile(file);
  }
}
