// lib/core/routing/routes.dart

class Routes {
  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH ROUTES
  // ═══════════════════════════════════════════════════════════════════════════
  static const splash = '/splash';
  static const login = '/login';
  static const setUsername = '/set-username';

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN ROUTES
  // ═══════════════════════════════════════════════════════════════════════════
  static const home = '/';
  static const feed = '/feed';
  static const discover = '/discover';
  static const search = '/search';

  // ═══════════════════════════════════════════════════════════════════════════
  // ANCHOR ROUTES
  // ═══════════════════════════════════════════════════════════════════════════
  static const anchors = '/anchors';
  static const anchorDetail = '/anchors/:anchorId';
  static const anchorDetailName = 'anchor_detail';
  static const createAnchor = '/anchors/create';
  static const editAnchor = '/anchors/:anchorId/edit';
  static const editAnchorName = 'anchor_edit';

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE ROUTES
  // ═══════════════════════════════════════════════════════════════════════════
  static const profile = '/profile';
  static const userProfile = '/users/:userId';
  static const userProfileName = 'user_profile';
  static const userProfileByUsername = '/u/:username';
  static const userProfileByUsernameName = 'user_profile_by_username';
  static const editProfile = '/profile/edit';
  static const myAnchors = '/profile/anchors';
  static const myLikes = '/profile/likes';
  static const myClones = '/profile/clones';
  static const followers = '/profile/followers';
  static const following = '/profile/following';

  // ═══════════════════════════════════════════════════════════════════════════
  // SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════
  static const settings = '/settings';
  static const notifications = '/notifications';

  // ═══════════════════════════════════════════════════════════════════════════
  // PATH BUILDERS (with parameters)
  // ═══════════════════════════════════════════════════════════════════════════

  /// /anchors/{id}
  static String anchorDetailPath(String id) => '/anchors/$id';

  /// /anchors/{id}/edit
  static String editAnchorPath(String id) => '/anchors/$id/edit';

  /// /users/{id}
  static String userProfilePath(String userId) => '/users/$userId';

  /// /u/{username}
  static String userProfileByUsernamePath(String username) => '/u/$username';

  /// /users/{id}/followers
  static String userFollowersPath(String userId) => '/users/$userId/followers';

  /// /users/{id}/following
  static String userFollowingPath(String userId) => '/users/$userId/following';
}
