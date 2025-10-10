import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/config/config.dart';
import '../models/invitation_stats_model.dart';
import '../models/invitation_model.dart';
import '../services/invitation_service.dart';

/// Dio provider
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
});

/// Invitation service provider
final invitationServiceProvider = Provider<InvitationService>((ref) {
  final dio = ref.watch(dioProvider);
  return InvitationService(
    dio: dio,
    baseUrl: AppConstants.baseURL,
  );
});

/// Invitation stats provider
final invitationStatsProvider = FutureProvider<InvitationStats>((ref) async {
  final service = ref.watch(invitationServiceProvider);
  return await service.fetchStats();
});

/// My invitations provider
final myInvitationsProvider = FutureProvider<List<Invitation>>((ref) async {
  final service = ref.watch(invitationServiceProvider);
  return await service.fetchMyInvitations(page: 0, size: 10);
});

