import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/emergency_action.dart';
import '../models/rescue_session.dart';

final rescueSessionProvider =
    NotifierProvider<RescueSessionNotifier, RescueSession>(
      RescueSessionNotifier.new,
    );

class RescueSessionNotifier extends Notifier<RescueSession> {
  @override
  RescueSession build() => RescueSession.initial();

  void submitEmergency(EmergencyActionType type) {
    state = state.withStatus(type, EmergencyRequestStatus.dispatched);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (state.statusFor(type) == EmergencyRequestStatus.dispatched) {
        state = state.withStatus(type, EmergencyRequestStatus.enRoute);
      }
    });
  }

  void cancelEmergency(EmergencyActionType type) {
    state = state.withStatus(type, EmergencyRequestStatus.idle);
  }
}
