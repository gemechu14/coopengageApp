// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MeetingModel _$MeetingModelFromJson(Map<String, dynamic> json) {
  return _MeetingModel.fromJson(json);
}

/// @nodoc
mixin _$MeetingModel {
  @JsonKey(name: "meetingId")
  int get meetingId => throw _privateConstructorUsedError;
  @JsonKey(name: "highProfileCustomerName")
  String get highProfileCustomerName => throw _privateConstructorUsedError;
  @JsonKey(name: "crmName")
  String get crmName => throw _privateConstructorUsedError;
  @JsonKey(name: "meetingDate")
  String get meetingDate => throw _privateConstructorUsedError;
  @JsonKey(name: "meetingTime")
  String get meetingTime => throw _privateConstructorUsedError;
  @JsonKey(name: "reason")
  String? get reason => throw _privateConstructorUsedError;
  @JsonKey(name: "feeling")
  String? get feeling => throw _privateConstructorUsedError;
  @JsonKey(name: "emotionalAttachment")
  String? get emotionalAttachment => throw _privateConstructorUsedError;
  @JsonKey(name: "notes")
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: "address")
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: "category")
  String? get category => throw _privateConstructorUsedError;
  @JsonKey(name: "status")
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAt")
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updatedAt")
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MeetingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeetingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingModelCopyWith<MeetingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingModelCopyWith<$Res> {
  factory $MeetingModelCopyWith(
          MeetingModel value, $Res Function(MeetingModel) then) =
      _$MeetingModelCopyWithImpl<$Res, MeetingModel>;
  @useResult
  $Res call(
      {@JsonKey(name: "meetingId") int meetingId,
      @JsonKey(name: "highProfileCustomerName") String highProfileCustomerName,
      @JsonKey(name: "crmName") String crmName,
      @JsonKey(name: "meetingDate") String meetingDate,
      @JsonKey(name: "meetingTime") String meetingTime,
      @JsonKey(name: "reason") String? reason,
      @JsonKey(name: "feeling") String? feeling,
      @JsonKey(name: "emotionalAttachment") String? emotionalAttachment,
      @JsonKey(name: "notes") String? notes,
      @JsonKey(name: "address") String? address,
      @JsonKey(name: "category") String? category,
      @JsonKey(name: "status") String? status,
      @JsonKey(name: "createdAt") String createdAt,
      @JsonKey(name: "updatedAt") String updatedAt});
}

/// @nodoc
class _$MeetingModelCopyWithImpl<$Res, $Val extends MeetingModel>
    implements $MeetingModelCopyWith<$Res> {
  _$MeetingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meetingId = null,
    Object? highProfileCustomerName = null,
    Object? crmName = null,
    Object? meetingDate = null,
    Object? meetingTime = null,
    Object? reason = freezed,
    Object? feeling = freezed,
    Object? emotionalAttachment = freezed,
    Object? notes = freezed,
    Object? address = freezed,
    Object? category = freezed,
    Object? status = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      meetingId: null == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as int,
      highProfileCustomerName: null == highProfileCustomerName
          ? _value.highProfileCustomerName
          : highProfileCustomerName // ignore: cast_nullable_to_non_nullable
              as String,
      crmName: null == crmName
          ? _value.crmName
          : crmName // ignore: cast_nullable_to_non_nullable
              as String,
      meetingDate: null == meetingDate
          ? _value.meetingDate
          : meetingDate // ignore: cast_nullable_to_non_nullable
              as String,
      meetingTime: null == meetingTime
          ? _value.meetingTime
          : meetingTime // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      feeling: freezed == feeling
          ? _value.feeling
          : feeling // ignore: cast_nullable_to_non_nullable
              as String?,
      emotionalAttachment: freezed == emotionalAttachment
          ? _value.emotionalAttachment
          : emotionalAttachment // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeetingModelImplCopyWith<$Res>
    implements $MeetingModelCopyWith<$Res> {
  factory _$$MeetingModelImplCopyWith(
          _$MeetingModelImpl value, $Res Function(_$MeetingModelImpl) then) =
      __$$MeetingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "meetingId") int meetingId,
      @JsonKey(name: "highProfileCustomerName") String highProfileCustomerName,
      @JsonKey(name: "crmName") String crmName,
      @JsonKey(name: "meetingDate") String meetingDate,
      @JsonKey(name: "meetingTime") String meetingTime,
      @JsonKey(name: "reason") String? reason,
      @JsonKey(name: "feeling") String? feeling,
      @JsonKey(name: "emotionalAttachment") String? emotionalAttachment,
      @JsonKey(name: "notes") String? notes,
      @JsonKey(name: "address") String? address,
      @JsonKey(name: "category") String? category,
      @JsonKey(name: "status") String? status,
      @JsonKey(name: "createdAt") String createdAt,
      @JsonKey(name: "updatedAt") String updatedAt});
}

/// @nodoc
class __$$MeetingModelImplCopyWithImpl<$Res>
    extends _$MeetingModelCopyWithImpl<$Res, _$MeetingModelImpl>
    implements _$$MeetingModelImplCopyWith<$Res> {
  __$$MeetingModelImplCopyWithImpl(
      _$MeetingModelImpl _value, $Res Function(_$MeetingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meetingId = null,
    Object? highProfileCustomerName = null,
    Object? crmName = null,
    Object? meetingDate = null,
    Object? meetingTime = null,
    Object? reason = freezed,
    Object? feeling = freezed,
    Object? emotionalAttachment = freezed,
    Object? notes = freezed,
    Object? address = freezed,
    Object? category = freezed,
    Object? status = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$MeetingModelImpl(
      meetingId: null == meetingId
          ? _value.meetingId
          : meetingId // ignore: cast_nullable_to_non_nullable
              as int,
      highProfileCustomerName: null == highProfileCustomerName
          ? _value.highProfileCustomerName
          : highProfileCustomerName // ignore: cast_nullable_to_non_nullable
              as String,
      crmName: null == crmName
          ? _value.crmName
          : crmName // ignore: cast_nullable_to_non_nullable
              as String,
      meetingDate: null == meetingDate
          ? _value.meetingDate
          : meetingDate // ignore: cast_nullable_to_non_nullable
              as String,
      meetingTime: null == meetingTime
          ? _value.meetingTime
          : meetingTime // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      feeling: freezed == feeling
          ? _value.feeling
          : feeling // ignore: cast_nullable_to_non_nullable
              as String?,
      emotionalAttachment: freezed == emotionalAttachment
          ? _value.emotionalAttachment
          : emotionalAttachment // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetingModelImpl implements _MeetingModel {
  const _$MeetingModelImpl(
      {@JsonKey(name: "meetingId") required this.meetingId,
      @JsonKey(name: "highProfileCustomerName")
      required this.highProfileCustomerName,
      @JsonKey(name: "crmName") required this.crmName,
      @JsonKey(name: "meetingDate") required this.meetingDate,
      @JsonKey(name: "meetingTime") required this.meetingTime,
      @JsonKey(name: "reason") this.reason,
      @JsonKey(name: "feeling") this.feeling,
      @JsonKey(name: "emotionalAttachment") this.emotionalAttachment,
      @JsonKey(name: "notes") this.notes,
      @JsonKey(name: "address") this.address,
      @JsonKey(name: "category") this.category,
      @JsonKey(name: "status") this.status,
      @JsonKey(name: "createdAt") required this.createdAt,
      @JsonKey(name: "updatedAt") required this.updatedAt});

  factory _$MeetingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetingModelImplFromJson(json);

  @override
  @JsonKey(name: "meetingId")
  final int meetingId;
  @override
  @JsonKey(name: "highProfileCustomerName")
  final String highProfileCustomerName;
  @override
  @JsonKey(name: "crmName")
  final String crmName;
  @override
  @JsonKey(name: "meetingDate")
  final String meetingDate;
  @override
  @JsonKey(name: "meetingTime")
  final String meetingTime;
  @override
  @JsonKey(name: "reason")
  final String? reason;
  @override
  @JsonKey(name: "feeling")
  final String? feeling;
  @override
  @JsonKey(name: "emotionalAttachment")
  final String? emotionalAttachment;
  @override
  @JsonKey(name: "notes")
  final String? notes;
  @override
  @JsonKey(name: "address")
  final String? address;
  @override
  @JsonKey(name: "category")
  final String? category;
  @override
  @JsonKey(name: "status")
  final String? status;
  @override
  @JsonKey(name: "createdAt")
  final String createdAt;
  @override
  @JsonKey(name: "updatedAt")
  final String updatedAt;

  @override
  String toString() {
    return 'MeetingModel(meetingId: $meetingId, highProfileCustomerName: $highProfileCustomerName, crmName: $crmName, meetingDate: $meetingDate, meetingTime: $meetingTime, reason: $reason, feeling: $feeling, emotionalAttachment: $emotionalAttachment, notes: $notes, address: $address, category: $category, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingModelImpl &&
            (identical(other.meetingId, meetingId) ||
                other.meetingId == meetingId) &&
            (identical(
                    other.highProfileCustomerName, highProfileCustomerName) ||
                other.highProfileCustomerName == highProfileCustomerName) &&
            (identical(other.crmName, crmName) || other.crmName == crmName) &&
            (identical(other.meetingDate, meetingDate) ||
                other.meetingDate == meetingDate) &&
            (identical(other.meetingTime, meetingTime) ||
                other.meetingTime == meetingTime) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.feeling, feeling) || other.feeling == feeling) &&
            (identical(other.emotionalAttachment, emotionalAttachment) ||
                other.emotionalAttachment == emotionalAttachment) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      meetingId,
      highProfileCustomerName,
      crmName,
      meetingDate,
      meetingTime,
      reason,
      feeling,
      emotionalAttachment,
      notes,
      address,
      category,
      status,
      createdAt,
      updatedAt);

  /// Create a copy of MeetingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingModelImplCopyWith<_$MeetingModelImpl> get copyWith =>
      __$$MeetingModelImplCopyWithImpl<_$MeetingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetingModelImplToJson(
      this,
    );
  }
}

abstract class _MeetingModel implements MeetingModel {
  const factory _MeetingModel(
      {@JsonKey(name: "meetingId") required final int meetingId,
      @JsonKey(name: "highProfileCustomerName")
      required final String highProfileCustomerName,
      @JsonKey(name: "crmName") required final String crmName,
      @JsonKey(name: "meetingDate") required final String meetingDate,
      @JsonKey(name: "meetingTime") required final String meetingTime,
      @JsonKey(name: "reason") final String? reason,
      @JsonKey(name: "feeling") final String? feeling,
      @JsonKey(name: "emotionalAttachment") final String? emotionalAttachment,
      @JsonKey(name: "notes") final String? notes,
      @JsonKey(name: "address") final String? address,
      @JsonKey(name: "category") final String? category,
      @JsonKey(name: "status") final String? status,
      @JsonKey(name: "createdAt") required final String createdAt,
      @JsonKey(name: "updatedAt")
      required final String updatedAt}) = _$MeetingModelImpl;

  factory _MeetingModel.fromJson(Map<String, dynamic> json) =
      _$MeetingModelImpl.fromJson;

  @override
  @JsonKey(name: "meetingId")
  int get meetingId;
  @override
  @JsonKey(name: "highProfileCustomerName")
  String get highProfileCustomerName;
  @override
  @JsonKey(name: "crmName")
  String get crmName;
  @override
  @JsonKey(name: "meetingDate")
  String get meetingDate;
  @override
  @JsonKey(name: "meetingTime")
  String get meetingTime;
  @override
  @JsonKey(name: "reason")
  String? get reason;
  @override
  @JsonKey(name: "feeling")
  String? get feeling;
  @override
  @JsonKey(name: "emotionalAttachment")
  String? get emotionalAttachment;
  @override
  @JsonKey(name: "notes")
  String? get notes;
  @override
  @JsonKey(name: "address")
  String? get address;
  @override
  @JsonKey(name: "category")
  String? get category;
  @override
  @JsonKey(name: "status")
  String? get status;
  @override
  @JsonKey(name: "createdAt")
  String get createdAt;
  @override
  @JsonKey(name: "updatedAt")
  String get updatedAt;

  /// Create a copy of MeetingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingModelImplCopyWith<_$MeetingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MeetingTime _$MeetingTimeFromJson(Map<String, dynamic> json) {
  return _MeetingTime.fromJson(json);
}

/// @nodoc
mixin _$MeetingTime {
  @JsonKey(name: "hour")
  int get hour => throw _privateConstructorUsedError;
  @JsonKey(name: "minute")
  int get minute => throw _privateConstructorUsedError;
  @JsonKey(name: "second")
  int get second => throw _privateConstructorUsedError;
  @JsonKey(name: "nano")
  int get nano => throw _privateConstructorUsedError;

  /// Serializes this MeetingTime to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeetingTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingTimeCopyWith<MeetingTime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingTimeCopyWith<$Res> {
  factory $MeetingTimeCopyWith(
          MeetingTime value, $Res Function(MeetingTime) then) =
      _$MeetingTimeCopyWithImpl<$Res, MeetingTime>;
  @useResult
  $Res call(
      {@JsonKey(name: "hour") int hour,
      @JsonKey(name: "minute") int minute,
      @JsonKey(name: "second") int second,
      @JsonKey(name: "nano") int nano});
}

/// @nodoc
class _$MeetingTimeCopyWithImpl<$Res, $Val extends MeetingTime>
    implements $MeetingTimeCopyWith<$Res> {
  _$MeetingTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetingTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
    Object? second = null,
    Object? nano = null,
  }) {
    return _then(_value.copyWith(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      second: null == second
          ? _value.second
          : second // ignore: cast_nullable_to_non_nullable
              as int,
      nano: null == nano
          ? _value.nano
          : nano // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeetingTimeImplCopyWith<$Res>
    implements $MeetingTimeCopyWith<$Res> {
  factory _$$MeetingTimeImplCopyWith(
          _$MeetingTimeImpl value, $Res Function(_$MeetingTimeImpl) then) =
      __$$MeetingTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "hour") int hour,
      @JsonKey(name: "minute") int minute,
      @JsonKey(name: "second") int second,
      @JsonKey(name: "nano") int nano});
}

/// @nodoc
class __$$MeetingTimeImplCopyWithImpl<$Res>
    extends _$MeetingTimeCopyWithImpl<$Res, _$MeetingTimeImpl>
    implements _$$MeetingTimeImplCopyWith<$Res> {
  __$$MeetingTimeImplCopyWithImpl(
      _$MeetingTimeImpl _value, $Res Function(_$MeetingTimeImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetingTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
    Object? second = null,
    Object? nano = null,
  }) {
    return _then(_$MeetingTimeImpl(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      second: null == second
          ? _value.second
          : second // ignore: cast_nullable_to_non_nullable
              as int,
      nano: null == nano
          ? _value.nano
          : nano // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetingTimeImpl implements _MeetingTime {
  const _$MeetingTimeImpl(
      {@JsonKey(name: "hour") required this.hour,
      @JsonKey(name: "minute") required this.minute,
      @JsonKey(name: "second") required this.second,
      @JsonKey(name: "nano") required this.nano});

  factory _$MeetingTimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetingTimeImplFromJson(json);

  @override
  @JsonKey(name: "hour")
  final int hour;
  @override
  @JsonKey(name: "minute")
  final int minute;
  @override
  @JsonKey(name: "second")
  final int second;
  @override
  @JsonKey(name: "nano")
  final int nano;

  @override
  String toString() {
    return 'MeetingTime(hour: $hour, minute: $minute, second: $second, nano: $nano)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingTimeImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.second, second) || other.second == second) &&
            (identical(other.nano, nano) || other.nano == nano));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute, second, nano);

  /// Create a copy of MeetingTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingTimeImplCopyWith<_$MeetingTimeImpl> get copyWith =>
      __$$MeetingTimeImplCopyWithImpl<_$MeetingTimeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetingTimeImplToJson(
      this,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "hour": hour,
      "minute": minute,
      "second": second,
      "nano": nano,
    };
  }
}

abstract class _MeetingTime implements MeetingTime {
  const factory _MeetingTime(
      {@JsonKey(name: "hour") required final int hour,
      @JsonKey(name: "minute") required final int minute,
      @JsonKey(name: "second") required final int second,
      @JsonKey(name: "nano") required final int nano}) = _$MeetingTimeImpl;

  factory _MeetingTime.fromJson(Map<String, dynamic> json) =
      _$MeetingTimeImpl.fromJson;

  @override
  @JsonKey(name: "hour")
  int get hour;
  @override
  @JsonKey(name: "minute")
  int get minute;
  @override
  @JsonKey(name: "second")
  int get second;
  @override
  @JsonKey(name: "nano")
  int get nano;

  /// Create a copy of MeetingTime
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingTimeImplCopyWith<_$MeetingTimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
