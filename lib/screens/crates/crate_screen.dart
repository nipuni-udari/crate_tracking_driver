import 'package:flutter/material.dart';
import 'package:crate_tracking_driver/screens/bottom_nav_bar.dart';
//import 'package:crate_tracking_driver/screens/crates/loading_tab.dart';
import 'package:crate_tracking_driver/screens/crates/unloading_tab.dart';
import 'package:crate_tracking_driver/screens/crates/collecting_tab.dart';
//import 'package:crate_tracking_driver/screens/crates/receiving_tab.dart';

class CrateScreen extends StatefulWidget {
  const CrateScreen({Key? key}) : super(key: key);

  @override
  _CrateScreenState createState() => _CrateScreenState();
}

class _CrateScreenState extends State<CrateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        title: const Text(
          "Crate Tracking",
          style: TextStyle(color: Colors.black), // Title in white
        ),
        backgroundColor: const Color.fromARGB(255, 249, 139, 71),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black, // Active tab text color
          unselectedLabelColor: Colors.white, // Inactive tab text color
          tabs: const [
            //Tab(text: "Loading"),
            Tab(text: "Unloading"),
            Tab(text: "Collecting"),
            //Tab(text: "Receiving"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          //LoadingTab(),
          UnloadingTab(),
          CollectingTab(),
          //ReceivingTab(),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
