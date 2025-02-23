import 'package:crate_tracking_driver/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({Key? key}) : super(key: key);

  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _vehicleController = TextEditingController();
  bool _isLoading = false;

  static const Color primaryColor = Color.fromARGB(255, 252, 132, 58);
  static const Color secondaryColor = Color.fromARGB(255, 43, 4, 4);
  static const Color buttonColor = Color.fromARGB(255, 241, 119, 62);

  Future<void> vehicleVerify(String vehicleNumber) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
      'https://demo.secretary.lk/cargills_app/driver/backend/vehicle_checking.php',
    );

    try {
      final response = await http.post(
        url,
        body: {'vehicle_no': vehicleNumber},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        switch (data['status']) {
          case 'success':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomeScreen(vehicleNumber: vehicleNumber),
              ),
            );
            break;
          case 'access_denied':
            _showAlert('Access denied. Vehicle number not found.', null);
            break;
          case 'error':
            _showAlert(data['message'], null);
            break;
          default:
            _showAlert('Unexpected response from server.', null);
        }
      } else {
        _showAlert(
          'HTTP Error: ${response.statusCode}. Please try again later.',
          null,
        );
      }
    } catch (e) {
      _showAlert('No internet connection. Please try again later.', null);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAlert(String message, VoidCallback? onOkPressed) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Alert'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onOkPressed != null) onOkPressed();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FadeIn(
            duration: const Duration(milliseconds: 1000),
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 32,
                ),
                child: Column(
                  children: [
                    BounceInUp(
                      duration: const Duration(milliseconds: 1200),
                      child: Image.asset(
                        'assets/images/truck.png',
                        width: 200,
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Verification',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Enter your vehicle number for verification.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _vehicleController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your Vehicle number",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.fire_truck,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final vehicleNumber = _vehicleController.text.trim();
                          if (vehicleNumber.isEmpty) {
                            _showAlert('Please enter a vehicle number.', null);
                          } else {
                            vehicleVerify(vehicleNumber);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('Verify'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
