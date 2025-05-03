// services/api_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'auth_service.dart';

class ApiService {
  // Backend API endpoints
  final String _baseUrl = 'https://mutaihillary27.pythonanywhere.com/api';
  // final String _baseUrl = 'http://localhost:8000'; // Local development URL
  final String _submitClaimEndpoint = '/submit-claim/';
  final AuthService _authService = AuthService();

Future<Map<String, dynamic>> analyzeDamage1(File imageFile) async {
    // Create a multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://plpchatbot.pythonanywhere.com/api/assess-damage/'),
    );

    // Get file name and content type
    String fileName = imageFile.path.split('/').last;
    String fileExtension = fileName.split('.').last.toLowerCase();
    
    // Determine content type based on file extension
    String contentType;
    switch (fileExtension) {
      case 'jpg':
      case 'jpeg':
        contentType = 'image/jpeg';
        break;
      case 'png':
        contentType = 'image/png';
        break;
      default:
        contentType = 'application/octet-stream';
    }

    // Add the file to the request
    request.files.add(
      await http.MultipartFile.fromPath(
        'images',  // Field name matching the API parameter
        imageFile.path,
        contentType: MediaType.parse(contentType),
      ),
    );

    try {
      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print("response: ${response.body}");  
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the response
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Check if the status is successful
        if (jsonResponse['status'] == 'success' && 
            jsonResponse['results'] != null && 
            jsonResponse['results'].isNotEmpty) {
          
          // Extract the first result's assessment
          var result = jsonResponse['results'][0];
          return {
            'isVehicle': result['isVehicle'] ?? false,
            'severity': result['assessment']['severity'] ?? 'Unknown',
            'damaged_parts': result['assessment']['damaged_parts'] ?? [],
            'repair_advice': result['assessment']['repair_advice'] ?? 'No repair advice available.',
            'estimatedCost': result['assessment']['estimatedCost'] ?? 0.0,
            'fraudRisk': result['assessment']['fraudRisk'] ?? 'Unknown',
            'description': result['assessment']['description'] ?? 'No description available.',
          };
        } else {
          // Return error information if status is not success
          return {
            'error': jsonResponse['status'] == 'error' 
                ? jsonResponse['message'] ?? 'Unknown error' 
                : 'No valid results found',
          };
        }
      } else {
        // Handle HTTP error
        return {
          'error': 'Server error: ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      // Handle exceptions
      return {
        'error': 'Request failed',
        'message': e.toString(),
      };
    }
  }
  
  Future<Map<String, dynamic>> analyzeDamage(File imageFile) async {
    try {
      final uri = Uri.parse('https://plpchatbot.pythonanywhere.com/api/assess-damage/');
            
      // Create multipart request
      var request = http.MultipartRequest('POST', uri);
      
      // Add file to request
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      
      // Determine media type based on file extension
      final String extension = imageFile.path.split('.').last.toLowerCase();
      String mediaType = 'image/jpeg'; // Default
      
      if (extension == 'png') {
        mediaType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        mediaType = 'image/jpeg';
      }
      
      final multipartFile = http.MultipartFile(
        'images', // Field name that the API expects
        fileStream,
        fileLength,
        filename: 'image.$extension',
        contentType: MediaType.parse(mediaType),
      );
      
      request.files.add(multipartFile);
      
      // Send request
      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(responseString);
        
        // Process the API response to match what our ResultCard expects
        if (decodedResponse['status'] == 'success' && decodedResponse['results'].isNotEmpty) {
          final result = decodedResponse['results'][0];
          
          // Check if image contains a vehicle
          if (!(result['isVehicle'] ?? true)) {
            return {
              'isVehicle': false,
              'reason': result['reason'] ?? 'No vehicle detected in the image'
            };
          }
          
          // Check if assessment data is available
          final assessment = result['assessment'];
          if (assessment == null) {
            return {
              'error': 'Invalid Response',
              'message': 'Assessment data missing from response'
            };
          }
          
          // Return a formatted object that matches our ResultCard's expected structure
          return {
            'isVehicle': result['isVehicle'],
            'severity': assessment['severity'],
            'damaged_parts': assessment['damaged_parts'],
            'repair_advice': assessment['repair_advice'],
            'estimatedCost': assessment['estimatedCost'],
            'fraudRisk': assessment['fraudRisk'],
            
            'description': assessment['description'],
          };
        } else {
          return {
            'error': 'Processing Failed',
            'message': decodedResponse['message'] ?? 'The damage assessment could not be completed'
          };
        }
      } else {
        return {
          'error': 'API Request Failed',
          'message': 'Status code: ${response.statusCode}, Message: $responseString'
        };
      }
    } catch (e) {
      return {
        'error': 'Error',
        'message': 'Error analyzing damage: ${e.toString()}'
      };
    }
    
  }


  // Submit a complete claim with all details and images
Future<Map<String, dynamic>> submitClaim({
  required String incidentType,
  required DateTime incidentDate,
  required String incidentLocation,
  required String description,
  required List<File> images,
}) async {
  try {
    // Check if images list is empty
    if (images.isEmpty) {
      throw Exception('At least one image is required');
    }

    // Get the auth token
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    // Create multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl$_submitClaimEndpoint'),
    );
    
    // Add auth token header
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    
    // Add claim details as fields
    request.fields['incidentType'] = incidentType;
    request.fields['incidentDate'] = incidentDate.toIso8601String();
    request.fields['incidentLocation'] = incidentLocation;
    request.fields['description'] = description;
    
    // Add all images - use the field name 'images' for all files
    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      
      // Important: Make sure file exists and has content
      if (fileLength <= 0) {
        throw Exception('Image file $i is empty or invalid');
      }
      
      final multipartFile = http.MultipartFile(
        'images', // Use 'images' as the field name for all files
        fileStream,
        fileLength,
        filename: path.basename(file.path), // Use actual filename
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
      
      // Debug print
      print('Adding image $i, size: ${fileLength} bytes with name: ${path.basename(file.path)}');
    }
    
    // Debug print total files
    print('Sending ${request.files.length} files in request');
    
    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    // Process the response
    if (response.statusCode == 201) {
      // 201 Created
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception(
        'Failed to submit claim: ${response.statusCode} - ${response.body}',
      );
    }
  } catch (e) {
    if (e is SocketException) {
      throw Exception(
        'Network error. Please check your internet connection.',
      );
    } else {
      print('Error submitting claim: $e');
      rethrow;
    }
  }
}
  // Added a direct method to get mock analysis without requiring an image file
  Future<Map<String, dynamic>> getMockAnalysis() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    return _getMockResponse();
  }

  // Mock response for testing purposes - Updated to match ResultCard expectations
  Map<String, dynamic> _getMockResponse() {
    // Randomly determine if damage is detected
    final bool hasDamage = DateTime.now().millisecond % 3 != 0;

    if (hasDamage) {
      return {
        'damaged': true, // Changed from 'hasDamage' to 'damaged'
        'confidence': 0.92,
        'damageType': 'Collision',
        'severity': 'Moderate', // Added direct severity field
        'damageDetails': {
          'location': 'Front Bumper',
          'severity': 'Moderate',
          'affectedParts': 'Bumper, Hood, Left Headlight',
          'repairRecommendation':
              'Replace bumper, repair hood, replace headlight',
        },
        'estimatedCost': 1200.00,
        'estimatedCostHigh': 1500.00,
      };
    } else {
      return {
        'damaged': false, // Changed from 'hasDamage' to 'damaged'
        'confidence': 0.87,
        'damageType': 'None',
        'severity': 'None',
        'estimatedCost': 0,
        'estimatedCostHigh': 0,
        'message': 'No significant damage detected in the provided image.',
      };
    }
  }

  // Mock claim submission response for testing
  Map<String, dynamic> _getMockClaimSubmissionResponse() {
    // Generate a random claim ID
    final claimId = 'A-${78000 + DateTime.now().millisecond}';

    return {
      'success': true,
      'message': 'Claim submitted successfully',
      'claimId': claimId,
      'status': 'Under Review',
      'submissionDate': DateTime.now().toIso8601String(),
      'estimatedProcessingTime': '3-5 business days',
      'damageAnalysis': _getMockResponse(),
    };
  }
}
