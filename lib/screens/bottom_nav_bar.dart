import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crate_tracking_driver/user_provider.dart';
import 'package:crate_tracking_driver/screens/crates/crate_screen.dart';
import 'package:crate_tracking_driver/screens/home/home_screen.dart';
import 'package:crate_tracking_driver/screens/profile/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vehicleNumber = userProvider.vehicleNumber;

    if (index == currentIndex) return; // Prevents reloading the same page

    Widget screen;
    switch (index) {
      case 0:
        screen = HomeScreen(vehicleNumber: vehicleNumber);
        break;
      case 1:
        screen = CrateScreen();
        break;
      // case 2:
      //   screen = ProfileScreen();
      //   break;
      default:
        return;
    }

    // Using PageRouteBuilder for custom fade transition animation
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Define fade transition
          var opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

          return FadeTransition(opacity: opacityAnimation, child: child);
        },
        transitionDuration: const Duration(
          milliseconds: 600,
        ), // Set duration for smoothness
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      backgroundColor: const Color.fromARGB(255, 249, 139, 71),
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color.fromARGB(255, 112, 112, 112),
      type: BottomNavigationBarType.fixed,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart, size: 30),
          label: 'Crate Track',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.person, size: 30),
        //   label: 'Profile',
        // ),
      ],
      showUnselectedLabels: true,
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      selectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
