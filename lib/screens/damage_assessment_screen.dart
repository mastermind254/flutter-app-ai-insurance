import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/image_preview.dart';
import '../widgets/result_card.dart';

class DamageAssessmentScreen extends StatefulWidget {
  @override
  _DamageAssessmentScreenState createState() => _DamageAssessmentScreenState();
}

class _DamageAssessmentScreenState extends State<DamageAssessmentScreen> {
  File? _image;
  bool _loading = false;
  bool _showingResults = false;
  Map<String, dynamic>? _result;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    _processPickedImage(pickedFile);
  }

  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    _processPickedImage(pickedFile);
  }

  void _processPickedImage(XFile? pickedFile) async {
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _loading = true;
      _result = null;
      _showingResults = false;
    });

    try {
      final result = await _apiService.analyzeDamage(_image!);
      setState(() {
        _result = result;
        _loading = false;
        _showingResults = true;
      });
      
      // Scroll down to show results
      Future.delayed(Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _result = {
          'error': 'Error',
          'message': e.toString()
        };
        _showingResults = true;
      });
    }
  }

  void _resetAssessment() {
    setState(() {
      _image = null;
      _result = null;
      _loading = false;
      _showingResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6366F1),
        elevation: 0,
        title: Text(
          'Damage Assessment',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_showingResults || _image != null)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: _resetAssessment,
              tooltip: 'Reset Assessment',
            ),
        ],
      ),
      body: Container(
        color: Color(0xFFF6F7F9),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introduction and upload section
                AnimatedOpacity(
                  opacity: _showingResults ? 0.6 : 1.0,
                  duration: Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Car Photo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Take a clear photo of the damaged area or select from gallery.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 20),
                      ImagePreview(
                        image: _image,
                        onTap: _showingResults ? null : () => pickImageFromGallery(),
                      ),
                      SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Results section
                _buildResultSection(),
                
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // When results are showing, we minimize the buttons
    if (_showingResults) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildMiniButton(
              icon: Icons.photo_library,
              label: 'Gallery',
              onTap: pickImageFromGallery,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildMiniButton(
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: pickImageFromCamera,
            ),
          ),
        ],
      );
    }
    
    // Default buttons when no results are showing
    return Column(
      children: [
        _buildButton(
          icon: Icons.photo_library,
          label: 'Select from Gallery',
          onTap: pickImageFromGallery,
          primary: true,
        ),
        SizedBox(height: 12),
        _buildButton(
          icon: Icons.camera_alt,
          label: 'Take a Photo',
          onTap: pickImageFromCamera,
          primary: true,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool primary,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: primary ? Color(0xFF6366F1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primary ? Colors.transparent : Color(0xFF6366F1),
          ),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primary ? Colors.white : Color(0xFF6366F1),
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primary ? Colors.white : Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFF6366F1).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color(0xFF6366F1), size: 20),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    if (_loading) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
            SizedBox(height: 16),
            Text(
              'Analyzing your image...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    } else if (_result != null) {
      // Add a title before the results
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'Assessment Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Use ResultCard widget with the analysis results
          ResultCard(result: _result!),
        ],
      );
    }
    
    return Container();
  }
}