import 'package:flutter/material.dart';
import '../models/news_category_model.dart';
import '../models/news_article_model.dart';
import '../models/subscription_model.dart';
import '../repos/news_repo.dart';
import '../repos/subscription_repo.dart';

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

  NewsController({
    required this.newsRepo,
    required this.subscriptionRepo,
    this.userToken,
  });

  List<NewsCategoryModel> get categories => _categories;
  NewsCategoryModel? get selectedCategory => _selectedCategory;
  List<NewsArticleModel> get articles => _articles;
  List<SubscriptionModel> get subscriptions => _subscriptions;
  Set<int> get subscribedCategoryIds => _subscribedCategoryIds;
  NewsArticleModel? get selectedArticle => _selectedArticle;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> init() async {
    await Future.wait([
      fetchCategories(),
      fetchSubscriptions(),
      fetchFarmerNewsFeed(),
    ]);
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await newsRepo.getCategories(token: userToken);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> fetchSubscriptions() async {
    try {
      _subscriptions = await subscriptionRepo.getSubscriptions(token: userToken);
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
      _articles = await newsRepo.getFarmerNewsFeed(
        categoryId: _selectedCategory?.id,
        search: _searchQuery,
        token: userToken,
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
      _selectedArticle = await newsRepo.getNewsDetail(id, token: userToken);
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
      final isSubbed = _subscribedCategoryIds.contains(categoryId);
      if (isSubbed) {
        final sub = _subscriptions.firstWhere((s) => s.category.id == categoryId);
        await subscriptionRepo.unsubscribe(sub.id, token: userToken);
        _subscriptions.removeWhere((s) => s.id == sub.id);
        _subscribedCategoryIds.remove(categoryId);
      } else {
        final newSub = await subscriptionRepo.subscribe(categoryId, token: userToken);
        _subscriptions.add(newSub);
        _subscribedCategoryIds.add(categoryId);
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

  // Admin Methods
  Future<List<NewsArticleModel>> fetchAdminNewsList() async {
    _isLoading = true;
    notifyListeners();
    try {
      return await newsRepo.getAdminNewsList(token: userToken);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return [];
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
    String status = 'DRAFT',
  }) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await newsRepo.createAdminNews(
        title: title,
        summary: summary,
        content: content,
        categoryId: categoryId,
        imageUrl: imageUrl,
        status: status,
        token: userToken,
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
      await newsRepo.publishAdminNews(id, token: userToken);
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
      await newsRepo.deleteAdminNews(id, token: userToken);
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
