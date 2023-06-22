import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_demo/bloc/post_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:flutter/material.dart';

import '../model/post.dart';

class PostCreateScreen extends StatefulWidget {
  const PostCreateScreen({super.key});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final QuillController _controller = QuillController.basic();
  File? _selectedFile;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _post() async {
    final String description = _controller.document.toPlainText();
    if (_selectedFile == null || description.isEmpty) {
      _showMessage('Post content and photo is required.');
      return;
    }

    final List<dynamic> decodedList = jsonDecode(
      jsonEncode(
        _controller.document.toDelta().toJson(),
      ),
    );
    final html = QuillDeltaToHtmlConverter(
      decodedList.cast<Map<String, dynamic>>(),
      ConverterOptions.forEmail(),
    ).convert();

    context.read<PostBloc>().add(
          UploadPhoto(
            post: Post(
              description: description,
              descriptionHtml: html,
            ),
            file: _selectedFile!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _post,
          ),
        ],
      ),
      body: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) async {
          if (state is PostError) {
            _showMessage(state.message);
          } else if (state is PostUploadDone) {
            context.read<PostBloc>().add(AddPost(post: state.post));
          } else if (state is PostDone) {
            context.read<PostBloc>().add(FetchPost());
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              if (state is PostUploading)
                LinearProgressIndicator(
                  value: state.progress,
                  minHeight: 4.0,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              QuillToolbar.basic(controller: _controller),
              Expanded(
                child: QuillEditor(
                  controller: _controller,
                  scrollController: ScrollController(),
                  scrollable: true,
                  focusNode: FocusNode(),
                  autoFocus: true,
                  readOnly: false,
                  placeholder: 'Write your content here...',
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  expands: true,
                ),
              ),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Upload Photo'),
              ),
              Expanded(
                child: _selectedFile != null
                    ? ListTile(
                        leading: Image.file(_selectedFile!),
                        title: Text(_selectedFile!.path),
                      )
                    : Container(),
              ),
            ],
          );
        },
      ),
    );
  }
}
