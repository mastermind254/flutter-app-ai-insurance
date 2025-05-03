// // services/auth_service.dart
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AuthService {
//   // Base URL for API endpoints
//   final String _baseUrl = 'https://mutaihillary27.pythonanywhere.com/api';
  
//   // Keys for shared preferences
//   static const String _accessTokenKey = 'access_token';
//   static const String _refreshTokenKey = 'refresh_token';
//   static const String _userDataKey = 'user_data';
//   static const String _rememberMeKey = 'remember_me';
//   static const String _savedLoginKey = 'saved_login';
//   static const String _savedPasswordKey = 'saved_password';

//   // Login method with JWT authentication
//   Future<void> login(String login, String password, bool rememberMe) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/token/'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'login': login, // Use the custom 'login' field for either email or username
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body) as Map<String, dynamic>;
        
//         // Store JWT tokens in shared preferences
//         await _saveTokens(responseData['access'], responseData['refresh']);
//         await _saveRememberMe(rememberMe);

//         print("RD: $responseData");
        
//         // Save credentials if remember me is checked
//         if (rememberMe) {
//           await _saveUserCredentials(login, password);
//         }
        
//         // Fetch user data with the new token
//         await _fetchAndStoreUserData();
        
//         if (kDebugMode) {
//           print('User logged in: $login');
//         }
//       } else {
//         final errorData = json.decode(response.body);
//         throw Exception(errorData['detail'] ?? 'Login failed');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Login error: $e');
//       }
//       rethrow;
//     }
//   }

//   // Register method with API call
//   Future<void> register(String email, String username, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/register/'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'email': email,
//           'username': username,
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 201) {
//         // After registration, login automatically
//         await login(email, password, false);
        
//         if (kDebugMode) {
//           print('User registered: $email');
//         }
//       } else {
//         final errorData = json.decode(response.body);
//         // Parse and format error messages
//         String errorMsg = _parseErrorResponse(errorData);
//         throw Exception(errorMsg);
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Registration error: $e');
//       }
//       rethrow;
//     }
//   }

//   // Store tokens in shared preferences
//   Future<void> _saveTokens(String accessToken, String refreshToken) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_accessTokenKey, accessToken);
//     await prefs.setString(_refreshTokenKey, refreshToken);
//   }
  
//   // Save remember me preference
//   Future<void> _saveRememberMe(bool rememberMe) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_rememberMeKey, rememberMe);
//   }
  
//   // Save user credentials for remember me
//   Future<void> _saveUserCredentials(String login, String password) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_savedLoginKey, login);
//     // Note: Storing passwords in SharedPreferences is not secure
//     // In production, consider more secure options like Flutter Secure Storage
//     await prefs.setString(_savedPasswordKey, password);
//   }
  
//   // Get saved credentials for auto-login
//   Future<Map<String, String?>> getSavedCredentials() async {
//     final prefs = await SharedPreferences.getInstance();
//     final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    
//     if (rememberMe) {
//       final login = prefs.getString(_savedLoginKey);
//       final password = prefs.getString(_savedPasswordKey);
//       return {
//         'login': login,
//         'password': password,
//       };
//     }
    
//     return {
//       'login': null,
//       'password': null,
//     };
//   }

//   // Helper method to fetch and store user data
//   Future<void> _fetchAndStoreUserData() async {
//     try {
//       final token = await getAccessToken();
//       if (token == null) {
//         throw Exception('Not authenticated');
//       }
      
//       final response = await http.get(
//         Uri.parse('$_baseUrl/user/profile/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final userData = json.decode(response.body);
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(_userDataKey, json.encode(userData));
//       } else {
//         throw Exception('Failed to fetch user data');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Fetch user data error: $e');
//       }
//       // Don't rethrow as this is an auxiliary operation
//     }
//   }

//   // Get user profile data
//   Future<Map<String, dynamic>> getUserProfile() async {
//     try {
//       final token = await getAccessToken();
//       if (token == null) {
//         throw Exception('Not authenticated');
//       }
      
//       // First try to get data from local storage
//       final prefs = await SharedPreferences.getInstance();
//       final storedUserDataJson = prefs.getString(_userDataKey);
      
//       if (storedUserDataJson != null) {
//         final userData = json.decode(storedUserDataJson) as Map<String, dynamic>;
//         return userData;
//       }
      
//       // If not in storage, fetch from API
//       final response = await http.get(
//         Uri.parse('$_baseUrl/user/profile/'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final userData = json.decode(response.body);
//         // Store for future use
//         await prefs.setString(_userDataKey, json.encode(userData));
//         return userData;
//       } else {
//         throw Exception('Failed to get user profile');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Get user profile error: $e');
//       }
//       rethrow;
//     }
//   }

//   // Update user profile for specific section
//   Future<Map<String, dynamic>> updateUserProfile({
//     Map<String, dynamic>? personalInfo,
//     Map<String, dynamic>? vehicleInfo,
//   }) async {
//     try {
//       final token = await getAccessToken();
//       if (token == null) {
//         throw Exception('Not authenticated. Please login again.');
//       }
      
//       // Get current user data
//       Map<String, dynamic> currentData = await getUserProfile();
      
//       // Prepare data for update
//       Map<String, dynamic> updateData = {};
      
//       // Update personal info if provided
//       if (personalInfo != null) {
//         updateData.addAll({
//           'email': personalInfo['email'] ?? currentData['email'],
//           'phone': personalInfo['phone'] ?? currentData['phone'],
//           'address': personalInfo['address'] ?? currentData['address'],
//           'full_name': personalInfo['full_name'] ?? currentData['full_name'],
//         });
//       }
      
//       // Update vehicle info if provided
//       if (vehicleInfo != null) {
//         updateData['vehicle'] = {
//           'model': vehicleInfo['model'] ?? currentData['vehicle']?['model'],
//           'license_plate': vehicleInfo['license_plate'] ?? currentData['vehicle']?['license_plate'],
//           'vin': vehicleInfo['vin'] ?? currentData['vehicle']?['vin'],
//         };
//       }
      
//       final response = await http.patch(
//         Uri.parse('$_baseUrl/user/profile/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode(updateData),
//       );

//       if (response.statusCode == 200) {
//         final updatedData = json.decode(response.body);
        
//         // Update stored user data
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(_userDataKey, json.encode(updatedData));
        
//         if (kDebugMode) {
//           print('Profile updated successfully');
//         }
        
//         return updatedData;
//       } else {
//         final errorData = json.decode(response.body);
//         String errorMsg = _parseErrorResponse(errorData);
//         throw Exception(errorMsg);
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Update profile error: $e');
//       }
//       rethrow;
//     }
//   }

//   // Get user data from local storage
//   Future<Map<String, dynamic>> getUserData() async {
//     return await getUserProfile();
//   }

//   // Logout - clear tokens and optionally call API
//   Future<void> logout() async {
//     try {
//       final token = await getAccessToken();
//       if (token != null) {
//         // Call logout endpoint to invalidate token on server
//         try {
//           await http.post(
//             Uri.parse('$_baseUrl/logout/'),
//             headers: {
//               'Authorization': 'Bearer $token',
//             },
//           );
//         } catch (e) {
//           // Continue with local logout even if API call fails
//           if (kDebugMode) {
//             print('Logout API error: $e');
//           }
//         }
//       }
      
//       // Clear tokens and user data
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_accessTokenKey);
//       await prefs.remove(_refreshTokenKey);
//       await prefs.remove(_userDataKey);
      
//       // Retain remember me setting and saved credentials if needed
//       // Uncomment if you want to clear saved credentials on logout:
//       // await prefs.remove(_savedLoginKey);
//       // await prefs.remove(_savedPasswordKey);
      
//       if (kDebugMode) {
//         print('User logged out');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Logout error: $e');
//       }
//       rethrow;
//     }
//   }

//   // Check if user is logged in by verifying token
//   Future<bool> isLoggedIn() async {
//     try {
//       final token = await getAccessToken();
//       if (token == null) {
//         return false;
//       }
      
//       // Check if token works by calling a protected endpoint
//       // Or use token validation endpoint if available
//       try {
//         final response = await http.get(
//           Uri.parse('$_baseUrl/token/verify/'),
//           headers: {
//             'Authorization': 'Bearer $token',
//           },
//         );
        
//         return response.statusCode == 200;
//       } catch (e) {
//         // Try refresh token if access token is invalid
//         return await _refreshToken();
//       }
//     } catch (e) {
//       return false;
//     }
//   }

//   // Refresh the access token using refresh token
//   Future<bool> _refreshToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final refreshToken = prefs.getString(_refreshTokenKey);
      
//       if (refreshToken == null) {
//         return false;
//       }
      
//       final response = await http.post(
//         Uri.parse('$_baseUrl/token/refresh/'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'refresh': refreshToken,
//         }),
//       );
      
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         await prefs.setString(_accessTokenKey, responseData['access']);
//         return true;
//       }
      
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Get access token for API calls
//   Future<String?> getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_accessTokenKey);
//   }
  
//   // Helper method to parse error responses from the API
//   String _parseErrorResponse(dynamic errorData) {
//     if (errorData is Map) {
//       String errorMsg = '';
//       errorData.forEach((key, value) {
//         if (value is List && value.isNotEmpty) {
//           errorMsg += '$key: ${value.join(', ')}\n';
//         } else {
//           errorMsg += '$key: $value\n';
//         }
//       });
//       return errorMsg.trim();
//     } else if (errorData is String) {
//       return errorData;
//     } else {
//       return 'An error occurred';
//     }
//   }
// }

/*!SECTION
{
    "data": {
        "username": "brian",
        "email": "mutaihillary279@gmail.com",
        "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc0NTY3ODI2NywiaWF0IjoxNzQ1NTkxODY3LCJqdGkiOiIyODVmYWY1YjZjNjY0ODFkYmQxMGJmMThiZjcwZDIyMCIsInVzZXJfaWQiOjR9.XNCISVHHm92iFNt1C7shhsWfmYfn0sGeLdoHO_AHbNs",
        "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzQ1NTk1NDY3LCJpYXQiOjE3NDU1OTE4NjcsImp0aSI6ImIxZjAzMzczMWUyMjQ5YWM5NGVlODdjNDNlZWVlNzUyIiwidXNlcl9pZCI6NH0.ORFECuR2fXza_DsSTajqXeBf8ZZmBdZTfRB6kZhou6A"
    }
}

*/




// // services/auth_service.dart
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class AuthService {
//   // We'll use shared preferences to store user data for this example
//   // In a real app, you would use more secure storage and a proper backend

//   // Keys for shared preferences
//   static const String _userDataKey = 'user_data';
//   static const String _tokenKey = 'auth_token';
//   static const String _rememberMeKey = 'remember_me';

//   // In a real app, this would call an API endpoint
//   Future<void> login(String email, String password, bool rememberMe) async {
//     try {
//       // Simulate API call delay
//       await Future.delayed(Duration(seconds: 1));
      
//       // In a real app, you would validate credentials against a backend
//       // For this example, we'll just check if the user exists in local storage
//       final prefs = await SharedPreferences.getInstance();
//       final storedUserDataJson = prefs.getString(_userDataKey);
      
//       if (storedUserDataJson == null) {
//         throw Exception('User not found. Please register first.');
//       }
      
//       final userData = json.decode(storedUserDataJson) as Map<String, dynamic>;
      
//       if (userData['email'] != email) {
//         throw Exception('User not found with this email.');
//       }
      
//       if (userData['password'] != password) {
//         throw Exception('Incorrect password.');
//       }
      
//       // Generate a mock token (in a real app, this would come from your server)
//       final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      
//       // Store token and remember me preference
//       await prefs.setString(_tokenKey, token);
//       await prefs.setBool(_rememberMeKey, rememberMe);
      
//       if (kDebugMode) {
//         print('User logged in: $email');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Login error: $e');
//       }
//       rethrow;
//     }
//   }

//   Future<void> register(String email, String username, String password) async {
//     try {
//       // Simulate API call delay
//       await Future.delayed(Duration(seconds: 1));
      
//       // Check if user already exists
//       final prefs = await SharedPreferences.getInstance();
//       final storedUserDataJson = prefs.getString(_userDataKey);
      
//       if (storedUserDataJson != null) {
//         final userData = json.decode(storedUserDataJson) as Map<String, dynamic>;
//         if (userData['email'] == email) {
//           throw Exception('User with this email already exists.');
//         }
//       }
      
//       // Store user data
//       final userData = {
//         'email': email,
//         'username': username,
//         'password': password, // In a real app, NEVER store plain text passwords
//         'createdAt': DateTime.now().toIso8601String(),
//       };
      
//       await prefs.setString(_userDataKey, json.encode(userData));
      
//       // Auto-login after registration
//       await login(email, password, false);
      
//       if (kDebugMode) {
//         print('User registered: $email');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Registration error: $e');
//       }
//       rethrow;
//     }
//   }

//   Future<void> updateProfile(
//     String email,
//     String username,
//     String currentPassword,
//     String? newPassword,
//   ) async {
//     try {
//       // Simulate API call delay
//       await Future.delayed(Duration(seconds: 1));
      
//       final prefs = await SharedPreferences.getInstance();
//       final storedUserDataJson = prefs.getString(_userDataKey);
      
//       if (storedUserDataJson == null) {
//         throw Exception('User data not found. Please login again.');
//       }
      
//       final userData = json.decode(storedUserDataJson) as Map<String, dynamic>;
      
//       // Verify current password if attempting to change password or email
//       if (newPassword != null || email != userData['email']) {
//         if (currentPassword != userData['password']) {
//           throw Exception('Current password is incorrect.');
//         }
//       }
      
//       // Update user data
//       userData['email'] = email;
//       userData['username'] = username;
//       if (newPassword != null && newPassword.isNotEmpty) {
//         userData['password'] = newPassword;
//       }
//       userData['updatedAt'] = DateTime.now().toIso8601String();
      
//       await prefs.setString(_userDataKey, json.encode(userData));
      
//       if (kDebugMode) {
//         print('Profile updated for: $email');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Update profile error: $e');
//       }
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>> getUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final storedUserDataJson = prefs.getString(_userDataKey);
      
//       if (storedUserDataJson == null) {
//         throw Exception('User data not found. Please login again.');
//       }
      
//       return json.decode(storedUserDataJson) as Map<String, dynamic>;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Get user data error: $e');
//       }
//       rethrow;
//     }
//   }

//   Future<void> logout() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
      
//       // Clear auth token
//       await prefs.remove(_tokenKey);
      
//       // Clear user data if remember me is not enabled
//       if (!rememberMe) {
//         await prefs.remove(_userDataKey);
//         await prefs.remove(_rememberMeKey);
//       }
      
//       if (kDebugMode) {
//         print('User logged out');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Logout error: $e');
//       }
//       rethrow;
//     }
//   }

//   Future<bool> isLoggedIn() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(_tokenKey);
//       return token != null;
//     } catch (e) {
//       return false;
//     }
//   }
// }



// services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Base URL for API endpoints
  final String _baseUrl = 'https://mutaihillary27.pythonanywhere.com/api';
  
  // Secure storage instance
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Keys for secure storage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _savedLoginKey = 'saved_login';
  static const String _savedPasswordKey = 'saved_password';
  
  // Keys for shared preferences (non-sensitive data)
  static const String _userDataKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';

  // Login method with JWT authentication
  Future<void> login(String login, String password, bool rememberMe) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login': login, // Use the custom 'login' field for either email or username
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        
        // Store JWT tokens in secure storage
        await _saveTokens(responseData['access'], responseData['refresh']);
        await _saveRememberMe(rememberMe);
                
        // Save credentials if remember me is checked
        if (rememberMe) {
          await _saveUserCredentials(login, password);
        } else {
          // Clear saved credentials if remember me is unchecked
          await _clearUserCredentials();
        }
        
        // Fetch user data with the new token
        await _fetchAndStoreUserData();
        
        if (kDebugMode) {
          print('User logged in: $login');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Login failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      rethrow;
    }
  }

  // Register method with API call
  Future<void> register(String email, String username, String password, String fullName, String phone, String address) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'username': username,
          'password': password,
          "full_name": fullName,
          "phone": phone,
          "address": address
        }),
      );

      if (response.statusCode == 201) {
        // After registration, login automatically
        await login(email, password, false);
        
        if (kDebugMode) {
          print('User registered: $email');
        }
      } else {
        final errorData = json.decode(response.body);
        // Parse and format error messages
        String errorMsg = _parseErrorResponse(errorData);
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }
      rethrow;
    }
  }

  // Store tokens in secure storage
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  // Save remember me preference in shared preferences (not sensitive)
  Future<void> _saveRememberMe(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
  }
  
  // Save user credentials for remember me in secure storage
  Future<void> _saveUserCredentials(String login, String password) async {
    await _secureStorage.write(key: _savedLoginKey, value: login);
    await _secureStorage.write(key: _savedPasswordKey, value: password);
  }
  
  // Clear saved credentials
  Future<void> _clearUserCredentials() async {
    await _secureStorage.delete(key: _savedLoginKey);
    await _secureStorage.delete(key: _savedPasswordKey);
  }
  
  // Get saved credentials for auto-login
  Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    
    if (rememberMe) {
      final login = await _secureStorage.read(key: _savedLoginKey);
      final password = await _secureStorage.read(key: _savedPasswordKey);
      return {
        'login': login,
        'password': password,
      };
    }
    
    return {
      'login': null,
      'password': null,
    };
  }

  // Helper method to fetch and store user data
  Future<void> _fetchAndStoreUserData() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/user/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, json.encode(userData));
      } else if (response.statusCode == 401) {
        // Token might be expired, try refreshing
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry with new token
          await _fetchAndStoreUserData();
        } else {
          throw Exception('Authentication failed');
        }
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Fetch user data error: $e');
      }
      // Don't rethrow as this is an auxiliary operation
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      // First try to get data from local storage
      final prefs = await SharedPreferences.getInstance();
      final storedUserDataJson = prefs.getString(_userDataKey);
      
      if (storedUserDataJson != null) {
        final userData = json.decode(storedUserDataJson) as Map<String, dynamic>;
        return userData;
      }
      print("token $token");
      
      // If not in storage, fetch from API
      final response = await http.get(
        Uri.parse('$_baseUrl/user/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        // Store for future use
        await prefs.setString(_userDataKey, json.encode(userData));
        return userData;
      } else if (response.statusCode == 401) {
        // Token might be expired, try refreshing
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry with new token
          return await getUserProfile();
        } else {
          throw Exception('Authentication failed. Please login again.');
        }
      } else {
        throw Exception('Failed to get user profile');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get user profile error: $e');
      }
      rethrow;
    }
  }

  // Update user profile for specific section
  Future<Map<String, dynamic>> updateUserProfile({
    Map<String, dynamic>? personalInfo,
    Map<String, dynamic>? vehicleInfo,
  }) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated. Please login again.');
      }
      
      // Get current user data
      Map<String, dynamic> currentData = await getUserProfile();
      
      // Prepare data for update
      Map<String, dynamic> updateData = {};
      
      // Update personal info if provided
      if (personalInfo != null) {
        updateData.addAll({
          'email': personalInfo['email'] ?? currentData['email'],
          'phone': personalInfo['phone'] ?? currentData['phone'],
          'address': personalInfo['address'] ?? currentData['address'],
          'full_name': personalInfo['full_name'] ?? currentData['full_name'],
        });
      }
      
      // Update vehicle info if provided
      if (vehicleInfo != null) {
        updateData['vehicle'] = {
          'model': vehicleInfo['model'] ?? currentData['vehicle']?['model'],
          'license_plate': vehicleInfo['license_plate'] ?? currentData['vehicle']?['license_plate'],
          'vin': vehicleInfo['vin'] ?? currentData['vehicle']?['vin'],
        };
      }
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/user/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body);
        
        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, json.encode(updatedData));
        
        if (kDebugMode) {
          print('Profile updated successfully');
        }
        
        return updatedData;
      } else if (response.statusCode == 401) {
        // Token might be expired, try refreshing
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry with new token
          return await updateUserProfile(
            personalInfo: personalInfo,
            vehicleInfo: vehicleInfo,
          );
        } else {
          throw Exception('Authentication failed. Please login again.');
        }
      } else {
        final errorData = json.decode(response.body);
        String errorMsg = _parseErrorResponse(errorData);
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      rethrow;
    }
  }

  // Get user data from local storage
  Future<Map<String, dynamic>> getUserData() async {
    return await getUserProfile();
  }

  Future<void> logout() async {
  try {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();  // <-- retrieve refresh token too

    if (accessToken != null && refreshToken != null) {
      // Call logout endpoint to invalidate token on server
      try {
        await http.post(
          Uri.parse('$_baseUrl/logout/'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'refresh': refreshToken}), // <-- send refresh token in body
        );
      } catch (e) {
        // Continue with local logout even if API call fails
        if (kDebugMode) {
          print('Logout API error: $e');
        }
      }
    }

    // Clear tokens from secure storage
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);

    // Clear user data from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);

    if (kDebugMode) {
      print('User logged out');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Logout error: $e');
    }
    rethrow;
  }
}


  // Check if user is logged in by verifying token
  Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        return false;
      }
      
      // Check if token works by calling a protected endpoint
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/token/verify/'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        
        return response.statusCode == 200;
      } catch (e) {
        // Try refresh token if access token is invalid
        return await _refreshToken();
      }
    } catch (e) {
      return false;
    }
  }

  // Refresh the access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      
      if (refreshToken == null) {
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'refresh': refreshToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await _secureStorage.write(key: _accessTokenKey, value: responseData['access']);
        
        // Some refresh token implementations also return a new refresh token
        if (responseData.containsKey('refresh')) {
          await _secureStorage.write(key: _refreshTokenKey, value: responseData['refresh']);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh error: $e');
      }
      return false;
    }
  }

  // Get access token for API calls
  Future<String?> getAccessToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    
    // If token doesn't exist, return null
    if (token == null) {
      return null;
    }
    
    // Here we could implement JWT token expiry checking by decoding the token
    // and checking the expiry time, but we'll rely on server-side validation
    // and handle 401 responses appropriately in each method
    
    return token;
  }
  
  // Get access token for API calls
  Future<String?> getRefreshToken() async {
    final token = await _secureStorage.read(key: _refreshTokenKey);
    
    // If token doesn't exist, return null
    if (token == null) {
      return null;
    }
    
    // Here we could implement JWT token expiry checking by decoding the token
    // and checking the expiry time, but we'll rely on server-side validation
    // and handle 401 responses appropriately in each method
    
    return token;
  }
  
  // Helper method to parse error responses from the API
  String _parseErrorResponse(dynamic errorData) {
    if (errorData is Map) {
      String errorMsg = '';
      errorData.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          errorMsg += '$key: ${value.join(', ')}\n';
        } else {
          errorMsg += '$key: $value\n';
        }
      });
      return errorMsg.trim();
    } else if (errorData is String) {
      return errorData;
    } else {
      return 'An error occurred';
    }
  }
}



