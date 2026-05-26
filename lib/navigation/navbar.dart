import 'dart:async';

import 'package:booktoplay_webapp/auth/login.dart';
import 'package:booktoplay_webapp/navigation/shell.dart';
import 'package:booktoplay_webapp/pages/Reminder/reminder.dart';
import 'package:booktoplay_webapp/pages/accounts/accounts.dart';
import 'package:booktoplay_webapp/pages/bookings/allbookings.dart';
import 'package:booktoplay_webapp/pages/bookings/bookings.dart';
import 'package:booktoplay_webapp/pages/dashboard/dashboard.dart';
import 'package:booktoplay_webapp/pages/freeslots/freeslots.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


final _authListenable = FirebaseAuthListenable();
  final FirebaseAuth _auth = FirebaseAuth.instance;


class FirebaseAuthListenable extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;
  FirebaseAuthListenable() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen(
      (_) => notifyListeners(),
    );
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: _authListenable,
  routes: [
    // 1. Move root '/' inside the ShellRoute
    ShellRoute(
      builder: (context, state, child) => ShellPage(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Dashboard(),
        ),
        GoRoute(
          path: '/bookings',
          builder: (context, state) => const Bookings(), // Replace with actual TicketsPage
        ),
        GoRoute(
          path: '/allbookings',
          builder: (context, state) => const Allbookings(), // Replace with actual AllBookingsPage
        ),
          GoRoute(
          path: '/freeslots',
          builder: (context, state) => const Freeslots(), // Replace with actual FreeSlotsPage
        ),
         GoRoute(
          path: '/accounts',
          builder: (context, state) => const Accounts(), // Replace with actual AllBookingsPage
        ),
      
        GoRoute(
          path: '/reminders',
          builder: (context, state) => const Reminder(), 
        ),
//         GoRoute(
//           path: '/memberclub',
//           builder: (context, state) => const Membersclub(),

//         ),
//          GoRoute(
//           path: '/events',
//           builder: (context, state) => const Events(),
//         ),
//       GoRoute(
//   path: '/displayevents',
//   builder: (context, state) {
//     // Cast the extra parameter safely to your EventModel type
//     final eventModel = state.extra as EventModel?;

//     return Displayevents(event: eventModel); // Pass the eventModel to your Displayevents page;
//   },
// ),
      ],
    ),
    
    // 2. Routes OUTSIDE the Shell (like Login)
    GoRoute(
      path: '/login',
      builder: (context, state) => const MobileLoging(),
    ),
  ],
);