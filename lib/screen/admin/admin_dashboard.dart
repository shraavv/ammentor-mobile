import 'package:ammentor/components/theme.dart';
import 'package:ammentor/screen/admin/dashboard_screen.dart';
import 'package:ammentor/screen/leaderboard/view/leaderboard_screen.dart';
import 'package:ammentor/screen/profile/view/profile_screen.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _page=0;

  final List<Widget> _pages = [
    DashboardScreen(),
    ProfileScreen(),
    LeaderboardScreen()
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard, label: "Dashboard"),
    _NavItem(icon: Icons.person, label: "Profile"),
    _NavItem(icon: Icons.leaderboard, label: "Leaderboard"),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: _pages[_page],
      bottomNavigationBar: Container(
        
        padding: EdgeInsets.symmetric(horizontal: screenWidth*0.01 , vertical: screenHeight*0.03),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final isSelected = _page == index;

            return GestureDetector(
              onTap: () => setState(() => _page = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 0,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: .1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? AppColors.primary : Colors.white,
                      size: 22,
                    ),
                    if (isSelected) ...[
                       SizedBox(width: screenWidth * 0.02),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}