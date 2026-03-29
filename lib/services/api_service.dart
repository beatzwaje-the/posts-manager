import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String postsEndpoint = '/posts';

  // Handle API exceptions
  static String handleApiException(dynamic error) {
    if (error is http.ClientException) {
      return 'Network error: Check your internet connection';
    } else if (error is http.Response) {
      return 'Server error: ${error.statusCode}';
    } else if (error is FormatException) {
      return 'Data format error: Invalid response from server';
    } else {
      return 'Unexpected error: $error';
    }
  }

  // GET all posts
  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$postsEndpoint'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw response;
      }
    } catch (e) {
      throw handleApiException(e);
    }
  }

  // GET single post
  Future<Post> getPost(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$postsEndpoint/$id'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw response;
      }
    } catch (e) {
      throw handleApiException(e);
    }
  }

  // CREATE new post
  Future<Post> createPost(Post post) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$postsEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw response;
      }
    } catch (e) {
      throw handleApiException(e);
    }
  }

  // UPDATE existing post
  Future<Post> updatePost(int id, Post post) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$postsEndpoint/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw response;
      }
    } catch (e) {
      throw handleApiException(e);
    }
  }

  // DELETE post
  Future<bool> deletePost(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$postsEndpoint/$id'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw response;
      }
    } catch (e) {
      throw handleApiException(e);
    }
  }
}