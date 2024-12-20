// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) {
  return _TaskModel.fromJson(json);
}

/// @nodoc
mixin _$TaskModel {
  @JsonKey(name: "taskId")
  int get taskId => throw _privateConstructorUsedError;
  @JsonKey(name: "highProfileCustomerName")
  String get highProfileCustomerName => throw _privateConstructorUsedError;
  @JsonKey(name: "crmName")
  String get crmName => throw _privateConstructorUsedError;
  @JsonKey(name: "taskDate")
  String get taskDate => throw _privateConstructorUsedError;
  @JsonKey(name: "taskTime")
  String get taskTime => throw _privateConstructorUsedError;
  @JsonKey(name: "title")
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: "description")
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: "address")
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: "reminder")
  bool get reminder => throw _privateConstructorUsedError;
  @JsonKey(name: "status")
  String get status => throw _privateConstructorUsedError;

  /// Serializes this TaskModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskModelCopyWith<TaskModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskModelCopyWith<$Res> {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) then) =
      _$TaskModelCopyWithImpl<$Res, TaskModel>;
  @useResult
  $Res call(
      {@JsonKey(name: "taskId") int taskId,
      @JsonKey(name: "highProfileCustomerName") String highProfileCustomerName,
      @JsonKey(name: "crmName") String crmName,
      @JsonKey(name: "taskDate") String taskDate,
      @JsonKey(name: "taskTime") String taskTime,
      @JsonKey(name: "title") String? title,
      @JsonKey(name: "description") String? description,
      @JsonKey(name: "address") String? address,
      @JsonKey(name: "reminder") bool reminder,
      @JsonKey(name: "status") String status});
}

/// @nodoc
class _$TaskModelCopyWithImpl<$Res, $Val extends TaskModel>
    implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
    Object? highProfileCustomerName = null,
    Object? crmName = null,
    Object? taskDate = null,
    Object? taskTime = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? address = freezed,
    Object? reminder = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      highProfileCustomerName: null == highProfileCustomerName
          ? _value.highProfileCustomerName
          : highProfileCustomerName // ignore: cast_nullable_to_non_nullable
              as String,
      crmName: null == crmName
          ? _value.crmName
          : crmName // ignore: cast_nullable_to_non_nullable
              as String,
      taskDate: null == taskDate
          ? _value.taskDate
          : taskDate // ignore: cast_nullable_to_non_nullable
              as String,
      taskTime: null == taskTime
          ? _value.taskTime
          : taskTime // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      reminder: null == reminder
          ? _value.reminder
          : reminder // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskModelImplCopyWith<$Res>
    implements $TaskModelCopyWith<$Res> {
  factory _$$TaskModelImplCopyWith(
          _$TaskModelImpl value, $Res Function(_$TaskModelImpl) then) =
      __$$TaskModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "taskId") int taskId,
      @JsonKey(name: "highProfileCustomerName") String highProfileCustomerName,
      @JsonKey(name: "crmName") String crmName,
      @JsonKey(name: "taskDate") String taskDate,
      @JsonKey(name: "taskTime") String taskTime,
      @JsonKey(name: "title") String? title,
      @JsonKey(name: "description") String? description,
      @JsonKey(name: "address") String? address,
      @JsonKey(name: "reminder") bool reminder,
      @JsonKey(name: "status") String status});
}

/// @nodoc
class __$$TaskModelImplCopyWithImpl<$Res>
    extends _$TaskModelCopyWithImpl<$Res, _$TaskModelImpl>
    implements _$$TaskModelImplCopyWith<$Res> {
  __$$TaskModelImplCopyWithImpl(
      _$TaskModelImpl _value, $Res Function(_$TaskModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
    Object? highProfileCustomerName = null,
    Object? crmName = null,
    Object? taskDate = null,
    Object? taskTime = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? address = freezed,
    Object? reminder = null,
    Object? status = null,
  }) {
    return _then(_$TaskModelImpl(
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int,
      highProfileCustomerName: null == highProfileCustomerName
          ? _value.highProfileCustomerName
          : highProfileCustomerName // ignore: cast_nullable_to_non_nullable
              as String,
      crmName: null == crmName
          ? _value.crmName
          : crmName // ignore: cast_nullable_to_non_nullable
              as String,
      taskDate: null == taskDate
          ? _value.taskDate
          : taskDate // ignore: cast_nullable_to_non_nullable
              as String,
      taskTime: null == taskTime
          ? _value.taskTime
          : taskTime // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      reminder: null == reminder
          ? _value.reminder
          : reminder // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskModelImpl implements _TaskModel {
  const _$TaskModelImpl(
      {@JsonKey(name: "taskId") required this.taskId,
      @JsonKey(name: "highProfileCustomerName")
      required this.highProfileCustomerName,
      @JsonKey(name: "crmName") required this.crmName,
      @JsonKey(name: "taskDate") required this.taskDate,
      @JsonKey(name: "taskTime") required this.taskTime,
      @JsonKey(name: "title") this.title,
      @JsonKey(name: "description") this.description,
      @JsonKey(name: "address") this.address,
      @JsonKey(name: "reminder") required this.reminder,
      @JsonKey(name: "status") required this.status});

  factory _$TaskModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskModelImplFromJson(json);

  @override
  @JsonKey(name: "taskId")
  final int taskId;
  @override
  @JsonKey(name: "highProfileCustomerName")
  final String highProfileCustomerName;
  @override
  @JsonKey(name: "crmName")
  final String crmName;
  @override
  @JsonKey(name: "taskDate")
  final String taskDate;
  @override
  @JsonKey(name: "taskTime")
  final String taskTime;
  @override
  @JsonKey(name: "title")
  final String? title;
  @override
  @JsonKey(name: "description")
  final String? description;
  @override
  @JsonKey(name: "address")
  final String? address;
  @override
  @JsonKey(name: "reminder")
  final bool reminder;
  @override
  @JsonKey(name: "status")
  final String status;

  @override
  String toString() {
    return 'TaskModel(taskId: $taskId, highProfileCustomerName: $highProfileCustomerName, crmName: $crmName, taskDate: $taskDate, taskTime: $taskTime, title: $title, description: $description, address: $address, reminder: $reminder, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskModelImpl &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(
                    other.highProfileCustomerName, highProfileCustomerName) ||
                other.highProfileCustomerName == highProfileCustomerName) &&
            (identical(other.crmName, crmName) || other.crmName == crmName) &&
            (identical(other.taskDate, taskDate) ||
                other.taskDate == taskDate) &&
            (identical(other.taskTime, taskTime) ||
                other.taskTime == taskTime) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.reminder, reminder) ||
                other.reminder == reminder) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      taskId,
      highProfileCustomerName,
      crmName,
      taskDate,
      taskTime,
      title,
      description,
      address,
      reminder,
      status);

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskModelImplCopyWith<_$TaskModelImpl> get copyWith =>
      __$$TaskModelImplCopyWithImpl<_$TaskModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskModelImplToJson(
      this,
    );
  }
}

abstract class _TaskModel implements TaskModel {
  const factory _TaskModel(
      {@JsonKey(name: "taskId") required final int taskId,
      @JsonKey(name: "highProfileCustomerName")
      required final String highProfileCustomerName,
      @JsonKey(name: "crmName") required final String crmName,
      @JsonKey(name: "taskDate") required final String taskDate,
      @JsonKey(name: "taskTime") required final String taskTime,
      @JsonKey(name: "title") final String? title,
      @JsonKey(name: "description") final String? description,
      @JsonKey(name: "address") final String? address,
      @JsonKey(name: "reminder") required final bool reminder,
      @JsonKey(name: "status") required final String status}) = _$TaskModelImpl;

  factory _TaskModel.fromJson(Map<String, dynamic> json) =
      _$TaskModelImpl.fromJson;

  @override
  @JsonKey(name: "taskId")
  int get taskId;
  @override
  @JsonKey(name: "highProfileCustomerName")
  String get highProfileCustomerName;
  @override
  @JsonKey(name: "crmName")
  String get crmName;
  @override
  @JsonKey(name: "taskDate")
  String get taskDate;
  @override
  @JsonKey(name: "taskTime")
  String get taskTime;
  @override
  @JsonKey(name: "title")
  String? get title;
  @override
  @JsonKey(name: "description")
  String? get description;
  @override
  @JsonKey(name: "address")
  String? get address;
  @override
  @JsonKey(name: "reminder")
  bool get reminder;
  @override
  @JsonKey(name: "status")
  String get status;

  /// Create a copy of TaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskModelImplCopyWith<_$TaskModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaskTime _$TaskTimeFromJson(Map<String, dynamic> json) {
  return _TaskTime.fromJson(json);
}

/// @nodoc
mixin _$TaskTime {
  @JsonKey(name: "hour")
  int get hour => throw _privateConstructorUsedError;
  @JsonKey(name: "minute")
  int get minute => throw _privateConstructorUsedError;
  @JsonKey(name: "second")
  int get second => throw _privateConstructorUsedError;
  @JsonKey(name: "nano")
  int get nano => throw _privateConstructorUsedError;

  /// Serializes this TaskTime to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskTimeCopyWith<TaskTime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskTimeCopyWith<$Res> {
  factory $TaskTimeCopyWith(TaskTime value, $Res Function(TaskTime) then) =
      _$TaskTimeCopyWithImpl<$Res, TaskTime>;
  @useResult
  $Res call(
      {@JsonKey(name: "hour") int hour,
      @JsonKey(name: "minute") int minute,
      @JsonKey(name: "second") int second,
      @JsonKey(name: "nano") int nano});
}

/// @nodoc
class _$TaskTimeCopyWithImpl<$Res, $Val extends TaskTime>
    implements $TaskTimeCopyWith<$Res> {
  _$TaskTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskTime
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
abstract class _$$TaskTimeImplCopyWith<$Res>
    implements $TaskTimeCopyWith<$Res> {
  factory _$$TaskTimeImplCopyWith(
          _$TaskTimeImpl value, $Res Function(_$TaskTimeImpl) then) =
      __$$TaskTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "hour") int hour,
      @JsonKey(name: "minute") int minute,
      @JsonKey(name: "second") int second,
      @JsonKey(name: "nano") int nano});
}

/// @nodoc
class __$$TaskTimeImplCopyWithImpl<$Res>
    extends _$TaskTimeCopyWithImpl<$Res, _$TaskTimeImpl>
    implements _$$TaskTimeImplCopyWith<$Res> {
  __$$TaskTimeImplCopyWithImpl(
      _$TaskTimeImpl _value, $Res Function(_$TaskTimeImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
    Object? second = null,
    Object? nano = null,
  }) {
    return _then(_$TaskTimeImpl(
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
class _$TaskTimeImpl implements _TaskTime {
  const _$TaskTimeImpl(
      {@JsonKey(name: "hour") required this.hour,
      @JsonKey(name: "minute") required this.minute,
      @JsonKey(name: "second") required this.second,
      @JsonKey(name: "nano") required this.nano});

  factory _$TaskTimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskTimeImplFromJson(json);

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
    return 'TaskTime(hour: $hour, minute: $minute, second: $second, nano: $nano)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskTimeImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.second, second) || other.second == second) &&
            (identical(other.nano, nano) || other.nano == nano));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute, second, nano);

  /// Create a copy of TaskTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskTimeImplCopyWith<_$TaskTimeImpl> get copyWith =>
      __$$TaskTimeImplCopyWithImpl<_$TaskTimeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskTimeImplToJson(
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

abstract class _TaskTime implements TaskTime {
  const factory _TaskTime(
      {@JsonKey(name: "hour") required final int hour,
      @JsonKey(name: "minute") required final int minute,
      @JsonKey(name: "second") required final int second,
      @JsonKey(name: "nano") required final int nano}) = _$TaskTimeImpl;

  factory _TaskTime.fromJson(Map<String, dynamic> json) =
      _$TaskTimeImpl.fromJson;

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

  /// Create a copy of TaskTime
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskTimeImplCopyWith<_$TaskTimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
