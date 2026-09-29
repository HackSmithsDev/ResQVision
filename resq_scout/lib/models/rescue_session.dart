import 'emergency_action.dart';

/// Immutable emergency-request state owned by [rescueSessionProvider].
class RescueSession {
  const RescueSession(this._statuses);

  factory RescueSession.initial() => RescueSession({
    for (final type in EmergencyActionType.values)
      type: EmergencyRequestStatus.idle,
  });

  final Map<EmergencyActionType, EmergencyRequestStatus> _statuses;

  EmergencyRequestStatus statusFor(EmergencyActionType type) =>
      _statuses[type] ?? EmergencyRequestStatus.idle;

  bool isRequested(EmergencyActionType type) =>
      statusFor(type) != EmergencyRequestStatus.idle;

  RescueSession withStatus(
    EmergencyActionType type,
    EmergencyRequestStatus status,
  ) => RescueSession({..._statuses, type: status});
}
