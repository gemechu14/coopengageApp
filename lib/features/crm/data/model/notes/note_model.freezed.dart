// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NoteModel _$NoteModelFromJson(Map<String, dynamic> json) {
  return _NoteModel.fromJson(json);
}

/// @nodoc
mixin _$NoteModel {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "highProfileCustomerId")
  int get highProfileCustomerId => throw _privateConstructorUsedError;
  @JsonKey(name: "highProfileCustomerName")
  String get highProfileCustomerName => throw _privateConstructorUsedError;
  @JsonKey(name: "addedById")
  int get addedById => throw _privateConstructorUsedError;
  @JsonKey(name: "addedByName")
  String get addedByName => throw _privateConstructorUsedError;
  @JsonKey(name: "title")
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: "content")
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: "color")
  String? get color => throw _privateConstructorUsedError;
  @JsonKey(name: "voiceNote")
  String? get voiceNote => throw _privateConstructorUsedError;

  /// Serializes this NoteModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NoteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoteModelCopyWith<NoteModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteModelCopyWith<$Res> {
  factory $NoteModelCopyWith(NoteModel value, $Res Function(NoteModel) then) =
      _$NoteModelCopyWithImpl<$Res, NoteModel>;
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "highProfileCustomerId") int highProfileCustomerId,
      @JsonKey(name: "highProfileCustomerName") String highProfileCustomerName,
      @JsonKey(name: "addedById") int addedById,
      @JsonKey(name: "addedByName") String addedByName,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "content") String content,
      @JsonKey(name: "color") String? color,
      @JsonKey(name: "voiceNote") String? voiceNote});
}

/// @nodoc
class _$NoteModelCopyWithImpl<$Res, $Val extends NoteModel>
    implements $NoteModelCopyWith<$Res> {
  _$NoteModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? highProfileCustomerId = null,
    Object? highProfileCustomerName = null,
    Object? addedById = null,
    Object? addedByName = null,
    Object? title = null,
    Object? content = null,
    Object? color = freezed,
    Object? voiceNote = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      highProfileCustomerId: null == highProfileCustomerId
          ? _value.highProfileCustomerId
          : highProfileCustomerId // ignore: cast_nullable_to_non_nullable
              as int,
      highProfileCustomerName: null == highProfileCustomerName
          ? _value.highProfileCustomerName
          : highProfileCustomerName // ignore: cast_nullable_to_non_nullable
              as String,
      addedById: null == addedById
          ? _value.addedById
          : addedById // ignore: cast_nullable_to_non_nullable
              as int,
      addedByName: null == addedByName
          ? _value.addedByName
          : addedByName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      voiceNote: freezed == voiceNote
          ? _value.voiceNote
          : voiceNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NoteModelImplCopyWith<$Res>
    implements $NoteModelCopyWith<$Res> {
  factory _$$NoteModelImplCopyWith(
          _$NoteModelImpl value, $Res Function(_$NoteModelImpl) then) =
      __$$NoteModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "highProfileCustomerId") int highProfileCustomerId,
      @JsonKey(name: "highProfileCustomerName") String highProfileCustomerName,
      @JsonKey(name: "addedById") int addedById,
      @JsonKey(name: "addedByName") String addedByName,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "content") String content,
      @JsonKey(name: "color") String? color,
      @JsonKey(name: "voiceNote") String? voiceNote});
}

/// @nodoc
class __$$NoteModelImplCopyWithImpl<$Res>
    extends _$NoteModelCopyWithImpl<$Res, _$NoteModelImpl>
    implements _$$NoteModelImplCopyWith<$Res> {
  __$$NoteModelImplCopyWithImpl(
      _$NoteModelImpl _value, $Res Function(_$NoteModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NoteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? highProfileCustomerId = null,
    Object? highProfileCustomerName = null,
    Object? addedById = null,
    Object? addedByName = null,
    Object? title = null,
    Object? content = null,
    Object? color = freezed,
    Object? voiceNote = freezed,
  }) {
    return _then(_$NoteModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      highProfileCustomerId: null == highProfileCustomerId
          ? _value.highProfileCustomerId
          : highProfileCustomerId // ignore: cast_nullable_to_non_nullable
              as int,
      highProfileCustomerName: null == highProfileCustomerName
          ? _value.highProfileCustomerName
          : highProfileCustomerName // ignore: cast_nullable_to_non_nullable
              as String,
      addedById: null == addedById
          ? _value.addedById
          : addedById // ignore: cast_nullable_to_non_nullable
              as int,
      addedByName: null == addedByName
          ? _value.addedByName
          : addedByName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      voiceNote: freezed == voiceNote
          ? _value.voiceNote
          : voiceNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NoteModelImpl implements _NoteModel {
  const _$NoteModelImpl(
      {@JsonKey(name: "id") required this.id,
      @JsonKey(name: "highProfileCustomerId")
      required this.highProfileCustomerId,
      @JsonKey(name: "highProfileCustomerName")
      required this.highProfileCustomerName,
      @JsonKey(name: "addedById") required this.addedById,
      @JsonKey(name: "addedByName") required this.addedByName,
      @JsonKey(name: "title") required this.title,
      @JsonKey(name: "content") required this.content,
      @JsonKey(name: "color") this.color,
      @JsonKey(name: "voiceNote") this.voiceNote});

  factory _$NoteModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoteModelImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "highProfileCustomerId")
  final int highProfileCustomerId;
  @override
  @JsonKey(name: "highProfileCustomerName")
  final String highProfileCustomerName;
  @override
  @JsonKey(name: "addedById")
  final int addedById;
  @override
  @JsonKey(name: "addedByName")
  final String addedByName;
  @override
  @JsonKey(name: "title")
  final String title;
  @override
  @JsonKey(name: "content")
  final String content;
  @override
  @JsonKey(name: "color")
  final String? color;
  @override
  @JsonKey(name: "voiceNote")
  final String? voiceNote;

  @override
  String toString() {
    return 'NoteModel(id: $id, highProfileCustomerId: $highProfileCustomerId, highProfileCustomerName: $highProfileCustomerName, addedById: $addedById, addedByName: $addedByName, title: $title, content: $content, color: $color, voiceNote: $voiceNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.highProfileCustomerId, highProfileCustomerId) ||
                other.highProfileCustomerId == highProfileCustomerId) &&
            (identical(
                    other.highProfileCustomerName, highProfileCustomerName) ||
                other.highProfileCustomerName == highProfileCustomerName) &&
            (identical(other.addedById, addedById) ||
                other.addedById == addedById) &&
            (identical(other.addedByName, addedByName) ||
                other.addedByName == addedByName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.voiceNote, voiceNote) ||
                other.voiceNote == voiceNote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      highProfileCustomerId,
      highProfileCustomerName,
      addedById,
      addedByName,
      title,
      content,
      color,
      voiceNote);

  /// Create a copy of NoteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteModelImplCopyWith<_$NoteModelImpl> get copyWith =>
      __$$NoteModelImplCopyWithImpl<_$NoteModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NoteModelImplToJson(
      this,
    );
  }
}

abstract class _NoteModel implements NoteModel {
  const factory _NoteModel(
      {@JsonKey(name: "id") required final int id,
      @JsonKey(name: "highProfileCustomerId")
      required final int highProfileCustomerId,
      @JsonKey(name: "highProfileCustomerName")
      required final String highProfileCustomerName,
      @JsonKey(name: "addedById") required final int addedById,
      @JsonKey(name: "addedByName") required final String addedByName,
      @JsonKey(name: "title") required final String title,
      @JsonKey(name: "content") required final String content,
      @JsonKey(name: "color") final String? color,
      @JsonKey(name: "voiceNote") final String? voiceNote}) = _$NoteModelImpl;

  factory _NoteModel.fromJson(Map<String, dynamic> json) =
      _$NoteModelImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "highProfileCustomerId")
  int get highProfileCustomerId;
  @override
  @JsonKey(name: "highProfileCustomerName")
  String get highProfileCustomerName;
  @override
  @JsonKey(name: "addedById")
  int get addedById;
  @override
  @JsonKey(name: "addedByName")
  String get addedByName;
  @override
  @JsonKey(name: "title")
  String get title;
  @override
  @JsonKey(name: "content")
  String get content;
  @override
  @JsonKey(name: "color")
  String? get color;
  @override
  @JsonKey(name: "voiceNote")
  String? get voiceNote;

  /// Create a copy of NoteModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteModelImplCopyWith<_$NoteModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
