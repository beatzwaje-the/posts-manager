import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;
  final Function(Post) onPostSaved;

  const PostFormScreen({
    super.key,
    this.post,
    required this.onPostSaved,
  });

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _userIdController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
    _userIdController = TextEditingController(
      text: widget.post?.userId.toString() ?? '1',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final post = Post(
          id: widget.post?.id,
          userId: int.parse(_userIdController.text),
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );

        Post savedPost;
        if (widget.post == null) {
          // Create new post
          savedPost = await _apiService.createPost(post);
          if (mounted) {
            Fluttertoast.showToast(
              msg: 'Post created successfully!',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          }
        } else {
          // Update existing post
          savedPost = await _apiService.updatePost(widget.post!.id!, post);
          if (mounted) {
            Fluttertoast.showToast(
              msg: 'Post updated successfully!',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          }
        }

        if (mounted) {
          widget.onPostSaved(savedPost);
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Error: $e',
            backgroundColor: Colors.red,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'Create Post' : 'Edit Post'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter user ID';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.article),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter content';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _savePost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.post == null ? 'Create Post' : 'Update Post',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}