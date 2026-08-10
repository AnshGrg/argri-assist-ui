import 'package:flutter/material.dart';
import '../models/news_category_model.dart';
import '../models/news_article_model.dart';
import '../models/subscription_model.dart';
import '../repos/news_repo.dart';
import '../repos/subscription_repo.dart';
import '../../../core/services/token_storage.dart';

class NewsController extends ChangeNotifier {
  final NewsRepo newsRepo;
  final SubscriptionRepo subscriptionRepo;
  final String? userToken;

  List<NewsCategoryModel> _categories = [];
  NewsCategoryModel? _selectedCategory;
  List<NewsArticleModel> _articles = [];
  List<SubscriptionModel> _subscriptions = [];
  Set<int> _subscribedCategoryIds = {};

  NewsArticleModel? _selectedArticle;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  String? _adminToken;

  NewsController({
    required this.newsRepo,
    required this.subscriptionRepo,
    this.userToken,
  });

  String? get adminToken => _adminToken ?? userToken;
  bool get isAdminLoggedIn => adminToken != null && adminToken!.isNotEmpty;

  void setAdminToken(String? token) {
    _adminToken = token;
    notifyListeners();
  }

  void logoutAdmin() {
    _adminToken = null;
    notifyListeners();
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

  List<NewsCategoryModel> get categories => _categories.isNotEmpty ? _categories : _defaultCategories;
  NewsCategoryModel? get selectedCategory => _selectedCategory;
  List<NewsArticleModel> get articles => _articles;
  List<SubscriptionModel> get subscriptions => _subscriptions;
  Set<int> get subscribedCategoryIds => _subscribedCategoryIds;
  NewsArticleModel? get selectedArticle => _selectedArticle;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<String?> _getEffectiveToken() async {
    final current = adminToken;
    if (current != null && current.isNotEmpty) {
      return current;
    }
    final saved = await TokenStorage.loadTokens();
    return saved?.access;
  }

  Future<void> init() async {
    await Future.wait([
      fetchCategories(),
      fetchSubscriptions(),
      fetchFarmerNewsFeed(),
    ]);
  }

  Future<void> fetchCategories() async {
    try {
      final token = await _getEffectiveToken();
      _categories = await newsRepo.getCategories(token: token);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> fetchSubscriptions() async {
    try {
      final token = await _getEffectiveToken();
      _subscriptions = await subscriptionRepo.getSubscriptions(token: token);
      _subscribedCategoryIds = _subscriptions.map((s) => s.category.id).toSet();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> fetchFarmerNewsFeed() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getEffectiveToken();
      _articles = await newsRepo.getFarmerNewsFeed(
        categoryId: _selectedCategory?.id,
        search: _searchQuery,
        token: token,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(NewsCategoryModel? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    fetchFarmerNewsFeed();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchFarmerNewsFeed();
  }

  Future<NewsArticleModel?> fetchArticleDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getEffectiveToken();
      _selectedArticle = await newsRepo.getNewsDetail(id, token: token);
      return _selectedArticle;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleSubscription(int categoryId) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final token = await _getEffectiveToken();
      final isSubbed = _subscribedCategoryIds.contains(categoryId);
      if (isSubbed) {
        final subIndex = _subscriptions.indexWhere((s) => s.category.id == categoryId || s.categoryId == categoryId);
        if (subIndex != -1) {
          final sub = _subscriptions[subIndex];
          await subscriptionRepo.unsubscribe(sub.id, token: token);
          _subscriptions.removeAt(subIndex);
        }
        _subscribedCategoryIds.remove(categoryId);
      } else {
        final newSub = await subscriptionRepo.subscribe(categoryId, token: token);
        _subscriptions.add(newSub);
        final addedCatId = newSub.category.id != 0 ? newSub.category.id : (newSub.categoryId != 0 ? newSub.categoryId : categoryId);
        _subscribedCategoryIds.add(addedCatId);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // Admin Methods (Uses adminToken header or loaded fallback token)
  Future<List<NewsArticleModel>> fetchAdminNewsList() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _getEffectiveToken();
      final list = await newsRepo.getAdminNewsList(token: token);
      _articles = list;
      notifyListeners();
      return list;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return _articles;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAdminArticle({
    required String title,
    required String summary,
    required String content,
    required int categoryId,
    String? imageUrl,
    List<int>? imageBytes,
    String? imageName,
    String status = 'DRAFT',
  }) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      final token = await _getEffectiveToken();
      await newsRepo.createAdminNews(
        title: title,
        summary: summary,
        content: content,
        categoryId: categoryId,
        imageUrl: imageUrl,
        imageBytes: imageBytes,
        imageName: imageName,
        status: status,
        token: token,
      );
      await fetchFarmerNewsFeed();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> publishAdminArticle(int id) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      final token = await _getEffectiveToken();
      await newsRepo.publishAdminNews(id, token: token);
      await fetchFarmerNewsFeed();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<NewsArticleModel?> fetchAdminNewsDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final token = await _getEffectiveToken();
      return await newsRepo.getAdminNewsDetail(id, token: token);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAdminArticle(
    int id, {
    String? title,
    String? summary,
    String? content,
    int? categoryId,
    String? imageUrl,
    List<int>? imageBytes,
    String? imageName,
    String? status,
  }) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      final token = await _getEffectiveToken();
      await newsRepo.updateAdminNews(
        id,
        title: title,
        summary: summary,
        content: content,
        categoryId: categoryId,
        imageUrl: imageUrl,
        imageBytes: imageBytes,
        imageName: imageName,
        status: status,
        token: token,
      );
      await fetchFarmerNewsFeed();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAdminArticle(int id) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      final token = await _getEffectiveToken();
      await newsRepo.deleteAdminNews(id, token: token);
      await fetchFarmerNewsFeed();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
