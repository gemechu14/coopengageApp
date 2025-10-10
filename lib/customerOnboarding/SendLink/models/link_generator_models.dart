/// Models for Link Generator feature
/// Following clean architecture principles

import 'package:flutter/material.dart';

/// Enum for account types
enum AccountType {
  individual,
  joint,
  organization;

  String get apiValue {
    switch (this) {
      case AccountType.individual:
        return 'INDIVIDUAL';
      case AccountType.joint:
        return 'JOINT';
      case AccountType.organization:
        return 'ORGANIZATION';
    }
  }

  String get displayName => apiValue;
}

/// Enum for share platforms
enum SharePlatform {
  whatsapp,
  telegram,
  email;

  String get apiValue {
    switch (this) {
      case SharePlatform.whatsapp:
        return 'WHATSAPP';
      case SharePlatform.telegram:
        return 'TELEGRAM';
      case SharePlatform.email:
        return 'EMAIL';
    }
  }

  IconData get iconData {
    switch (this) {
      case SharePlatform.whatsapp:
        return Icons.chat; // WhatsApp (Flutter doesn't have built-in WhatsApp icon)
      case SharePlatform.telegram:
        return Icons.telegram;
      case SharePlatform.email:
        return Icons.email;
    }
  }

  Color get color {
    switch (this) {
      case SharePlatform.whatsapp:
        return const Color(0xFF25D366);
      case SharePlatform.telegram:
        return const Color(0xFF229ED9);
      case SharePlatform.email:
        return Colors.redAccent;
    }
  }

  String get displayName => apiValue;
}

/// Request model for generating link
class LinkGenerationRequest {
  final AccountType accountType;
  final SharePlatform platform;
  final String? recipientName;
  final String? recipientPhone;
  final String? email;

  const LinkGenerationRequest({
    required this.accountType,
    required this.platform,
    this.recipientName,
    this.recipientPhone,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'linkType': accountType.apiValue,
      'platform': platform.apiValue,
    };

    if (recipientName != null && recipientName!.trim().isNotEmpty) {
      json['recipientName'] = recipientName!.trim();
    }
    if (recipientPhone != null && recipientPhone!.trim().isNotEmpty) {
      json['recipientPhone'] = recipientPhone!.trim();
    }
    if (email != null && email!.trim().isNotEmpty) {
      json['email'] = email!.trim();
    }

    return json;
  }

  LinkGenerationRequest copyWith({
    AccountType? accountType,
    SharePlatform? platform,
    String? recipientName,
    String? recipientPhone,
    String? email,
  }) {
    return LinkGenerationRequest(
      accountType: accountType ?? this.accountType,
      platform: platform ?? this.platform,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      email: email ?? this.email,
    );
  }
}

/// Response model for link generation
class LinkGenerationResponse {
  final String shareableLink;
  final String? platformSpecificUrl;
  final String? qrCodeUrl;
  final String? message;

  const LinkGenerationResponse({
    required this.shareableLink,
    this.platformSpecificUrl,
    this.qrCodeUrl,
    this.message,
  });

  factory LinkGenerationResponse.fromJson(Map<String, dynamic> json) {
    // Handle potential null or missing shareableLink
    final shareableLink = json['shareableLink'] as String? ?? '';
    
    // Handle both 'message' and 'formattedMessage' from API
    final message = json['message'] as String? ?? 
                    json['formattedMessage'] as String?;
    
    return LinkGenerationResponse(
      shareableLink: shareableLink,
      platformSpecificUrl: json['platformSpecificUrl'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String?,
      message: message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareableLink': shareableLink,
      'platformSpecificUrl': platformSpecificUrl,
      'qrCodeUrl': qrCodeUrl,
      'message': message,
    };
  }

  LinkGenerationResponse copyWith({
    String? shareableLink,
    String? platformSpecificUrl,
    String? qrCodeUrl,
    String? message,
  }) {
    return LinkGenerationResponse(
      shareableLink: shareableLink ?? this.shareableLink,
      platformSpecificUrl: platformSpecificUrl ?? this.platformSpecificUrl,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      message: message ?? this.message,
    );
  }
}

/// State model for link generator
class LinkGeneratorState {
  final bool isLoading;
  final String? errorMessage;
  final LinkGenerationResponse? result;

  const LinkGeneratorState({
    this.isLoading = false,
    this.errorMessage,
    this.result,
  });

  LinkGeneratorState copyWith({
    bool? isLoading,
    String? errorMessage,
    LinkGenerationResponse? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return LinkGeneratorState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasResult => result != null;
}

