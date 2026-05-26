import 'package:flutter/material.dart';
class ShellPage extends StatelessWidget {
  final Widget child;
  const ShellPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Detect the current location to highlight the sidebar menu
   // final String location = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1212), // Signature Dark Background
      body: Row(
        children: [        
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12), // Adds space around the main content
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black, // Main content background
                borderRadius: BorderRadius.circular(24),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}