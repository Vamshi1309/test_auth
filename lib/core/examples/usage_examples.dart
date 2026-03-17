// // lib/core/examples/usage_examples.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:pod/core/config/app_config.dart';
// import 'package:pod/core/network/api_service_provider.dart';
// import 'package:pod/core/utils/snackbar.dart';
// import 'package:pod/core/error/failures.dart';
// import 'package:pod/core/routing/navigation_extensions.dart';
// import 'package:pod/core/utils/helpers/shared_prefs.dart';

// part 'usage_examples.g.dart';

// class ExampleApiWidget extends ConsumerWidget {
//   const ExampleApiWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ElevatedButton(
//       onPressed: () async {
//         final api = ref.read(apiServiceProvider.notifier);
//         try {
//           // GET
//           final user = await api.get(AppConfig.me);
//           print('User: $user');

//           // POST
//           final newUser = await api.post(
//             AppConfig.register,
//             data: {'name': 'John', 'email': 'john@example.com'},
//           );
//           print('Created user: $newUser');

//           // PATCH
//           await api.patch(
//             AppConfig.updateProfile,
//             data: {'name': 'Jane'},
//           );

//           // DELETE
//           await api.delete('/users/123');

//           AppSnackBar.success(context, 'All operations successful!');
//         } catch (e) {
//           if (e is NetworkFailure) {
//             AppSnackBar.error(context, 'No internet connection');
//           } else if (e is UnauthorizedFailure) {
//             AppSnackBar.error(context, 'Session expired');
//             context.goToLogin();
//           } else {
//             AppSnackBar.error(context, e.toString());
//           }
//         }
//       },
//       child: const Text('Test API'),
//     );
//   }
// }

// class ExampleNavigationWidget extends StatelessWidget {
//   const ExampleNavigationWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: () => context.goToHome(),
//           child: const Text('Go Home'),
//         ),
//         ElevatedButton(
//           onPressed: () => context.goToProductDetail('123'),
//           child: const Text('View Product 123'),
//         ),
//         ElevatedButton(
//           onPressed: () => context.pushToProductDetail('456'),
//           child: const Text('Push Product 456'),
//         ),
//         ElevatedButton(
//           onPressed: () => context.goBack(),
//           child: const Text('Go Back'),
//         ),
//       ],
//     );
//   }
// }

// @riverpod
// class UserRepository extends _$UserRepository {
//   @override
//   void build() {}

//   Future<Map<String, dynamic>> getCurrentUser() async {
//     final api = ref.read(apiServiceProvider.notifier);
//     return await api.get(AppConfig.me) as Map<String, dynamic>;
//   }

//   Future<void> updateProfile(String name) async {
//     final api = ref.read(apiServiceProvider.notifier);
//     await api.patch(AppConfig.updateProfile, data: {'name': name});
//   }

//   Future<void> logout() async {
//     final prefs = await ref.read(sharedPrefsProvider.future);
//     await prefs.clearAll();
//     final nav = NavigationService(ref);
//     nav.goToLogin();
//   }
// }

// @riverpod
// class Products extends _$Products {
//   @override
//   Future<List<Map<String, dynamic>>> build() => _fetch();

//   Future<List<Map<String, dynamic>>> _fetch() async {
//     final api = ref.read(apiServiceProvider.notifier);
//     final response = await api.get(AppConfig.products);
//     return (response as List).cast<Map<String, dynamic>>();
//   }

//   Future<void> addProduct(Map<String, dynamic> product) async {
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final api = ref.read(apiServiceProvider.notifier);
//       await api.post(AppConfig.products, data: product);
//       return _fetch();
//     });
//   }

//   Future<void> deleteProduct(String id) async {
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final api = ref.read(apiServiceProvider.notifier);
//       await api.delete(AppConfig.deleteProduct(id));
//       return _fetch();
//     });
//   }
// }

// class ProductsScreen extends ConsumerWidget {
//   const ProductsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final productsAsync = ref.watch(productsProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Products')),
//       body: productsAsync.when(
//         data: (products) => ListView.builder(
//           itemCount: products.length,
//           itemBuilder: (context, index) {
//             final product = products[index];
//             return ListTile(
//               title: Text(product['name'] ?? ''),
//               onTap: () => context.goToProductDetail(product['id']),
//             );
//           },
//         ),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(child: Text('Error: $error')),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await ref.read(productsProvider.notifier).addProduct({
//             'name': 'New Product',
//             'price': 99.99,
//           });
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
