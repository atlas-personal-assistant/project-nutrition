import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/space_models.dart';
import '../../../core/services/api_space_service.dart';

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
      error: error,
    );
  }
}

// Space Notifier
class SpaceNotifier extends StateNotifier<SpaceState> {
  SpaceNotifier() : super(const SpaceState());

  Future<void> loadSpaces() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final spacesData = await ApiSpaceService.getSpaces();
      final spaces = spacesData.map((json) => Space.fromJson(json)).toList();
      
      state = state.copyWith(
        spaces: spaces,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Fehler beim Laden: $e');
    }
  }

  Future<void> createSpace({required String name, String description = ''}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final newSpaceData = await ApiSpaceService.createSpace(
        name: name,
        description: description,
      );
      final newSpace = Space.fromJson(newSpaceData);
      
      state = state.copyWith(
        spaces: [...state.spaces, newSpace],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Fehler beim Erstellen: $e');
    }
  }

  Future<void> joinSpace({required String inviteCode}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final joinedSpaceData = await ApiSpaceService.joinSpace(inviteCode: inviteCode);
      final joinedSpace = Space.fromJson(joinedSpaceData);
      
      state = state.copyWith(
        spaces: [...state.spaces, joinedSpace],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Fehler beim Beitreten: $e');
    }
  }

  Future<void> getSpaceDetails(String spaceId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Suche Space in lokaler Liste
      final space = state.spaces.firstWhere(
        (s) => s.id == spaceId,
        orElse: () => throw Exception('Space nicht gefunden'),
      );
      
      // Erstelle SpaceWithMembers (ohne echte Mitglieder)
      final spaceWithMembers = SpaceWithMembers(
        id: space.id,
        name: space.name,
        inviteCode: space.inviteCode,
        createdAt: space.createdAt,
        updatedAt: space.updatedAt,
        ownerUserId: 'current_user',
        status: 'active',
        members: [],
      );
      
      state = state.copyWith(
        currentSpace: spaceWithMembers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Fehler beim Laden: $e');
    }
  }

  // Debug: Lösche alle Spaces (nur lokal, API hat keinen clearAll)
  Future<void> clearAll() async {
    state = const SpaceState();
  }
}

// Providers
final spaceProvider = StateNotifierProvider<SpaceNotifier, SpaceState>((ref) {
  return SpaceNotifier();
});
