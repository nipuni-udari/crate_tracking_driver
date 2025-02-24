import 'package:crate_tracking_driver/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'dart:async';

class FunctionsWidget extends StatefulWidget {
  const FunctionsWidget({Key? key}) : super(key: key);

  @override
  _FunctionsWidgetState createState() => _FunctionsWidgetState();
}

class _FunctionsWidgetState extends State<FunctionsWidget> {
  //String loadingCount = '0';
  String unloadingCount = '0';
  String collectingCount = '0';
  //String receivingCount = '0';
  String exactCratesCount = '0';
  String systemCratesCount = '0';

  Timer? _refreshTimer;

  Future<void> searchTruck(String truckNo) async {
    if (truckNo.isEmpty) {
      setState(() {
        //loadingCount = '0';
        unloadingCount = '0';
        collectingCount = '0';
        //receivingCount = '0';
      });
      return;
    }

    final response = await http.post(
      Uri.parse(
        'https://demo.secretary.lk/cargills_app/driver/backend/crate_tracking_counts.php',
      ),
      body: {'truckNo': truckNo},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print("Response Data: $data"); // Debugging: Print the response data
      setState(() {
        //loadingCount = data['loading']?.toString() ?? '0';
        unloadingCount = data['unloading']?.toString() ?? '0';
        collectingCount = data['collecting']?.toString() ?? '0';
        //receivingCount = data['receiving']?.toString() ?? '0';
        exactCratesCount = data['exact_crates_count']?.toString() ?? '0';
        systemCratesCount = data['system_crates_count']?.toString() ?? '0';
      });
    } else {
      print("Failed to fetch data");
    }
  }

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String vehicleNumber = userProvider.vehicleNumber;

    // Automatically search for the truck when the widget is initialized
    searchTruck(vehicleNumber);

    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String vehicleNumber = userProvider.vehicleNumber;

      searchTruck(vehicleNumber); // Refresh truck-specific data
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String vehicleNumber = userProvider.vehicleNumber;

    return Column(
      children: [
        // Special Offer Banner
        SpecialOfferBanner(
          exactCratesCount: exactCratesCount,
          systemCratesCount: systemCratesCount,
        ),
        // TextField for Truck No
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  readOnly: true, // Make the text field read-only
                  controller: TextEditingController(text: vehicleNumber),
                  style: const TextStyle(color: Colors.orange),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Truck No',
                    labelStyle: const TextStyle(color: Colors.orange),
                    border: InputBorder.none,
                    prefixIcon: const Icon(
                      Icons.local_shipping,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Function Cards
        // FunctionCard(
        //   title: "Loading",
        //   description: "Loading crates to the truck",
        //   imagePath: "assets/images/loading.png",
        //   count: loadingCount,
        //   exactCount: exactCratesCount,
        // ),
        const SizedBox(height: 15),
        FunctionCard(
          title: "Unloading",
          description: "Unloading crates from the truck",
          imagePath: "assets/images/unloading.webp",
          count: unloadingCount,
          exactCount: exactCratesCount,
        ),
        const SizedBox(height: 15),
        FunctionCard(
          title: "Collecting",
          description: "Collecting crates from the customer",
          imagePath: "assets/images/collect.webp",
          count: collectingCount,
          exactCount: exactCratesCount,
        ),
        // const SizedBox(height: 15),
        // FunctionCard(
        //   title: "Receiving",
        //   description: "Hand over crates to the warehouse",
        //   imagePath: "assets/images/receiving.jpg",
        //   count: receivingCount,
        //   exactCount: exactCratesCount,
        // ),
      ],
    );
  }
}

class FunctionCard extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final String count;
  final String exactCount;

  const FunctionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.count,
    required this.exactCount,
  }) : super(key: key);

  @override
  _FunctionCardState createState() => _FunctionCardState();
}

class _FunctionCardState extends State<FunctionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomIn() {
    _controller.forward().then((_) {
      Future.delayed(Duration(milliseconds: 300), () {
        _controller.reverse();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _zoomIn,
      child: ScaleTransition(
        scale: _animation,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.count,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.description,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              "Exact crates count: ${widget.exactCount}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              backgroundColor: Colors.orange,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.fire_truck,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  // Handle button click
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Special Offer Banner Widget
class SpecialOfferBanner extends StatelessWidget {
  final String exactCratesCount;
  final String systemCratesCount;

  const SpecialOfferBanner({
    Key? key,
    required this.exactCratesCount,
    required this.systemCratesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 203, 70, 17),
              Color.fromARGB(255, 243, 161, 60),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Left side: Image and text
            Expanded(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/crate_image.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Track Crates Like a Pro!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Never lose a crate again! '
                          'Our app provides real-time tracking, analytics, and more. ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Right side: Buttons stacked vertically
            Column(
              children: [
                // Exact Crate Count Button
                ElevatedButton(
                  onPressed: () {
                    // Add your action here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Exact crate Count: $exactCratesCount',
                    style: TextStyle(
                      color: Color.fromARGB(255, 252, 37, 37),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Space between buttons
                // System Crate Count Button
                ElevatedButton(
                  onPressed: () {
                    // Add your action here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'System crate Count: $systemCratesCount',
                    style: TextStyle(
                      color: Color.fromARGB(255, 252, 37, 37),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
