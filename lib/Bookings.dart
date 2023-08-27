import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shell_mobile/constants.dart';
import 'package:shell_mobile/services/consultations_service.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<dynamic>? _consultationsData;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchConsultationData();
  }
  Future<void> fetchConsultationData() async {
    final service = ConsultationsService(); // Create an instance of your service class
    final data = await service.getConsultationsHistory();
    setState(() {
      _consultationsData = data?["consultations"];
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      );
    }
    else if (_consultationsData == null || _consultationsData!.isEmpty) {
      return _noData(context);
    }
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20,15,20,0),
        child: Column(
          children: [
            _header(context),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _consultationsData?.length,
              itemBuilder: (context, index) {
                final consultation = _consultationsData?[index];
                final consultationDate = DateTime.parse(consultation['dateConsultation']);
                List consultationServices = consultation['consultation_service'];
                String servicesNames = consultationServices != null
                    ? consultationServices
                    .map<String>((service) => jsonDecode(service['service']['label'])['en'])
                    .join(', ')
                    : "";
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: secondary,
                      radius: 30,
                      child: Icon(
                        Icons.description,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      DateFormat.yMMMMd().format(consultationDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ${consultation['price']}TND'),
                        Text('Employee: ${consultation['employee']['user']['firstName']} ${consultation['employee']['user']['lastName']}'),
                        Text('Services: $servicesNames'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _noData(context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _header(context), // Place header at the top
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/no_results_found.png', // Replace with the actual path to your image
                  width: 400, // Set the desired width of the image
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 100),
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
              Icons.history,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child:Text(
            'Maintenance History',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

}
