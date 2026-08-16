import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/space_models.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

// Space state
class SpaceState {
  final List<Space> spaces;
  final SpaceWithMembers? currentSpace;
  final bool isLoading;
  final String? error;

  const SpaceState({
    this.spaces = const [],
    this.currentSpace,
    this.isLoading = false,
    this.error,
  });

  SpaceState copyWith({
    List<Space>? spaces,
    SpaceWithMembers? currentSpace,
    bool? isLoading,
    String? error,
  }) {
    return SpaceState(
      spaces: spaces ?? this.spaces,
      currentSpace: currentSpace ?? this.currentSpace,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Space Notifier
class SpaceNotifier extends StateNotifier<SpaceState> {
  final DioClient _dioClient;

  SpaceNotifier({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient(),
        super(const SpaceState());

  Future<void> loadSpaces() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _dioClient.dio.get(ApiConstants.spaces);
      final spaces = (response.data as List)
          .map((json) => Space.fromJson(json))
          .toList();
      
      state = state.copyWith(
        spaces: spaces,
        isLoading: false,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? 'Failed to load spaces';
      state = state.copyWith(isLoading: false, error: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
    }
  }

  Future<void> createSpace({required String name}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.spaces,
        data: {'name': name},
      );
      
      final newSpace = Space.fromJson(response.data);
      
      state = state.copyWith(
        spaces: [...state.spaces, newSpace],
        isLoading: false,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? 'Failed to create space';
      state = state.copyWith(isLoading: false, error: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
    }
  }

  Future<void> joinSpace({required String inviteCode}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.joinSpace,
        data: {'invite_code': inviteCode},
      );
      
      final joinedSpace = Space.fromJson(response.data);
      
      state = state.copyWith(
        spaces: [...state.spaces, joinedSpace],
        isLoading: false,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? 'Failed to join space';
      state = state.copyWith(isLoading: false, error: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
    }
  }

  Future<void> getSpaceDetails(String spaceId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _dioClient.dio.get('${ApiConstants.spaces}/$spaceId');
      final space = SpaceWithMembers.fromJson(response.data);
      
      state = state.copyWith(
        currentSpace: space,
        isLoading: false,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? 'Failed to load space details';
      state = state.copyWith(isLoading: false, error: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
    }
  }
}

// Providers
final spaceProvider = StateNotifierProvider<SpaceNotifier, SpaceState>((ref) {
  return SpaceNotifier();
});