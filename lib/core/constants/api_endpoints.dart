class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.agriassist.example.com/v1';

  // Endpoint routes placeholders
  static const String getWeather = '$baseUrl/weather';
  static const String getPredictionHistory = '$baseUrl/predictions/history';
  static const String predictCrop = 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/crop/';
  static const String predictFertilizer = 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/fertilizer/';
  static const String getCrops = 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/crops/';
  static const String getFertilizers = 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/fertilizers/';
  static const String cropHistory = 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/crop-history/';
  static const String fertilizerHistory = 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/fertilizer-history/';
  static String cropHistoryDetail(dynamic id) => 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/crop-history/$id/';
  static String fertilizerHistoryDetail(dynamic id) => 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/fertilizer-history/$id/';
  static const String login = 'https://unknotted-unknown-heat.ngrok-free.dev/api/accounts/login/';
  static const String logout = 'https://unknotted-unknown-heat.ngrok-free.dev/api/accounts/logout/';
  static const String profile = 'https://unknotted-unknown-heat.ngrok-free.dev/api/accounts/profile/';
  static const String register = 'https://unknotted-unknown-heat.ngrok-free.dev/api/accounts/register/';
  static const String refreshToken = 'https://unknotted-unknown-heat.ngrok-free.dev/api/accounts/token/refresh/';

  // Analytics Endpoints
  static const String analyticsKpis = 'https://unknotted-unknown-heat.ngrok-free.dev/api/analytics/kpis/';
  static const String analyticsFertilizerDemand = 'https://unknotted-unknown-heat.ngrok-free.dev/api/analytics/fertilizer-demand/';
  static const String analyticsSoilAcidity = 'https://unknotted-unknown-heat.ngrok-free.dev/api/analytics/soil-acidity-hotspots/';
  static const String analyticsCropDistribution = 'https://unknotted-unknown-heat.ngrok-free.dev/api/analytics/crop-distribution/';
  static const String analyticsUsageTrends = 'https://unknotted-unknown-heat.ngrok-free.dev/api/analytics/usage-trends/';

  // News, Subscriptions & Notifications Endpoints
  static const String newsCategories = 'https://unknotted-unknown-heat.ngrok-free.dev/api/news/categories/';
  static const String farmerNewsFeed = 'https://unknotted-unknown-heat.ngrok-free.dev/api/news/';
  static String farmerNewsDetail(int id) => 'https://unknotted-unknown-heat.ngrok-free.dev/api/news/$id/';
  static const String subscriptions = 'https://unknotted-unknown-heat.ngrok-free.dev/api/subscriptions/';
  static String unsubscribeTopic(int id) => 'https://unknotted-unknown-heat.ngrok-free.dev/api/subscriptions/$id/';
  static const String notifications = 'https://unknotted-unknown-heat.ngrok-free.dev/api/notifications/';
  static const String notificationsUnreadCount = 'https://unknotted-unknown-heat.ngrok-free.dev/api/notifications/unread-count/';
  static String markNotificationRead(int id) => 'https://unknotted-unknown-heat.ngrok-free.dev/api/notifications/$id/read/';
  static const String markAllNotificationsRead = 'https://unknotted-unknown-heat.ngrok-free.dev/api/notifications/read-all/';
  static const String adminNews = 'https://unknotted-unknown-heat.ngrok-free.dev/api/admin/news/';
  static String adminNewsDetail(int id) => 'https://unknotted-unknown-heat.ngrok-free.dev/api/admin/news/$id/';
  static String adminPublishNews(int id) => 'https://unknotted-unknown-heat.ngrok-free.dev/api/admin/news/$id/publish/';
}

