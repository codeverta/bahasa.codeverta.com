import 'package:bahasa_master/core/network/dio_client.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/features/home/data/home_repository.dart';
import 'package:bahasa_master/features/home/domain/home_dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(dioProvider));
});

final homeDashboardProvider = FutureProvider.autoDispose<HomeDashboard>((ref) {
  ref.watch(authControllerProvider.select((state) => state.user?.id));
  return ref.watch(homeRepositoryProvider).fetchDashboard();
});
