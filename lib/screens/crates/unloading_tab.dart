import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:crate_tracking_driver/user_provider.dart';
import 'package:flutter_searchable_dropdown/flutter_searchable_dropdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UnloadingTab extends StatefulWidget {
  const UnloadingTab({Key? key}) : super(key: key);

  @override
  _UnloadingTabState createState() => _UnloadingTabState();
}

class _UnloadingTabState extends State<UnloadingTab> {
  List<String> scannedCrates = [];
  bool isScanning = false;
  String? selectedLorry;
  String? selectedCustomer;
  String? selectedPoNumber;
  List<String> customers = [];
  List<String> poNumbers = [];
  String serverResponse = "";
  int totalScannedCrates = 0;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    selectedLorry = userProvider.vehicleNumber;
  }

  Future<List<String>> fetchCustomers() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://demo.secretary.lk/cargills_app/driver/backend/customers.php',
        ),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<String>.from(data);
      } else {
        throw Exception('Failed to load customers');
      }
    } on SocketException {
      throw ('No internet connection');
    } catch (e) {
      throw ('An error occurred: $e');
    }
  }

  Future<List<String>> fetchPoNumbers() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://demo.secretary.lk/cargills_app/driver/backend/po_numbers.php',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<String>.from(data);
      } else {
        throw Exception('Failed to load PO numbers');
      }
    } on SocketException {
      throw ('No internet connection');
    } catch (e) {
      throw ('An error occurred: $e');
    }
  }

  Future<void> _startScan() async {
    if (selectedLorry == null ||
        selectedCustomer == null ||
        selectedPoNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select lorry, customer and PO number first"),
        ),
      );
      return;
    }

    var status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        isScanning = true;
        scannedCrates.clear();
        serverResponse = "";
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera permission is required to scan QR codes"),
        ),
      );
    }
  }

  Future<void> _sendTotalCratesToDatabase() async {
    if (selectedLorry == null || totalScannedCrates == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a lorry and scan crates first"),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          'https://demo.secretary.lk/cargills_app/driver/backend/save_unload_total_crates.php',
        ),
        body: {
          'vehicle_no': selectedLorry!,
          'total_crates': totalScannedCrates.toString(),
        },
      );

      print("Response Code: ${response.statusCode}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData['message'])));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _doneScanning() {
    setState(() {
      isScanning = false;
      totalScannedCrates = scannedCrates.length;
      scannedCrates.clear();
    });

    _sendTotalCratesToDatabase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Total crates scanned: $totalScannedCrates")),
    );
  }

  Future<void> _sendToDatabase(String serialNumber) async {
    try {
      String bpCode = selectedCustomer!.split(' - ')[0];

      final response = await http.post(
        Uri.parse(
          'https://demo.secretary.lk/cargills_app/driver/backend/unloading_crate_log.php',
        ),
        body: {
          'serial': serialNumber,
          'vehicle_no': selectedLorry!,
          'customer': bpCode,
          'po_number': selectedPoNumber!,
        },
      );

      final responseData = json.decode(response.body);
      setState(() {
        if (response.statusCode == 200 && responseData["status"] == "success") {
          serverResponse = "Crate $serialNumber saved successfully!";
        } else if (responseData["status"] == "duplicate") {
          serverResponse = "You have already scanned this crate.";
        } else {
          serverResponse = "Failed to save crate: ${responseData["message"]}";
        }
      });
    } catch (e) {
      setState(() {
        serverResponse = "Error: ${e.toString()}";
      });
    }
  }

  void _resetPage() {
    setState(() {
      isScanning = false;
      scannedCrates.clear();
      selectedLorry = null;
      selectedCustomer = null;
      selectedPoNumber = null;
      serverResponse = "";
      totalScannedCrates = 0;
    });
  }

  Widget _buildTotalScannedCratesCard() {
    return Positioned(
      left: 16,
      top: 150,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 249, 139, 71),
                const Color.fromARGB(255, 255, 183, 77),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Scanned Crates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                totalScannedCrates.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildLocationDetailsCard(userProvider),
          if (totalScannedCrates > 0) _buildTotalScannedCratesCard(),
          if (selectedLorry != null ||
              selectedCustomer != null ||
              selectedPoNumber != null)
            _buildSelectedDetailsCard(),
          Center(
            child:
                isScanning
                    ? _buildScanner()
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCustomerSelection(userProvider),
                        _buildPoSelection(userProvider),
                        const SizedBox(height: 20),
                        _buildStartScanButton(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDetailsCard() {
    return Positioned(
      right: 16,
      top: 16,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 249, 139, 71),
                const Color.fromARGB(255, 255, 183, 77),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedLorry != null)
                Text(
                  'Selected Truck: $selectedLorry',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              if (selectedCustomer != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Customer: $selectedCustomer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (selectedPoNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'PO Number: $selectedPoNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSelection(UserProvider userProvider) {
    return FutureBuilder<List<String>>(
      future: fetchCustomers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitThreeBounce(
            color: Color.fromARGB(255, 249, 139, 71),
            size: 30.0,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No customers available');
        } else {
          customers = snapshot.data!;
          return Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 249, 139, 71),
                width: 2,
              ),
            ),
            child: SearchableDropdown<String>(
              items:
                  customers
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
              value: selectedCustomer,
              hint: const Text('Select Customer'),
              searchHint: const Text('Search customer'),
              onChanged: (value) {
                setState(() {
                  selectedCustomer = value;
                });
              },
              isExpanded: true,
            ),
          );
        }
      },
    );
  }

  Widget _buildPoSelection(UserProvider userProvider) {
    return FutureBuilder<List<String>>(
      future: fetchPoNumbers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitThreeBounce(
            color: Color.fromARGB(255, 249, 139, 71),
            size: 30.0,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No PO numbers available');
        } else {
          poNumbers = snapshot.data!;
          return Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromARGB(255, 249, 139, 71),
                width: 2,
              ),
            ),
            child: SearchableDropdown<String>(
              items:
                  poNumbers
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
              value: selectedPoNumber,
              hint: const Text('Select PO Number'),
              searchHint: const Text('Search PO number'),
              onChanged: (value) {
                setState(() {
                  selectedPoNumber = value;
                });
              },
              isExpanded: true,
            ),
          );
        }
      },
    );
  }

  Widget _buildLocationDetailsCard(UserProvider userProvider) {
    return Positioned(
      left: 16,
      top: 16,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 249, 139, 71),
                const Color.fromARGB(255, 255, 183, 77),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userProvider.subLocationName.isNotEmpty)
                      Text(
                        'Sub Location: ${userProvider.subLocationName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (userProvider.divisionsName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Division: ${userProvider.divisionsName}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/crate_image.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartScanButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt,
          size: 100,
          color: const Color.fromARGB(255, 249, 139, 71),
        ),
        const SizedBox(height: 20),
        const Text(
          "Scan the QR Code",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Please scan the crate details",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: selectedLorry != null ? _startScan : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedLorry != null
                    ? const Color.fromARGB(255, 249, 139, 71)
                    : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text("Start Scan"),
        ),
      ],
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/background_pattern.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.9),
            BlendMode.lighten,
          ),
        ),
      ),
    );
  }

  Widget _buildScanner() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: MobileScanner(
            onDetect: (BarcodeCapture capture) async {
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null &&
                    barcode.format == BarcodeFormat.qrCode) {
                  String serialNumber = barcode.rawValue!;
                  if (!scannedCrates.contains(serialNumber)) {
                    setState(() {
                      scannedCrates.add(serialNumber);
                    });
                    await _sendToDatabase(serialNumber);
                  }
                }
              }
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Scanned Crates: ${scannedCrates.length}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (serverResponse.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    serverResponse,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          serverResponse.contains("successfully")
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: scannedCrates.length,
                  itemBuilder:
                      (context, index) =>
                          ListTile(title: Text(scannedCrates[index])),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _doneScanning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 5, 168, 29),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text("Done Scanning"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _resetPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text("Exit"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
