// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpaceImpl _$$SpaceImplFromJson(Map<String, dynamic> json) => _$SpaceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerUserId: json['ownerUserId'] as String,
      status: json['status'] as String,
      inviteCode: json['inviteCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SpaceImplToJson(_$SpaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerUserId': instance.ownerUserId,
      'status': instance.status,
      'inviteCode': instance.inviteCode,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$SpaceMembershipImpl _$$SpaceMembershipImplFromJson(
        Map<String, dynamic> json) =>
    _$SpaceMembershipImpl(
      id: json['id'] as String,
      spaceId: json['spaceId'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SpaceMembershipImplToJson(
        _$SpaceMembershipImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'spaceId': instance.spaceId,
      'userId': instance.userId,
      'role': instance.role,
      'status': instance.status,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'user': instance.user,
    };

_$SpaceWithMembersImpl _$$SpaceWithMembersImplFromJson(
        Map<String, dynamic> json) =>
    _$SpaceWithMembersImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerUserId: json['ownerUserId'] as String,
      status: json['status'] as String,
      inviteCode: json['inviteCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      members: (json['members'] as List<dynamic>)
          .map((e) => SpaceMembership.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SpaceWithMembersImplToJson(
        _$SpaceWithMembersImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerUserId': instance.ownerUserId,
      'status': instance.status,
      'inviteCode': instance.inviteCode,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'members': instance.members,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$CreateSpaceRequestImpl _$$CreateSpaceRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateSpaceRequestImpl(
      name: json['name'] as String,
    );

Map<String, dynamic> _$$CreateSpaceRequestImplToJson(
        _$CreateSpaceRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

_$JoinSpaceRequestImpl _$$JoinSpaceRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$JoinSpaceRequestImpl(
      inviteCode: json['inviteCode'] as String,
    );

Map<String, dynamic> _$$JoinSpaceRequestImplToJson(
        _$JoinSpaceRequestImpl instance) =>
    <String, dynamic>{
      'inviteCode': instance.inviteCode,
    };
