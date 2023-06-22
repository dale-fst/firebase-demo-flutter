import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? id;
  String? description;
  String? descriptionHtml;
  String? photoReference;
  String? thumbnailReference;
  String? photoUrl;
  String? uid;
  String? timestamp;

  Post({
    this.id,
    this.description,
    this.descriptionHtml,
    this.photoReference,
    this.thumbnailReference,
    this.photoUrl,
    this.uid,
    this.timestamp,
  });
}
