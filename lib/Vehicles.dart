import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shell_mobile/services/vehicle_service.dart';

import 'constants.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  _VehiclesPageState createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  bool isLoading = true;
  Map<String, dynamic>? vehicleData;

  @override
  void initState() {
    super.initState();
    fetchVehicleData();
  }

  Future<void> fetchVehicleData() async {
    final service = VehicleService(); // Create an instance of your service class
    final data = await service.getVehicle();
    setState(() {
      isLoading = false;
      vehicleData = data?["vehicle"];
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      );
    }

    String formattedDate = "No data";
    String formattedTime = "";
    if (vehicleData == null) {
     return _addVehicle(context);
    } else {
      try {
        final lastOilChangeDate = DateTime.parse(
            vehicleData!["lastOilChange"].toString());
        formattedDate =
            DateFormat("dd MMMM yyyy").format(lastOilChangeDate);
        formattedTime = DateFormat("hh:mm a").format(lastOilChangeDate);
      } catch (ex){
        formattedDate = "No data";
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20,15,20,0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              ListTile(
                leading: const Icon(Icons.car_rental),
                title: Text(
                  '${vehicleData?["brand"]} ${vehicleData?["model"]}',
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  'Licence plate: ${vehicleData?["matricule"]}',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Year: ${vehicleData?["year"]}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.local_gas_station),
                title: Text(
                  'Fuel Type: ${vehicleData?["fuelType"]}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.speed,
                  color: secondary,
                ),
                title: Text(
                  'Mileage: ${vehicleData?["mileage"]} km',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.history,
                  color: secondary,
                ),
                title: const Text(
                  'Last Oil Change:',
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  '$formattedDate\n$formattedTime',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 15), // Add some spacing between the content and buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Implement your delete logic here
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary,
                    ),
                    onPressed: () {
                      // Implement your update logic here
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }
  Widget _addVehicle(context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _header(context), // Place header at the top
        const SizedBox(height: 10),
        Image.asset(
          'assets/no_results_found.png', // Replace with the actual path to your image
          width: 350, // Set the desired width of the image
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            // Implement your logic here
          },
          icon: Icon(Icons.add), // "+" icon
          label: const Text(
            'Add vehicle',
            style: TextStyle(
              color: Colors.black, // Text color of the button
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: primary,
          ),
        ),
      ],
    );
  }




  Widget _header(context) {
    return const Column(
      children: [
        Center(
          child: CircleAvatar(
            backgroundColor: secondary,
            radius: 40,
            child: Icon(
              Icons.car_rental,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Text(
            'Vehicle Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
