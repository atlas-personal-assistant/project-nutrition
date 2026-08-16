import 'package:freezed_annotation/freezed_annotation.dart';

part 'space_models.freezed.dart';
part 'space_models.g.dart';

@freezed
class Space with _$Space {
  const factory Space({
    required String id,
    required String name,
    required String ownerUserId,
    required String status,
    String? inviteCode,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Space;

  factory Space.fromJson(Map<String, dynamic> json) => _$SpaceFromJson(json);
}

@freezed
class SpaceMembership with _$SpaceMembership {
  const factory SpaceMembership({
    required String id,
    required String spaceId,
    required String userId,
    required String role,
    required String status,
    required DateTime joinedAt,
    User? user,
  }) = _SpaceMembership;

  factory SpaceMembership.fromJson(Map<String, dynamic> json) => _$SpaceMembershipFromJson(json);
}

@freezed
class SpaceWithMembers with _$SpaceWithMembers {
  const factory SpaceWithMembers({
    required String id,
    required String name,
    required String ownerUserId,
    required String status,
    String? inviteCode,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<SpaceMembership> members,
  }) = _SpaceWithMembers;

  factory SpaceWithMembers.fromJson(Map<String, dynamic> json) => _$SpaceWithMembersFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String displayName,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class CreateSpaceRequest with _$CreateSpaceRequest {
  const factory CreateSpaceRequest({
    required String name,
  }) = _CreateSpaceRequest;

  factory CreateSpaceRequest.fromJson(Map<String, dynamic> json) => _$CreateSpaceRequestFromJson(json);
}

@freezed
class JoinSpaceRequest with _$JoinSpaceRequest {
  const factory JoinSpaceRequest({
    required String inviteCode,
  }) = _JoinSpaceRequest;

  factory JoinSpaceRequest.fromJson(Map<String, dynamic> json) => _$JoinSpaceRequestFromJson(json);
}