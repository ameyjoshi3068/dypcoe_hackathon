import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/disease.dart';
import 'package:http/http.dart' as http;

class DiseaseDetailsWidget extends StatelessWidget {
  final Disease disease;

  const DiseaseDetailsWidget({
    super.key,
    required this.disease,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDescription(),
            const SizedBox(height: 16),
            disease.identification.name == 'Invalid Image'
                ? const SizedBox.shrink()
                : _buildSeverity(),
            const SizedBox(height: 16),
            disease.identification.name == 'Invalid Image'
                ? const SizedBox.shrink()
                : _buildSymptoms(),
            const SizedBox(height: 16),
            disease.identification.name == 'Invalid Image'
                ? const SizedBox.shrink()
                : _buildTreatments(),
            const SizedBox(height: 16),
            disease.identification.name == 'Invalid Image'
                ? const SizedBox.shrink()
                : ElevatedButton.icon(
                    onPressed: () => _showDosePredictionDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 211, 236, 248),
                    ),
                    icon: const Icon(Icons.calculate),
                    label: const Text('Predict Dose'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  disease.identification.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              disease.identification.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Severity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              disease.identification.severity,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptoms() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Symptoms',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: disease.identification.symptoms.length,
              itemBuilder: (context, index) {
                final symptom = disease.identification.symptoms[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ExpansionTile(
                    title: Text(
                      symptom.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          symptom.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Treatments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTreatmentSection(
              'Prevention Methods',
              disease.identification.treatment.prevention,
              Icons.shield_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildTreatmentSection(
              'Chemical Control',
              disease.identification.treatment.chemical,
              Icons.science_outlined,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildTreatmentSection(
              'Biological Control',
              disease.identification.treatment.biological,
              Icons.eco_outlined,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return ExpansionTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      items[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showDosePredictionDialog(BuildContext context) {
    String cropType = 'Rice'; // Default value
    String growthStage = 'Seedling';
    String fertilizerName = '';
    double plotSize = 1.0;

    final List<String> cropTypes = [
      "Rice",
      "Wheat",
      "Maize",
      "Barley",
      "Lentils",
      "Beans",
      "Soybean",
      "Groundnut",
      "Sunflower",
      "Tomato",
      "Potato",
      "Onion",
      "Brinjal (Eggplant)",
      "Mango",
      "Banana",
      "Apple",
      "Grapes",
      "Cotton",
      "Sugarcane",
      "Coffee",
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Predict Medicine Dose'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: cropType,
                      decoration: const InputDecoration(
                        labelText: 'Crop Type',
                      ),
                      items: cropTypes
                          .map((crop) => DropdownMenuItem(
                                value: crop,
                                child: Text(crop),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => cropType = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: growthStage,
                      decoration: const InputDecoration(
                        labelText: 'Growth Stage',
                      ),
                      items: ['Seedling', 'Vegetative', 'Flowering', 'Maturity']
                          .map((stage) => DropdownMenuItem(
                                value: stage,
                                child: Text(stage),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => growthStage = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Fertilizer Name',
                      ),
                      onChanged: (value) {
                        setState(() => fertilizerName = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (plotSize > 0.5) plotSize -= 0.5;
                            });
                          },
                        ),
                        Expanded(
                          child: Slider(
                            value: plotSize,
                            min: 0.5,
                            max: 10.0,
                            divisions: 19,
                            label: '$plotSize Acres',
                            onChanged: (value) {
                              setState(() => plotSize = value);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              if (plotSize < 10.0) plotSize += 0.5;
                            });
                          },
                        ),
                        Text('${plotSize.toStringAsFixed(1)} Acres'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _predictDose(
                    context,
                    cropType,
                    growthStage,
                    fertilizerName,
                    plotSize,
                  ),
                  child: const Text('Predict'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _predictDose(
    BuildContext context,
    String cropType,
    String growthStage,
    String fertilizerName,
    double plotSize,
  ) async {
    try {
      log("sending request");
      final response = await http.post(
        Uri.parse('http://192.168.137.10:5000/doseprediction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'crop_type': cropType.toLowerCase(),
          'growth_stage': growthStage,
          'fertilizer_name': fertilizerName,
          'plot_size': '$plotSize Acres',
        }),
      );
      log("Request body: ${jsonEncode({
            'crop_type': cropType.toLowerCase(),
            'growth_stage': growthStage,
            'fertilizer_name': fertilizerName,
            'plot_size': '$plotSize Acres',
          })}");

      log("response: ${response.body}");

      log("response sent");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        result = result["Dose prediction"];
        Navigator.pop(context); // Close the input dialog
        _showResultDialog(context, result);
      } else {
        throw Exception('Failed to predict dose');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      log("error: $e");
    }
  }

  void _showResultDialog(BuildContext context, Map<String, dynamic> result) {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Recommended Dose'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.science, color: Colors.blue),
                  title: const Text('Fertilizer'),
                  subtitle: Text(result['fertilizer']),
                ),
                ListTile(
                  leading: const Icon(Icons.scale, color: Colors.green),
                  title: const Text('Quantity'),
                  subtitle: Text(result['quantity']),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      log("Error in showing result dialog: $e");
    }
  }
}
