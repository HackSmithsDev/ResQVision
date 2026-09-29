import 'package:flutter/material.dart';

enum EmergencyActionType { sos, medical, stretcher, helicopter }

enum EmergencyRequestStatus { idle, requested, dispatched, enRoute }

class EmergencyActionDetails {
  const EmergencyActionDetails({
    required this.type,
    required this.title,
    required this.shortTitle,
    required this.subtitle,
    required this.description,
    required this.voicePrompt,
    required this.requestLabel,
    required this.confirmationTitle,
    required this.confirmationMessage,
    required this.unitLabel,
    required this.unitName,
    required this.distance,
    required this.eta,
    required this.accent,
    required this.icon,
    this.landingZone,
  });

  final EmergencyActionType type;
  final String title;
  final String shortTitle;
  final String subtitle;
  final String description;
  final String voicePrompt;
  final String requestLabel;
  final String confirmationTitle;
  final String confirmationMessage;
  final String unitLabel;
  final String unitName;
  final String distance;
  final String eta;
  final Color accent;
  final IconData icon;
  final String? landingZone;

  bool get isSos => type == EmergencyActionType.sos;
  bool get isHelicopter => type == EmergencyActionType.helicopter;

  factory EmergencyActionDetails.fromJson(Map<String, dynamic> json) =>
      EmergencyActionDetails(
        type: EmergencyActionType.values.byName(json['type'] as String),
        title: json['title'] as String,
        shortTitle: json['shortTitle'] as String,
        subtitle: json['subtitle'] as String,
        description: json['description'] as String,
        voicePrompt: json['voicePrompt'] as String,
        requestLabel: json['requestLabel'] as String,
        confirmationTitle: json['confirmationTitle'] as String,
        confirmationMessage: json['confirmationMessage'] as String,
        unitLabel: json['unitLabel'] as String,
        unitName: json['unitName'] as String,
        distance: json['distance'] as String,
        eta: json['eta'] as String,
        accent: Color(json['accentColor'] as int),
        icon: IconData(
          // The runtime code point comes from future backend JSON.
          // ignore: non_const_argument_for_const_parameter
          json['iconCodePoint'] as int,
          fontFamily: 'MaterialIcons',
        ),
        landingZone: json['landingZone'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'title': title,
    'shortTitle': shortTitle,
    'subtitle': subtitle,
    'description': description,
    'voicePrompt': voicePrompt,
    'requestLabel': requestLabel,
    'confirmationTitle': confirmationTitle,
    'confirmationMessage': confirmationMessage,
    'unitLabel': unitLabel,
    'unitName': unitName,
    'distance': distance,
    'eta': eta,
    'accentColor': accent.toARGB32(),
    'iconCodePoint': icon.codePoint,
    'landingZone': landingZone,
  };
}
