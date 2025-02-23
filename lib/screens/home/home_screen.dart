import 'dart:convert';
import 'dart:io'; // Import for SocketException
import 'package:crate_tracking_driver/screens/bottom_nav_bar.dart';
import 'package:crate_tracking_driver/screens/home/widgets/functions.dart';
import 'package:crate_tracking_driver/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String vehicleNumber;

  const HomeScreen({Key? key, required this.vehicleNumber}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> fetchUserDetails() async {
    final url = Uri.parse(
      "https://demo.secretary.lk/cargills_app/driver/backend/user_details.php",
    );

    try {
      final response = await http.post(
        url,
        body: {'vehicleNumber': widget.vehicleNumber},
      );

      print("Response body: ${response.body}");

      final data = jsonDecode(response.body);
      print("Decoded JSON: $data");

      if (data['status'] == 'success') {
        final user = data['data']; // Changed from 'user' to 'data'

        print("User data: $user");
        print("Data types:");
        user.forEach((key, value) {
          print("$key: ${value.runtimeType}");
        });

        Provider.of<UserProvider>(context, listen: false).setUser(
          vehicleNumber: widget.vehicleNumber,
          subLocationId: user['sub_location_id'].toString(),
          divisionsId: user['divisions_id'].toString(),
          divisionsName: user['division_name'].toString(),
          subLocationName: user['sub_location_name'].toString(),
        );
      } else {
        print("Vehicle not found: ${data['message']}");
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No internet connection"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void _logout() {
    Provider.of<UserProvider>(context, listen: false);
    Navigator.pushReplacementNamed(context, '/vehicle');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 252, 132, 58),
        elevation: 5,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Vehicle No: ${userProvider.vehicleNumber}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),

              // Profile Icon with Logout Button
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout();
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Logout', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 252, 132, 58),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),

      body: Stack(
        children: [
          // Background Image with Repeat Pattern
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                opacity: 0.1,
                image: AssetImage("assets/images/background_pattern.jpg"),
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [SizedBox(height: 20), FunctionsWidget()],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
