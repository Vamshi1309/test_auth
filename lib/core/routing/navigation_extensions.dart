// lib/core/routing/navigation_extensions.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pod/core/routing/routes.dart';

/// Extension methods for easy navigation
extension NavigationExtensions on BuildContext {
  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════
  void goToLogin() => go(Routes.login);
  void goToSetUsername() => go(Routes.setUsername);

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════
  void goToHome() => go(Routes.home);
  void goToFeed() => go(Routes.feed);
  void goToDiscover() => go(Routes.discover);
  void goToSearch() => go(Routes.search);
  void goToNotifications() => go(Routes.notifications);

  // ═══════════════════════════════════════════════════════════════════════════
  // ANCHOR NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════
  void goToCreateAnchor() => push(Routes.createAnchor);
  void goToAnchorDetail(String id) => push(Routes.anchorDetailPath(id));
  void goToEditAnchor(String id) => push(Routes.editAnchorPath(id));

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════
  void goToProfile() => go(Routes.profile);
  void goToUserProfile(String userId) => push(Routes.userProfilePath(userId));
  void goToUserProfileByUsername(String username) =>
      push(Routes.userProfileByUsernamePath(username));
  void goToEditProfile() => push(Routes.editProfile);
  void goToMyAnchors() => push(Routes.myAnchors);
  void goToMyLikes() => push(Routes.myLikes);
  void goToMyClones() => push(Routes.myClones);
  void goToFollowers(String userId) => push(Routes.userFollowersPath(userId));
  void goToFollowing(String userId) => push(Routes.userFollowingPath(userId));
  void goToSettings() => push(Routes.settings);

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERIC NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════
  void goBack() => pop();
  void goBackWithResult<T>(T result) => pop(result);
  void replaceWithHome() => replace(Routes.home);
  void replaceWithLogin() => replace(Routes.login);
}
