import 'package:flutter/foundation.dart';
import '../models/trip_model.dart';
import '../models/auth_model.dart';

class TripContext {
  static final TripContext instance = TripContext._internal();
  TripContext._internal();

  final ValueNotifier<TripModel?> activeTripNotifier = ValueNotifier<TripModel?>(null);
  final ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier<UserModel?>(null);

  TripModel? get activeTrip => activeTripNotifier.value;
  set activeTrip(TripModel? trip) {
    activeTripNotifier.value = trip;
  }

  UserModel? get currentUser => currentUserNotifier.value;
  set currentUser(UserModel? user) {
    currentUserNotifier.value = user;
  }

  void logout() {
    currentUser = null;
    activeTrip = null;
  }
}
