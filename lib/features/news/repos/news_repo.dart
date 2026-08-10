import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/news_category_model.dart';
import '../models/news_article_model.dart';

abstract class NewsRepo {
  Future<List<NewsCategoryModel>> getCategories({String? token});
  Future<List<NewsArticleModel>> getFarmerNewsFeed({int? categoryId, String? categoryName, String? search, String? token});
  Future<NewsArticleModel> getNewsDetail(int newsId, {String? token});

  // Admin Endpoints
  Future<List<NewsArticleModel>> getAdminNewsList({String? token});
  Future<NewsArticleModel> getAdminNewsDetail(int id, {String? token});
  Future<NewsArticleModel> createAdminNews({
    required String title,
    required String summary,
    required String content,
    required int categoryId,
    String? imageUrl,
    List<int>? imageBytes,
    String? imageName,
    String status = 'DRAFT',
    String? token,
  });
  Future<NewsArticleModel> updateAdminNews(
    int id, {
    String? title,
    String? summary,
    String? content,
    int? categoryId,
    String? imageUrl,
    List<int>? imageBytes,
    String? imageName,
    String? status,
    String? token,
  });
  Future<void> deleteAdminNews(int id, {String? token});
  Future<NewsArticleModel> publishAdminNews(int id, {String? token});
}

class HttpNewsRepo implements NewsRepo {
  Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static const List<NewsCategoryModel> _defaultCategories = [
    NewsCategoryModel(id: 1, name: 'Weather Alerts', description: 'Severe weather notices and rainfall forecasts'),
    NewsCategoryModel(id: 2, name: 'Crop Management', description: 'Seasonal planting and harvesting guidelines'),
    NewsCategoryModel(id: 3, name: 'Fertilizer', description: 'Fertilizer availability and dosage advisories'),
    NewsCategoryModel(id: 4, name: 'Pest & Disease', description: 'Pest outbreak alerts and treatment steps'),
    NewsCategoryModel(id: 5, name: 'Government Schemes', description: 'Nepal government subsidies and farming schemes'),
    NewsCategoryModel(id: 6, name: 'Organic Farming', description: 'Organic compost and biological pest control guidelines'),
    NewsCategoryModel(id: 7, name: 'Farming Techniques', description: 'Modern precision farming methods and machinery usage'),
  ];

  @override
  Future<List<NewsCategoryModel>> getCategories({String? token}) async {
    final uri = Uri.parse(ApiEndpoints.newsCategories);

    // 1. Try with token headers
    try {
      final response = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['categories'] as List?) ?? (decoded['results'] as List?) ?? [];
        }
        if (list.isNotEmpty) {
          return list.map((item) => NewsCategoryModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    // 2. Try minimal ngrok header
    try {
      final response = await http.get(uri, headers: {'ngrok-skip-browser-warning': 'true'}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['categories'] as List?) ?? (decoded['results'] as List?) ?? [];
        }
        if (list.isNotEmpty) {
          return list.map((item) => NewsCategoryModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    // 3. Try basic GET
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['categories'] as List?) ?? (decoded['results'] as List?) ?? [];
        }
        if (list.isNotEmpty) {
          return list.map((item) => NewsCategoryModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    return _defaultCategories;
  }

  @override
  Future<List<NewsArticleModel>> getFarmerNewsFeed({int? categoryId, String? categoryName, String? search, String? token}) async {
    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category'] = categoryId.toString();
    if (categoryName != null && categoryName.trim().isNotEmpty) queryParams['category__name'] = categoryName.trim();
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();

    final uri = Uri.parse(ApiEndpoints.farmerNewsFeed).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    // 1. Try with Auth token headers
    try {
      final response = await http.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['results'] as List?) ?? (decoded['articles'] as List?) ?? [];
        }
        if (list.isNotEmpty) {
          return list.map((item) => NewsArticleModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    // 2. Try minimal ngrok header
    try {
      final response = await http.get(uri, headers: {'ngrok-skip-browser-warning': 'true'}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['results'] as List?) ?? (decoded['articles'] as List?) ?? [];
        }
        if (list.isNotEmpty) {
          return list.map((item) => NewsArticleModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    // 3. Try standard GET without custom headers (bypasses browser CORS preflight restrictions)
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['results'] as List?) ?? (decoded['articles'] as List?) ?? [];
        }
        return list.map((item) => NewsArticleModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<NewsArticleModel> getNewsDetail(int newsId, {String? token}) async {
    try {
      var response = await http
          .get(Uri.parse(ApiEndpoints.farmerNewsDetail(newsId)), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if ((response.statusCode == 401 || response.statusCode == 403) && token != null) {
        response = await http
            .get(Uri.parse(ApiEndpoints.farmerNewsDetail(newsId)), headers: _headers(null))
            .timeout(const Duration(seconds: 10));
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final articleJson = decoded['article'] as Map<String, dynamic>? ?? decoded;
        return NewsArticleModel.fromJson(articleJson);
      }
      throw Exception('Failed to fetch article detail (${response.statusCode})');
    } catch (e) {
      throw Exception('NewsRepo Error: $e');
    }
  }

  @override
  Future<List<NewsArticleModel>> getAdminNewsList({String? token}) async {
    // 1. Fetch news feed /api/news/ with admin token
    try {
      final farmerNews = await getFarmerNewsFeed(token: token);
      if (farmerNews.isNotEmpty) {
        return farmerNews;
      }
    } catch (_) {}

    // 2. Fetch news feed /api/news/ without token (public request)
    try {
      final farmerNewsNoToken = await getFarmerNewsFeed(token: null);
      if (farmerNewsNoToken.isNotEmpty) {
        return farmerNewsNoToken;
      }
    } catch (_) {}

    // 3. Fallback to admin endpoint /api/admin/news/
    try {
      final response = await http
          .get(Uri.parse(ApiEndpoints.adminNews), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = (decoded['results'] as List?) ?? (decoded['articles'] as List?) ?? [];
        }
        return list.map((item) => NewsArticleModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<NewsArticleModel> getAdminNewsDetail(int id, {String? token}) async {
    try {
      final response = await http
          .get(Uri.parse(ApiEndpoints.adminNewsDetail(id)), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final articleJson = decoded['article'] as Map<String, dynamic>? ?? decoded;
        return NewsArticleModel.fromJson(articleJson);
      }
    } catch (e) {
      // Fallback below
    }

    return getNewsDetail(id, token: token);
  }

  @override
  Future<NewsArticleModel> createAdminNews({
    required String title,
    required String summary,
    required String content,
    required int categoryId,
    String? imageUrl,
    List<int>? imageBytes,
    String? imageName,
    String status = 'DRAFT',
    String? token,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.adminNews));
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['title'] = title;
      request.fields['summary'] = summary;
      request.fields['content'] = content;
      request.fields['category_id'] = categoryId.toString();
      request.fields['status'] = status;

      if (imageBytes != null && imageBytes.isNotEmpty) {
        final filename = imageName ?? 'news_image.jpg';
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: filename,
          ),
        );
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        request.fields['image_url'] = imageUrl;
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final articleJson = decoded['article'] as Map<String, dynamic>? ?? decoded;
        return NewsArticleModel.fromJson(articleJson);
      }
      throw Exception('Failed to create news (${response.statusCode}): ${response.body}');
    } catch (e) {
      throw Exception('NewsRepo Admin Create Error: $e');
    }
  }

  @override
  Future<NewsArticleModel> updateAdminNews(
    int id, {
    String? title,
    String? summary,
    String? content,
    int? categoryId,
    String? imageUrl,
    List<int>? imageBytes,
    String? imageName,
    String? status,
    String? token,
  }) async {
    try {
      final request = http.MultipartRequest('PATCH', Uri.parse(ApiEndpoints.adminNewsDetail(id)));
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (title != null) request.fields['title'] = title;
      if (summary != null) request.fields['summary'] = summary;
      if (content != null) request.fields['content'] = content;
      if (categoryId != null) request.fields['category_id'] = categoryId.toString();
      if (status != null) request.fields['status'] = status;

      if (imageBytes != null && imageBytes.isNotEmpty) {
        final filename = imageName ?? 'news_image.jpg';
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: filename,
          ),
        );
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        request.fields['image_url'] = imageUrl;
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final articleJson = decoded['article'] as Map<String, dynamic>? ?? decoded;
        return NewsArticleModel.fromJson(articleJson);
      }
      throw Exception('Failed to update news (${response.statusCode}): ${response.body}');
    } catch (e) {
      throw Exception('NewsRepo Admin Update Error: $e');
    }
  }

  @override
  Future<void> deleteAdminNews(int id, {String? token}) async {
    try {
      final response = await http
          .delete(Uri.parse(ApiEndpoints.adminNewsDetail(id)), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete news (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('NewsRepo Admin Delete Error: $e');
    }
  }

  @override
  Future<NewsArticleModel> publishAdminNews(int id, {String? token}) async {
    try {
      final response = await http
          .post(Uri.parse(ApiEndpoints.adminPublishNews(id)), headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final articleJson = decoded['article'] as Map<String, dynamic>? ?? decoded;
        return NewsArticleModel.fromJson(articleJson);
      }
      throw Exception('Failed to publish news article (${response.statusCode})');
    } catch (e) {
      throw Exception('NewsRepo Admin Publish Error: $e');
    }
  }
}

class MockNewsRepo implements NewsRepo {
  final List<NewsCategoryModel> _mockCategories = const [
    NewsCategoryModel(id: 1, name: 'Weather Alerts', description: 'Severe weather notices and rainfall forecasts'),
    NewsCategoryModel(id: 2, name: 'Crop Management', description: 'Seasonal planting and harvesting guidelines'),
    NewsCategoryModel(id: 3, name: 'Fertilizer', description: 'Fertilizer availability and dosage advisories'),
    NewsCategoryModel(id: 4, name: 'Pest & Disease', description: 'Pest outbreak alerts and treatment steps'),
    NewsCategoryModel(id: 5, name: 'Government Schemes', description: 'Nepal government subsidies and farming schemes'),
  ];

  late final List<NewsArticleModel> _mockArticles = [
    NewsArticleModel(
      id: 12,
      title: 'Armyworm Outbreak Alert in Chitwan Maize Fields',
      summary: 'Fall armyworm detected in Chitwan region. Immediate pesticide application recommended.',
      content: '''## Fall Armyworm Alert (Chitwan District)

Recent surveillance by agricultural extension officers has confirmed sightings of Fall Armyworm (*Spodoptera frugiperda*) larvae in maize fields across Chitwan.

### Recommended Steps:
1. **Field Inspection:** Inspect young maize whorls during early morning or late afternoon for leaf damage and frass.
2. **Pesticide Application:** Apply **Emamectin benzoate 5% SG** at **0.4g per liter of water** directly into crop whorls.
3. **Biological Control:** Encourage natural predators and clear weed borders around fields.
4. **Report Outbreaks:** Contact your local Krishi Gyan Kendra for support and subsidized pesticide distribution.''',
      imageUrl: 'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?auto=format&fit=crop&w=800&q=80',
      category: const NewsCategoryModel(id: 4, name: 'Pest & Disease', description: 'Pest outbreak alerts'),
      createdBy: 'Extension Officer Chitwan',
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'PUBLISHED',
    ),
    NewsArticleModel(
      id: 14,
      title: 'Monsoon Rainfall & Irrigation Advisory for Terai Region',
      summary: 'Heavy monsoon rains predicted over the next 48 hours. Ensure proper drainage in rice paddies.',
      content: '''## Terai Monsoon Advisory

Department of Hydrology and Meteorology forecasts moderate to heavy rainfall across Parsa, Bara, and Rupandehi over the coming weekend.

### Farmer Guidance:
* **Rice Farmers:** Maintain 5cm water level in paddy fields; clear drainage channels to prevent waterlogging.
* **Vegetable Farmers:** Raise nursery beds and apply organic mulch to protect delicate seedlings from heavy downpours.
* **Fertilizer Caution:** Delay broadcasting Urea until rain subsides to prevent nutrient runoff.''',
      imageUrl: 'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?auto=format&fit=crop&w=800&q=80',
      category: const NewsCategoryModel(id: 1, name: 'Weather Alerts', description: 'Severe weather notices'),
      createdBy: 'AgroMet Nepal',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: 'PUBLISHED',
    ),
    NewsArticleModel(
      id: 15,
      title: 'Subsidy Distribution: Subsidized Urea & DAP Allocation Announced',
      summary: 'Nepal Agricultural Supply Corporation announces fresh distribution of subsidized fertilizers.',
      content: '''## Fertilizer Subsidy Distribution Notice

The Ministry of Agriculture and Livestock Development has approved the allocation of 25,000 metric tons of subsidized Urea and DAP for smallholder farmers.

### Distribution Details:
* **Required Documents:** Citizenship Card & Farm Registration Certificate.
* **Quota:** Maximum 2 bags (100 kg total) per farming household.
* **Contact:** Visit local agricultural cooperatives starting Sunday morning.''',
      imageUrl: 'https://images.unsplash.com/photo-1628352081506-83c43123ed6d?auto=format&fit=crop&w=800&q=80',
      category: const NewsCategoryModel(id: 3, name: 'Fertilizer', description: 'Fertilizer availability'),
      createdBy: 'Ministry of Agriculture',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      status: 'PUBLISHED',
    ),
  ];

  @override
  Future<List<NewsCategoryModel>> getCategories({String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCategories;
  }

  @override
  Future<List<NewsArticleModel>> getFarmerNewsFeed({int? categoryId, String? categoryName, String? search, String? token}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var list = _mockArticles.where((a) => a.status == 'PUBLISHED').toList();
    if (categoryId != null) {
      list = list.where((a) => a.category.id == categoryId).toList();
    }
    if (categoryName != null && categoryName.trim().isNotEmpty) {
      final cName = categoryName.trim().toLowerCase();
      list = list.where((a) => a.category.name.toLowerCase() == cName).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((a) => a.title.toLowerCase().contains(q) || a.summary.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Future<NewsArticleModel> getNewsDetail(int newsId, {String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final article = _mockArticles.firstWhere(
      (a) => a.id == newsId,
      orElse: () => _mockArticles.first,
    );
    return article;
  }

  @override
  Future<List<NewsArticleModel>> getAdminNewsList({String? token}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_mockArticles);
  }

  @override
  Future<NewsArticleModel> getAdminNewsDetail(int id, {String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockArticles.firstWhere(
      (a) => a.id == id,
      orElse: () => _mockArticles.first,
    );
  }

  @override
  Future<NewsArticleModel> createAdminNews({
    required String title,
    required String summary,
    required String content,
    required int categoryId,
    String? imageUrl,
    List<int>? imageBytes,
    String? imageName,
    String status = 'DRAFT',
    String? token,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final cat = _mockCategories.firstWhere((c) => c.id == categoryId, orElse: () => _mockCategories.first);
    final newId = DateTime.now().millisecondsSinceEpoch % 10000;
    final article = NewsArticleModel(
      id: newId,
      title: title,
      summary: summary,
      content: content,
      imageUrl: imageUrl ?? (imageName != null ? 'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?auto=format&fit=crop&w=800&q=80' : null),
      category: cat,
      createdBy: 'Officer Admin',
      createdAt: DateTime.now(),
      publishedAt: status == 'PUBLISHED' ? DateTime.now() : null,
      status: status,
    );
    _mockArticles.insert(0, article);
    return article;
  }

  @override
  Future<NewsArticleModel> updateAdminNews(
    int id, {
    String? title,
    String? summary,
    String? content,
    int? categoryId,
    String? imageUrl,
    List<int>? imageBytes,
    String? imageName,
    String? status,
    String? token,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _mockArticles.indexWhere((a) => a.id == id);
    if (index == -1) throw Exception('Article not found');
    final existing = _mockArticles[index];
    final cat = categoryId != null
        ? _mockCategories.firstWhere((c) => c.id == categoryId, orElse: () => existing.category)
        : existing.category;

    final updated = NewsArticleModel(
      id: existing.id,
      title: title ?? existing.title,
      summary: summary ?? existing.summary,
      content: content ?? existing.content,
      imageUrl: imageUrl ?? existing.imageUrl,
      category: cat,
      createdBy: existing.createdBy,
      createdAt: existing.createdAt,
      publishedAt: (status == 'PUBLISHED' && existing.publishedAt == null) ? DateTime.now() : existing.publishedAt,
      status: status ?? existing.status,
    );
    _mockArticles[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteAdminNews(int id, {String? token}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockArticles.removeWhere((a) => a.id == id);
  }

  @override
  Future<NewsArticleModel> publishAdminNews(int id, {String? token}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return updateAdminNews(id, status: 'PUBLISHED', token: token);
  }
}
