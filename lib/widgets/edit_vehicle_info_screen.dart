import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EditVehicleInfoScreen extends StatefulWidget {
  final Map<String, dynamic> vehicleData;

  EditVehicleInfoScreen({required this.vehicleData});

  @override
  _EditVehicleInfoScreenState createState() => _EditVehicleInfoScreenState();
}

class _EditVehicleInfoScreenState extends State<EditVehicleInfoScreen> {
  final AuthService _authService = AuthService();

  late TextEditingController _modelController;
  late TextEditingController _licensePlateController;
  late TextEditingController _vinController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController(text: widget.vehicleData['model']);
    _licensePlateController = TextEditingController(text: widget.vehicleData['license_plate']);
    _vinController = TextEditingController(text: widget.vehicleData['vin']);
  }

  @override
  void dispose() {
    _modelController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSubmitting = true;
    });

    final updatedVehicleData = {
      'model': _modelController.text,
      'license_plate': _licensePlateController.text,
      'vin': _vinController.text,
    };

    try {
      // Update vehicle info using the new updateUserProfile method
      await _authService.updateUserProfile(vehicleInfo: updatedVehicleData);
      Navigator.pop(context, updatedVehicleData); // return updated data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle info updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update vehicle info: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Vehicle Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _modelController,
              decoration: InputDecoration(labelText: 'Vehicle Model'),
            ),
            TextField(
              controller: _licensePlateController,
              decoration: InputDecoration(labelText: 'License Plate'),
            ),
            TextField(
              controller: _vinController,
              decoration: InputDecoration(labelText: 'VIN'),
            ),
            Spacer(),
            _isSubmitting
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text('Save Changes'),
                  ),
          ],
        ),
      ),
    );
  }
}
