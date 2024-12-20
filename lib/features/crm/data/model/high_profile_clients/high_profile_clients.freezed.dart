// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'high_profile_clients.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HighProfileClientsModel _$HighProfileClientsModelFromJson(
    Map<String, dynamic> json) {
  return _HighProfileClientsModel.fromJson(json);
}

/// @nodoc
mixin _$HighProfileClientsModel {
  @JsonKey(name: "id")
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "phone")
  String get phone => throw _privateConstructorUsedError;
  @JsonKey(name: "accHolderName")
  String get accHolderName => throw _privateConstructorUsedError;
  @JsonKey(name: "address")
  String get address => throw _privateConstructorUsedError;
  @JsonKey(name: "tinNumber")
  String get tinNumber => throw _privateConstructorUsedError;
  @JsonKey(name: "accountNumber")
  int get accountNumber => throw _privateConstructorUsedError; // Updated type
  @JsonKey(name: "assignedCRMName")
  String? get assignedCRMName => throw _privateConstructorUsedError; // Nullable
  @JsonKey(name: "gender")
  String get gender => throw _privateConstructorUsedError;
  @JsonKey(name: "birthDate")
  String get birthDate => throw _privateConstructorUsedError;
  @JsonKey(name: "maritalStatus")
  String get maritalStatus => throw _privateConstructorUsedError;
  @JsonKey(name: "nationality")
  String get nationality => throw _privateConstructorUsedError;
  @JsonKey(name: "email")
  String get email => throw _privateConstructorUsedError;

  /// Serializes this HighProfileClientsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HighProfileClientsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighProfileClientsModelCopyWith<HighProfileClientsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighProfileClientsModelCopyWith<$Res> {
  factory $HighProfileClientsModelCopyWith(HighProfileClientsModel value,
          $Res Function(HighProfileClientsModel) then) =
      _$HighProfileClientsModelCopyWithImpl<$Res, HighProfileClientsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: "id") int? id,
      @JsonKey(name: "phone") String phone,
      @JsonKey(name: "accHolderName") String accHolderName,
      @JsonKey(name: "address") String address,
      @JsonKey(name: "tinNumber") String tinNumber,
      @JsonKey(name: "accountNumber") int accountNumber,
      @JsonKey(name: "assignedCRMName") String? assignedCRMName,
      @JsonKey(name: "gender") String gender,
      @JsonKey(name: "birthDate") String birthDate,
      @JsonKey(name: "maritalStatus") String maritalStatus,
      @JsonKey(name: "nationality") String nationality,
      @JsonKey(name: "email") String email});
}

/// @nodoc
class _$HighProfileClientsModelCopyWithImpl<$Res,
        $Val extends HighProfileClientsModel>
    implements $HighProfileClientsModelCopyWith<$Res> {
  _$HighProfileClientsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HighProfileClientsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? phone = null,
    Object? accHolderName = null,
    Object? address = null,
    Object? tinNumber = null,
    Object? accountNumber = null,
    Object? assignedCRMName = freezed,
    Object? gender = null,
    Object? birthDate = null,
    Object? maritalStatus = null,
    Object? nationality = null,
    Object? email = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      accHolderName: null == accHolderName
          ? _value.accHolderName
          : accHolderName // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      tinNumber: null == tinNumber
          ? _value.tinNumber
          : tinNumber // ignore: cast_nullable_to_non_nullable
              as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as int,
      assignedCRMName: freezed == assignedCRMName
          ? _value.assignedCRMName
          : assignedCRMName // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as String,
      maritalStatus: null == maritalStatus
          ? _value.maritalStatus
          : maritalStatus // ignore: cast_nullable_to_non_nullable
              as String,
      nationality: null == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HighProfileClientsModelImplCopyWith<$Res>
    implements $HighProfileClientsModelCopyWith<$Res> {
  factory _$$HighProfileClientsModelImplCopyWith(
          _$HighProfileClientsModelImpl value,
          $Res Function(_$HighProfileClientsModelImpl) then) =
      __$$HighProfileClientsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "id") int? id,
      @JsonKey(name: "phone") String phone,
      @JsonKey(name: "accHolderName") String accHolderName,
      @JsonKey(name: "address") String address,
      @JsonKey(name: "tinNumber") String tinNumber,
      @JsonKey(name: "accountNumber") int accountNumber,
      @JsonKey(name: "assignedCRMName") String? assignedCRMName,
      @JsonKey(name: "gender") String gender,
      @JsonKey(name: "birthDate") String birthDate,
      @JsonKey(name: "maritalStatus") String maritalStatus,
      @JsonKey(name: "nationality") String nationality,
      @JsonKey(name: "email") String email});
}

/// @nodoc
class __$$HighProfileClientsModelImplCopyWithImpl<$Res>
    extends _$HighProfileClientsModelCopyWithImpl<$Res,
        _$HighProfileClientsModelImpl>
    implements _$$HighProfileClientsModelImplCopyWith<$Res> {
  __$$HighProfileClientsModelImplCopyWithImpl(
      _$HighProfileClientsModelImpl _value,
      $Res Function(_$HighProfileClientsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of HighProfileClientsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? phone = null,
    Object? accHolderName = null,
    Object? address = null,
    Object? tinNumber = null,
    Object? accountNumber = null,
    Object? assignedCRMName = freezed,
    Object? gender = null,
    Object? birthDate = null,
    Object? maritalStatus = null,
    Object? nationality = null,
    Object? email = null,
  }) {
    return _then(_$HighProfileClientsModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      accHolderName: null == accHolderName
          ? _value.accHolderName
          : accHolderName // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      tinNumber: null == tinNumber
          ? _value.tinNumber
          : tinNumber // ignore: cast_nullable_to_non_nullable
              as String,
      accountNumber: null == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as int,
      assignedCRMName: freezed == assignedCRMName
          ? _value.assignedCRMName
          : assignedCRMName // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as String,
      maritalStatus: null == maritalStatus
          ? _value.maritalStatus
          : maritalStatus // ignore: cast_nullable_to_non_nullable
              as String,
      nationality: null == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HighProfileClientsModelImpl implements _HighProfileClientsModel {
  const _$HighProfileClientsModelImpl(
      {@JsonKey(name: "id") this.id,
      @JsonKey(name: "phone") required this.phone,
      @JsonKey(name: "accHolderName") required this.accHolderName,
      @JsonKey(name: "address") required this.address,
      @JsonKey(name: "tinNumber") required this.tinNumber,
      @JsonKey(name: "accountNumber") required this.accountNumber,
      @JsonKey(name: "assignedCRMName") this.assignedCRMName,
      @JsonKey(name: "gender") required this.gender,
      @JsonKey(name: "birthDate") required this.birthDate,
      @JsonKey(name: "maritalStatus") required this.maritalStatus,
      @JsonKey(name: "nationality") required this.nationality,
      @JsonKey(name: "email") required this.email});

  factory _$HighProfileClientsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HighProfileClientsModelImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int? id;
  @override
  @JsonKey(name: "phone")
  final String phone;
  @override
  @JsonKey(name: "accHolderName")
  final String accHolderName;
  @override
  @JsonKey(name: "address")
  final String address;
  @override
  @JsonKey(name: "tinNumber")
  final String tinNumber;
  @override
  @JsonKey(name: "accountNumber")
  final int accountNumber;
// Updated type
  @override
  @JsonKey(name: "assignedCRMName")
  final String? assignedCRMName;
// Nullable
  @override
  @JsonKey(name: "gender")
  final String gender;
  @override
  @JsonKey(name: "birthDate")
  final String birthDate;
  @override
  @JsonKey(name: "maritalStatus")
  final String maritalStatus;
  @override
  @JsonKey(name: "nationality")
  final String nationality;
  @override
  @JsonKey(name: "email")
  final String email;

  @override
  String toString() {
    return 'HighProfileClientsModel(id: $id, phone: $phone, accHolderName: $accHolderName, address: $address, tinNumber: $tinNumber, accountNumber: $accountNumber, assignedCRMName: $assignedCRMName, gender: $gender, birthDate: $birthDate, maritalStatus: $maritalStatus, nationality: $nationality, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighProfileClientsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.accHolderName, accHolderName) ||
                other.accHolderName == accHolderName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.tinNumber, tinNumber) ||
                other.tinNumber == tinNumber) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.assignedCRMName, assignedCRMName) ||
                other.assignedCRMName == assignedCRMName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.maritalStatus, maritalStatus) ||
                other.maritalStatus == maritalStatus) &&
            (identical(other.nationality, nationality) ||
                other.nationality == nationality) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      phone,
      accHolderName,
      address,
      tinNumber,
      accountNumber,
      assignedCRMName,
      gender,
      birthDate,
      maritalStatus,
      nationality,
      email);

  /// Create a copy of HighProfileClientsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighProfileClientsModelImplCopyWith<_$HighProfileClientsModelImpl>
      get copyWith => __$$HighProfileClientsModelImplCopyWithImpl<
          _$HighProfileClientsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HighProfileClientsModelImplToJson(
      this,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'accHolderName': accHolderName,
      'address': address,
      'tinNumber': tinNumber,
      'accountNumber': accountNumber,
      'assignedCRMName': assignedCRMName,
      'gender': gender,
      'birthDate': birthDate,
      'maritalStatus': maritalStatus,
      'nationality': nationality,
      'email': email,
    };
  }

  @override
  Map<String, dynamic> toPartialMap() {
    return {
      // 'id': id,
      'accHolderName': accHolderName,
      'phone': phone,
      'email': email,
      'tinNumber': tinNumber,
      'accountNumber': accountNumber,
      'address': address,
    };
  }
}

abstract class _HighProfileClientsModel implements HighProfileClientsModel {
  const factory _HighProfileClientsModel(
          {@JsonKey(name: "id") final int? id,
          @JsonKey(name: "phone") required final String phone,
          @JsonKey(name: "accHolderName") required final String accHolderName,
          @JsonKey(name: "address") required final String address,
          @JsonKey(name: "tinNumber") required final String tinNumber,
          @JsonKey(name: "accountNumber") required final int accountNumber,
          @JsonKey(name: "assignedCRMName") final String? assignedCRMName,
          @JsonKey(name: "gender") required final String gender,
          @JsonKey(name: "birthDate") required final String birthDate,
          @JsonKey(name: "maritalStatus") required final String maritalStatus,
          @JsonKey(name: "nationality") required final String nationality,
          @JsonKey(name: "email") required final String email}) =
      _$HighProfileClientsModelImpl;

  factory _HighProfileClientsModel.fromJson(Map<String, dynamic> json) =
      _$HighProfileClientsModelImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int? get id;
  @override
  @JsonKey(name: "phone")
  String get phone;
  @override
  @JsonKey(name: "accHolderName")
  String get accHolderName;
  @override
  @JsonKey(name: "address")
  String get address;
  @override
  @JsonKey(name: "tinNumber")
  String get tinNumber;
  @override
  @JsonKey(name: "accountNumber")
  int get accountNumber; // Updated type
  @override
  @JsonKey(name: "assignedCRMName")
  String? get assignedCRMName; // Nullable
  @override
  @JsonKey(name: "gender")
  String get gender;
  @override
  @JsonKey(name: "birthDate")
  String get birthDate;
  @override
  @JsonKey(name: "maritalStatus")
  String get maritalStatus;
  @override
  @JsonKey(name: "nationality")
  String get nationality;
  @override
  @JsonKey(name: "email")
  String get email;

  /// Create a copy of HighProfileClientsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighProfileClientsModelImplCopyWith<_$HighProfileClientsModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
