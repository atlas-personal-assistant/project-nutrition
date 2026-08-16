// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Space _$SpaceFromJson(Map<String, dynamic> json) {
  return _Space.fromJson(json);
}

/// @nodoc
mixin _$Space {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get ownerUserId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get inviteCode => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Space to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Space
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpaceCopyWith<Space> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpaceCopyWith<$Res> {
  factory $SpaceCopyWith(Space value, $Res Function(Space) then) =
      _$SpaceCopyWithImpl<$Res, Space>;
  @useResult
  $Res call(
      {String id,
      String name,
      String ownerUserId,
      String status,
      String? inviteCode,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$SpaceCopyWithImpl<$Res, $Val extends Space>
    implements $SpaceCopyWith<$Res> {
  _$SpaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Space
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerUserId = null,
    Object? status = null,
    Object? inviteCode = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ownerUserId: null == ownerUserId
          ? _value.ownerUserId
          : ownerUserId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      inviteCode: freezed == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpaceImplCopyWith<$Res> implements $SpaceCopyWith<$Res> {
  factory _$$SpaceImplCopyWith(
          _$SpaceImpl value, $Res Function(_$SpaceImpl) then) =
      __$$SpaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String ownerUserId,
      String status,
      String? inviteCode,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$SpaceImplCopyWithImpl<$Res>
    extends _$SpaceCopyWithImpl<$Res, _$SpaceImpl>
    implements _$$SpaceImplCopyWith<$Res> {
  __$$SpaceImplCopyWithImpl(
      _$SpaceImpl _value, $Res Function(_$SpaceImpl) _then)
      : super(_value, _then);

  /// Create a copy of Space
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerUserId = null,
    Object? status = null,
    Object? inviteCode = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SpaceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ownerUserId: null == ownerUserId
          ? _value.ownerUserId
          : ownerUserId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      inviteCode: freezed == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpaceImpl implements _Space {
  const _$SpaceImpl(
      {required this.id,
      required this.name,
      required this.ownerUserId,
      required this.status,
      this.inviteCode,
      required this.createdAt,
      required this.updatedAt});

  factory _$SpaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpaceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String ownerUserId;
  @override
  final String status;
  @override
  final String? inviteCode;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Space(id: $id, name: $name, ownerUserId: $ownerUserId, status: $status, inviteCode: $inviteCode, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ownerUserId, ownerUserId) ||
                other.ownerUserId == ownerUserId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, ownerUserId, status,
      inviteCode, createdAt, updatedAt);

  /// Create a copy of Space
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpaceImplCopyWith<_$SpaceImpl> get copyWith =>
      __$$SpaceImplCopyWithImpl<_$SpaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpaceImplToJson(
      this,
    );
  }
}

abstract class _Space implements Space {
  const factory _Space(
      {required final String id,
      required final String name,
      required final String ownerUserId,
      required final String status,
      final String? inviteCode,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$SpaceImpl;

  factory _Space.fromJson(Map<String, dynamic> json) = _$SpaceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get ownerUserId;
  @override
  String get status;
  @override
  String? get inviteCode;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Space
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpaceImplCopyWith<_$SpaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SpaceMembership _$SpaceMembershipFromJson(Map<String, dynamic> json) {
  return _SpaceMembership.fromJson(json);
}

/// @nodoc
mixin _$SpaceMembership {
  String get id => throw _privateConstructorUsedError;
  String get spaceId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  User? get user => throw _privateConstructorUsedError;

  /// Serializes this SpaceMembership to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpaceMembership
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpaceMembershipCopyWith<SpaceMembership> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpaceMembershipCopyWith<$Res> {
  factory $SpaceMembershipCopyWith(
          SpaceMembership value, $Res Function(SpaceMembership) then) =
      _$SpaceMembershipCopyWithImpl<$Res, SpaceMembership>;
  @useResult
  $Res call(
      {String id,
      String spaceId,
      String userId,
      String role,
      String status,
      DateTime joinedAt,
      User? user});

  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$SpaceMembershipCopyWithImpl<$Res, $Val extends SpaceMembership>
    implements $SpaceMembershipCopyWith<$Res> {
  _$SpaceMembershipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpaceMembership
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? spaceId = null,
    Object? userId = null,
    Object? role = null,
    Object? status = null,
    Object? joinedAt = null,
    Object? user = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      spaceId: null == spaceId
          ? _value.spaceId
          : spaceId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ) as $Val);
  }

  /// Create a copy of SpaceMembership
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SpaceMembershipImplCopyWith<$Res>
    implements $SpaceMembershipCopyWith<$Res> {
  factory _$$SpaceMembershipImplCopyWith(_$SpaceMembershipImpl value,
          $Res Function(_$SpaceMembershipImpl) then) =
      __$$SpaceMembershipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String spaceId,
      String userId,
      String role,
      String status,
      DateTime joinedAt,
      User? user});

  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$SpaceMembershipImplCopyWithImpl<$Res>
    extends _$SpaceMembershipCopyWithImpl<$Res, _$SpaceMembershipImpl>
    implements _$$SpaceMembershipImplCopyWith<$Res> {
  __$$SpaceMembershipImplCopyWithImpl(
      _$SpaceMembershipImpl _value, $Res Function(_$SpaceMembershipImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpaceMembership
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? spaceId = null,
    Object? userId = null,
    Object? role = null,
    Object? status = null,
    Object? joinedAt = null,
    Object? user = freezed,
  }) {
    return _then(_$SpaceMembershipImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      spaceId: null == spaceId
          ? _value.spaceId
          : spaceId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpaceMembershipImpl implements _SpaceMembership {
  const _$SpaceMembershipImpl(
      {required this.id,
      required this.spaceId,
      required this.userId,
      required this.role,
      required this.status,
      required this.joinedAt,
      this.user});

  factory _$SpaceMembershipImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpaceMembershipImplFromJson(json);

  @override
  final String id;
  @override
  final String spaceId;
  @override
  final String userId;
  @override
  final String role;
  @override
  final String status;
  @override
  final DateTime joinedAt;
  @override
  final User? user;

  @override
  String toString() {
    return 'SpaceMembership(id: $id, spaceId: $spaceId, userId: $userId, role: $role, status: $status, joinedAt: $joinedAt, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpaceMembershipImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.spaceId, spaceId) || other.spaceId == spaceId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, spaceId, userId, role, status, joinedAt, user);

  /// Create a copy of SpaceMembership
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpaceMembershipImplCopyWith<_$SpaceMembershipImpl> get copyWith =>
      __$$SpaceMembershipImplCopyWithImpl<_$SpaceMembershipImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpaceMembershipImplToJson(
      this,
    );
  }
}

abstract class _SpaceMembership implements SpaceMembership {
  const factory _SpaceMembership(
      {required final String id,
      required final String spaceId,
      required final String userId,
      required final String role,
      required final String status,
      required final DateTime joinedAt,
      final User? user}) = _$SpaceMembershipImpl;

  factory _SpaceMembership.fromJson(Map<String, dynamic> json) =
      _$SpaceMembershipImpl.fromJson;

  @override
  String get id;
  @override
  String get spaceId;
  @override
  String get userId;
  @override
  String get role;
  @override
  String get status;
  @override
  DateTime get joinedAt;
  @override
  User? get user;

  /// Create a copy of SpaceMembership
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpaceMembershipImplCopyWith<_$SpaceMembershipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SpaceWithMembers _$SpaceWithMembersFromJson(Map<String, dynamic> json) {
  return _SpaceWithMembers.fromJson(json);
}

/// @nodoc
mixin _$SpaceWithMembers {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get ownerUserId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get inviteCode => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<SpaceMembership> get members => throw _privateConstructorUsedError;

  /// Serializes this SpaceWithMembers to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpaceWithMembers
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpaceWithMembersCopyWith<SpaceWithMembers> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpaceWithMembersCopyWith<$Res> {
  factory $SpaceWithMembersCopyWith(
          SpaceWithMembers value, $Res Function(SpaceWithMembers) then) =
      _$SpaceWithMembersCopyWithImpl<$Res, SpaceWithMembers>;
  @useResult
  $Res call(
      {String id,
      String name,
      String ownerUserId,
      String status,
      String? inviteCode,
      DateTime createdAt,
      DateTime updatedAt,
      List<SpaceMembership> members});
}

/// @nodoc
class _$SpaceWithMembersCopyWithImpl<$Res, $Val extends SpaceWithMembers>
    implements $SpaceWithMembersCopyWith<$Res> {
  _$SpaceWithMembersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpaceWithMembers
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerUserId = null,
    Object? status = null,
    Object? inviteCode = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? members = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ownerUserId: null == ownerUserId
          ? _value.ownerUserId
          : ownerUserId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      inviteCode: freezed == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      members: null == members
          ? _value.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<SpaceMembership>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpaceWithMembersImplCopyWith<$Res>
    implements $SpaceWithMembersCopyWith<$Res> {
  factory _$$SpaceWithMembersImplCopyWith(_$SpaceWithMembersImpl value,
          $Res Function(_$SpaceWithMembersImpl) then) =
      __$$SpaceWithMembersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String ownerUserId,
      String status,
      String? inviteCode,
      DateTime createdAt,
      DateTime updatedAt,
      List<SpaceMembership> members});
}

/// @nodoc
class __$$SpaceWithMembersImplCopyWithImpl<$Res>
    extends _$SpaceWithMembersCopyWithImpl<$Res, _$SpaceWithMembersImpl>
    implements _$$SpaceWithMembersImplCopyWith<$Res> {
  __$$SpaceWithMembersImplCopyWithImpl(_$SpaceWithMembersImpl _value,
      $Res Function(_$SpaceWithMembersImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpaceWithMembers
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerUserId = null,
    Object? status = null,
    Object? inviteCode = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? members = null,
  }) {
    return _then(_$SpaceWithMembersImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ownerUserId: null == ownerUserId
          ? _value.ownerUserId
          : ownerUserId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      inviteCode: freezed == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      members: null == members
          ? _value._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<SpaceMembership>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpaceWithMembersImpl implements _SpaceWithMembers {
  const _$SpaceWithMembersImpl(
      {required this.id,
      required this.name,
      required this.ownerUserId,
      required this.status,
      this.inviteCode,
      required this.createdAt,
      required this.updatedAt,
      required final List<SpaceMembership> members})
      : _members = members;

  factory _$SpaceWithMembersImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpaceWithMembersImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String ownerUserId;
  @override
  final String status;
  @override
  final String? inviteCode;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final List<SpaceMembership> _members;
  @override
  List<SpaceMembership> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  String toString() {
    return 'SpaceWithMembers(id: $id, name: $name, ownerUserId: $ownerUserId, status: $status, inviteCode: $inviteCode, createdAt: $createdAt, updatedAt: $updatedAt, members: $members)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpaceWithMembersImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ownerUserId, ownerUserId) ||
                other.ownerUserId == ownerUserId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._members, _members));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      ownerUserId,
      status,
      inviteCode,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_members));

  /// Create a copy of SpaceWithMembers
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpaceWithMembersImplCopyWith<_$SpaceWithMembersImpl> get copyWith =>
      __$$SpaceWithMembersImplCopyWithImpl<_$SpaceWithMembersImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpaceWithMembersImplToJson(
      this,
    );
  }
}

abstract class _SpaceWithMembers implements SpaceWithMembers {
  const factory _SpaceWithMembers(
      {required final String id,
      required final String name,
      required final String ownerUserId,
      required final String status,
      final String? inviteCode,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final List<SpaceMembership> members}) = _$SpaceWithMembersImpl;

  factory _SpaceWithMembers.fromJson(Map<String, dynamic> json) =
      _$SpaceWithMembersImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get ownerUserId;
  @override
  String get status;
  @override
  String? get inviteCode;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  List<SpaceMembership> get members;

  /// Create a copy of SpaceWithMembers
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpaceWithMembersImplCopyWith<_$SpaceWithMembersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String id,
      String email,
      String displayName,
      String status,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String displayName,
      String status,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      required this.email,
      required this.displayName,
      required this.status,
      required this.createdAt,
      required this.updatedAt});

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String displayName;
  @override
  final String status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, email, displayName, status, createdAt, updatedAt);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String id,
      required final String email,
      required final String displayName,
      required final String status,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get displayName;
  @override
  String get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateSpaceRequest _$CreateSpaceRequestFromJson(Map<String, dynamic> json) {
  return _CreateSpaceRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateSpaceRequest {
  String get name => throw _privateConstructorUsedError;

  /// Serializes this CreateSpaceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateSpaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateSpaceRequestCopyWith<CreateSpaceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSpaceRequestCopyWith<$Res> {
  factory $CreateSpaceRequestCopyWith(
          CreateSpaceRequest value, $Res Function(CreateSpaceRequest) then) =
      _$CreateSpaceRequestCopyWithImpl<$Res, CreateSpaceRequest>;
  @useResult
  $Res call({String name});
}

/// @nodoc
class _$CreateSpaceRequestCopyWithImpl<$Res, $Val extends CreateSpaceRequest>
    implements $CreateSpaceRequestCopyWith<$Res> {
  _$CreateSpaceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateSpaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateSpaceRequestImplCopyWith<$Res>
    implements $CreateSpaceRequestCopyWith<$Res> {
  factory _$$CreateSpaceRequestImplCopyWith(_$CreateSpaceRequestImpl value,
          $Res Function(_$CreateSpaceRequestImpl) then) =
      __$$CreateSpaceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name});
}

/// @nodoc
class __$$CreateSpaceRequestImplCopyWithImpl<$Res>
    extends _$CreateSpaceRequestCopyWithImpl<$Res, _$CreateSpaceRequestImpl>
    implements _$$CreateSpaceRequestImplCopyWith<$Res> {
  __$$CreateSpaceRequestImplCopyWithImpl(_$CreateSpaceRequestImpl _value,
      $Res Function(_$CreateSpaceRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateSpaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
  }) {
    return _then(_$CreateSpaceRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateSpaceRequestImpl implements _CreateSpaceRequest {
  const _$CreateSpaceRequestImpl({required this.name});

  factory _$CreateSpaceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateSpaceRequestImplFromJson(json);

  @override
  final String name;

  @override
  String toString() {
    return 'CreateSpaceRequest(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateSpaceRequestImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of CreateSpaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateSpaceRequestImplCopyWith<_$CreateSpaceRequestImpl> get copyWith =>
      __$$CreateSpaceRequestImplCopyWithImpl<_$CreateSpaceRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateSpaceRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateSpaceRequest implements CreateSpaceRequest {
  const factory _CreateSpaceRequest({required final String name}) =
      _$CreateSpaceRequestImpl;

  factory _CreateSpaceRequest.fromJson(Map<String, dynamic> json) =
      _$CreateSpaceRequestImpl.fromJson;

  @override
  String get name;

  /// Create a copy of CreateSpaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateSpaceRequestImplCopyWith<_$CreateSpaceRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JoinSpaceRequest _$JoinSpaceRequestFromJson(Map<String, dynamic> json) {
  return _JoinSpaceRequest.fromJson(json);
}

/// @nodoc
mixin _$JoinSpaceRequest {
  String get inviteCode => throw _privateConstructorUsedError;

  /// Serializes this JoinSpaceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JoinSpaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JoinSpaceRequestCopyWith<JoinSpaceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JoinSpaceRequestCopyWith<$Res> {
  factory $JoinSpaceRequestCopyWith(
          JoinSpaceRequest value, $Res Function(JoinSpaceRequest) then) =
      _$JoinSpaceRequestCopyWithImpl<$Res, JoinSpaceRequest>;
  @useResult
  $Res call({String inviteCode});
}

/// @nodoc
class _$JoinSpaceRequestCopyWithImpl<$Res, $Val extends JoinSpaceRequest>
    implements $JoinSpaceRequestCopyWith<$Res> {
  _$JoinSpaceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JoinSpaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inviteCode = null,
  }) {
    return _then(_value.copyWith(
      inviteCode: null == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JoinSpaceRequestImplCopyWith<$Res>
    implements $JoinSpaceRequestCopyWith<$Res> {
  factory _$$JoinSpaceRequestImplCopyWith(_$JoinSpaceRequestImpl value,
          $Res Function(_$JoinSpaceRequestImpl) then) =
      __$$JoinSpaceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String inviteCode});
}

/// @nodoc
class __$$JoinSpaceRequestImplCopyWithImpl<$Res>
    extends _$JoinSpaceRequestCopyWithImpl<$Res, _$JoinSpaceRequestImpl>
    implements _$$JoinSpaceRequestImplCopyWith<$Res> {
  __$$JoinSpaceRequestImplCopyWithImpl(_$JoinSpaceRequestImpl _value,
      $Res Function(_$JoinSpaceRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of JoinSpaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inviteCode = null,
  }) {
    return _then(_$JoinSpaceRequestImpl(
      inviteCode: null == inviteCode
          ? _value.inviteCode
          : inviteCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JoinSpaceRequestImpl implements _JoinSpaceRequest {
  const _$JoinSpaceRequestImpl({required this.inviteCode});

  factory _$JoinSpaceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$JoinSpaceRequestImplFromJson(json);

  @override
  final String inviteCode;

  @override
  String toString() {
    return 'JoinSpaceRequest(inviteCode: $inviteCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JoinSpaceRequestImpl &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, inviteCode);

  /// Create a copy of JoinSpaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JoinSpaceRequestImplCopyWith<_$JoinSpaceRequestImpl> get copyWith =>
      __$$JoinSpaceRequestImplCopyWithImpl<_$JoinSpaceRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JoinSpaceRequestImplToJson(
      this,
    );
  }
}

abstract class _JoinSpaceRequest implements JoinSpaceRequest {
  const factory _JoinSpaceRequest({required final String inviteCode}) =
      _$JoinSpaceRequestImpl;

  factory _JoinSpaceRequest.fromJson(Map<String, dynamic> json) =
      _$JoinSpaceRequestImpl.fromJson;

  @override
  String get inviteCode;

  /// Create a copy of JoinSpaceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JoinSpaceRequestImplCopyWith<_$JoinSpaceRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
