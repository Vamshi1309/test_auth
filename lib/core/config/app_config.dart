// lib/core/config/app_config.dart

enum Environment { dev, staging, prod }

class AppConfig {
  static late Environment _env;

  static void init(Environment env) => _env = env;

  // ═══════════════════════════════════════════════════════════════════════════
  // BASE URL
  // ═══════════════════════════════════════════════════════════════════════════
  static String get baseUrl {
    return switch (_env) {
      Environment.dev => 'http://localhost:8080/api/v1',
      Environment.staging => 'https://staging-api.anchorapp.io/api/v1',
      Environment.prod => 'https://api.anchorapp.io/api/v1',
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. AUTHENTICATION (5 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════
  static String get authGoogle => '/auth/google';
  static String get authMe => '/auth/me';
  static String get authSetUsername => '/auth/username';
  static String get authCheckUsername =>
      '/auth/username/check'; // ?username=xxx
  static String get authRefresh => '/auth/refresh';

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. ANCHORS (11 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════
  static String get anchors => '/anchors';
  static String anchor(String id) => '/anchors/$id';
  static String anchorPin(String id) => '/anchors/$id/pin';
  static String anchorItems(String id) => '/anchors/$id/items';
  static String anchorItem(String anchorId, String itemId) =>
      '/anchors/$anchorId/items/$itemId';
  static String anchorItemsReorder(String id) => '/anchors/$id/items/reorder';
  static String anchorClone(String id) => '/anchors/$id/clone';
  static String anchorClones(String id) => '/anchors/$id/clones';
  static String anchorLike(String id) => '/anchors/$id/like';
  static String anchorLikeStatus(String id) => '/anchors/$id/like/status';
  static String anchorLikeSummary(String id) => '/anchors/$id/like/summary';
  static String anchorComments(String id) => '/anchors/$id/comments';

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. FOLLOWS (3 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════
  static String userFollow(String userId) => '/users/$userId/follow';
  static String userFollowers(String userId) => '/users/$userId/followers';
  static String userFollowing(String userId) => '/users/$userId/following';

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. USER PROFILE (9 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════
  static String user(String id) => '/users/$id';
  static String userByUsername(String username) => '/users/username/$username';
  static String get usersMe => '/users/me';
  static String userAnchors(String userId) => '/users/$userId/anchors';
  static String userLikes(String userId) => '/users/$userId/likes';
  static String get myLikes => '/users/me/likes';
  static String userClones(String userId) => '/users/$userId/clones';
  static String get myClones => '/users/me/clones';
  static String userStats(String userId) => '/users/$userId/stats';

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. COMMENTS (7 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════
  static String comment(String id) => '/comments/$id';
  static String commentLike(String id) => '/comments/$id/like';
  static String commentLikeStatus(String id) => '/comments/$id/like/status';

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. NOTIFICATIONS (4 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════
  static String get notifications => '/notifications';
  static String get notificationsUnreadCount => '/notifications/unread-count';
  static String notificationRead(String id) => '/notifications/$id/read';
  static String get notificationsReadAll => '/notifications/read-all';

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. FEED (2 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════
  static String get feedHome => '/feed/home';
  static String get feedDiscover => '/feed/discover';

  // ═══════════════════════════════════════════════════════════════════════════
  // 8. SEARCH (4 endpoints)
  // ═══════════════════════════════════════════════════════════════════════════
  static String get search => '/search';
  static String get searchAnchors => '/search/anchors';
  static String get searchUsers => '/search/users';
  static String get searchTags => '/search/tags';

  // ═══════════════════════════════════════════════════════════════════════════
  // APP METADATA
  // ═══════════════════════════════════════════════════════════════════════════
  static String get appName => 'Anchor';
  static String get appVersion => '1.0.0';

  // Google OAuth - Server Client ID (from Firebase Console)
  static String get googleServerClientId =>
      '653037413028-j0b95j6pgstspoonbq09cbfpkgkn2r7a.apps.googleusercontent.com';

  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE FLAGS
  // ═══════════════════════════════════════════════════════════════════════════
  static bool get isDebug => _env != Environment.prod;
  static bool get enableLogging => _env != Environment.prod;
  static bool get enableAnalytics => _env == Environment.prod;

  // ═══════════════════════════════════════════════════════════════════════════
  // TIMEOUTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);
  static const sendTimeout = Duration(seconds: 60); // Longer for image uploads

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const defaultPageSize = 20;
  static const maxPageSize = 50;

  // ═══════════════════════════════════════════════════════════════════════════
  // LIMITS
  // ═══════════════════════════════════════════════════════════════════════════
  static const maxPinnedAnchors = 3;
  static const maxTagsPerAnchor = 5;
  static const maxItemsPerAnchor = 100;

  // Current environment
  static String get environmentName => _env.name;
}
