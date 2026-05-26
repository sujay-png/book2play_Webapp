import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class sidebar extends StatefulWidget {
  final Widget child;

  const sidebar({super.key, required this.child});

  @override
  State<sidebar> createState() => _sidebarState();
}

class _sidebarState extends State<sidebar> {
  Widget _navItem(
    BuildContext context, {
    required String route,
    required IconData icon,
    required String label,
    bool isenabled = true,
  }) {
    // Correctly fetching current path for highlighting
    final currentPath = GoRouterState.of(context).uri.path;
    final isSelected = currentPath == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Opacity(
        opacity: isenabled ? 1.0 : 0.4,
        child: InkWell(
          onTap: isenabled ? () => context.go(route) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // Mint green background with low opacity for selected item
              color: isSelected
                  ? const Color(0xFF00D9A3).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? const Color(0xFF00D9A3) : Colors.white54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 3, 3), // Deep dark theme
      // FIX: Wrapped everything in a Row
      body: Row(
        children: [
          // 1. Sidebar
          Container(
            width: 260, // Increased from 100 to fit "BOOK2PLAY" text
            decoration: const BoxDecoration(
              color: Color(0xFF0A1212),
              border: Border(right: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              children: [
                // Header with Logo
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flash_on_rounded,
                        color: Color(0xFF00D9A3),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "BOOK2PLAY",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Navigation Items
                Expanded(
                  child: ListView(
                    children: [
                      _navItem(
                        context,
                        route: '/',
                        icon: Icons.grid_view_rounded,
                        label: "Dashboard",
                      ),
                      _navItem(
                        context,
                        route: '/bookings',
                        icon: Icons.calendar_today_outlined,
                        label: "Manual Bookings",
                      ),
                      _navItem(
                        context,
                        route: '/allbookings',
                        icon: Icons.stacked_bar_chart_outlined,
                        label: "All Bookings",
                      ),
                      _navItem(
                        context,
                        route: '/freeslots',
                        icon: Icons.trending_up_outlined,
                        label: "Free solts & Ads",
                      ),
                      _navItem(
                        context,
                        route: '/accounts',
                        icon: Icons.attach_money_outlined,
                        label: "Accounts",
                      ),
                      _navItem(
                        context,
                        route: '/reminders',
                        icon: Icons.notifications_active,
                        label: "Reminders",
                      ),

                      // _navItem(context, route: '/memberclub', icon: Icons.people_alt_outlined  , label: "Members Club(Upcomming)", isenabled: false),
                      // _navItem(context, route: '/events', icon: Icons.chat_bubble_rounded, label: "Create Events(Upcomming)", isenabled: false),
                      // _navItem(context, route: '/displayevents', icon: Icons.event, label: "Events(Upcomming)", isenabled: false),
                    ],
                  ),
                ),

                // Sign Out Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => _handleSignOut(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Sign Out",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Content Area (Rounded Canvas style)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Ensure router takes user to the correct login path
      context.go('/login');
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
  }
}
