// // Clean data models for National ID authentication

// class NationalIdState {
//   final bool isLoading;
//   final bool isConnected;
//   final bool isRegistered;
//   final bool isCompleted;
//   final String? authUrl;
//   final String? state;
//   final String? error;
//   final FaydaUserData? userData;

//   const NationalIdState({
//     this.isLoading = false,
//     this.isConnected = false,
//     this.isRegistered = false,
//     this.isCompleted = false,
//     this.authUrl,
//     this.state,
//     this.error,
//     this.userData,
//   });

//   NationalIdState copyWith({
//     bool? isLoading,
//     bool? isConnected,
//     bool? isRegistered,
//     bool? isCompleted,
//     String? authUrl,
//     String? state,
//     String? error,
//     FaydaUserData? userData,
//   }) {
//     return NationalIdState(
//       isLoading: isLoading ?? this.isLoading,
//       isConnected: isConnected ?? this.isConnected,
//       isRegistered: isRegistered ?? this.isRegistered,
//       isCompleted: isCompleted ?? this.isCompleted,
//       authUrl: authUrl ?? this.authUrl,
//       state: state ?? this.state,
//       error: error ?? this.error,
//       userData: userData ?? this.userData,
//     );
//   }
// }

// class FaydaUserData {
//   final String sub;
//   final String name;
//   final String email;
//   final String? phoneNumber;
//   final String? birthdate;
//   final String? gender;
//   final FaydaAddress? address;

//   const FaydaUserData({
//     required this.sub,
//     required this.name,
//     required this.email,
//     this.phoneNumber,
//     this.birthdate,
//     this.gender,
//     this.address,

//   });

//   factory FaydaUserData.fromJson(Map<String, dynamic> json) {
//     return FaydaUserData(
//       sub: json['sub'] as String,
//       name: json['name'] as String,
//       email: json['email'] as String,
//       phoneNumber: json['phone_number'] as String?,
//       birthdate: json['birthdate'] as String?,
//       gender: json['gender'] as String?,
//       address: json['address'] != null 
//           ? FaydaAddress.fromJson(json['address'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }

// class FaydaAddress {
//   final String? country;
//   final String? region;

//   const FaydaAddress({
//     this.country,
//     this.region,
//   });

//   factory FaydaAddress.fromJson(Map<String, dynamic> json) {
//     return FaydaAddress(
//       country: json['country'] as String?,
//       region: json['region'] as String?,
//     );
//   }
// } 



class NationalIdState {
  final bool isLoading;
  final bool isConnected;
  final bool isRegistered;
  final bool isCompleted;
  final String? authUrl;
  final String? state;
  final String? error;
  final FaydaUserData? userData;

  const NationalIdState({
    this.isLoading = false,
    this.isConnected = false,
    this.isRegistered = false,
    this.isCompleted = false,
    this.authUrl,
    this.state,
    this.error,
    this.userData,
  });

  NationalIdState copyWith({
    bool? isLoading,
    bool? isConnected,
    bool? isRegistered,
    bool? isCompleted,
    String? authUrl,
    String? state,
    String? error,
    FaydaUserData? userData,
  }) {
    return NationalIdState(
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      isRegistered: isRegistered ?? this.isRegistered,
      isCompleted: isCompleted ?? this.isCompleted,
      authUrl: authUrl ?? this.authUrl,
      state: state ?? this.state,
      error: error ?? this.error,
      userData: userData ?? this.userData,
    );
  }
}

class FaydaUserData {
  final String sub;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? birthdate;
  final String? gender;
  final String? picture;
  final FaydaAddress? address;

  const FaydaUserData({
    required this.sub,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.birthdate,
    this.gender,
    this.picture,
    this.address,
  });

  factory FaydaUserData.fromJson(Map<String, dynamic> json) {
    return FaydaUserData(
      sub: json['sub'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      birthdate: json['birthdate'] as String?,
      gender: json['gender'] as String?,
      picture: json['picture'] as String?, // new
      address: json['address'] != null 
          ? FaydaAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }
}

class FaydaAddress {
  final String? country;
  final String? region;
  final String? zone;   // new
  final String? woreda; // new

  const FaydaAddress({
    this.country,
    this.region,
    this.zone,
    this.woreda,
  });

  factory FaydaAddress.fromJson(Map<String, dynamic> json) {
    return FaydaAddress(
      country: json['country'] as String?,
      region: json['region'] as String?,
      zone: json['zone'] as String?,       // new
      woreda: json['woreda'] as String?,   // new
    );
  }
}
