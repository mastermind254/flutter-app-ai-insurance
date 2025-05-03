// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'damage_assessment_screen.dart';
import 'claim_history_screen.dart';
import 'profile_screen.dart';
import 'submit_claim_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  // User profile data
  String userName = "User";
  String policyNumber = "Policy number loading...";
  String validUntil = "Loading...";
  String vehicleModel = "Loading...";
  bool _isLoading = true;

  // Key to maintain claim history state
  final GlobalKey<_HomeScreenState> _homeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserProfile();
      setState(() {
        userName = userData['username'] ?? "User";
        policyNumber = userData['insurance_detail']?['policy_number'] ?? "Unknown";
        validUntil = userData['insurance_detail']?['renewal_date'] ?? "Unknown";
        vehicleModel = userData['car_detail']?['vehicle'] ?? "Your vehicle";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  // Method to handle tab navigation from child screens
  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Row(
                children: [
                  Image.asset(
                    'images/logo.jpg',
                    height: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AutoAssess',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
        backgroundColor: Color(0xFF6366F1),
              elevation: 0,
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeScreen(),
          SubmitClaimScreen(
            onSubmissionComplete: () {
              // After submission, navigate to claims history
              setState(() {
                _currentIndex = 2; // Move to claims history tab
              });
            },
          ),
          ClaimHistoryScreen(
            onTabChange: _navigateToTab, // Pass the navigation callback
          ),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeScreen() {
    return SafeArea(
      child: Container(
        color: Color(0xFFF6F7F9), // Light gray background
        child: _isLoading 
          ? Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: Color(0xFF6366F1),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildActivePolicy(),
                    _buildQuickActionsSection(),
                    _buildRecentClaimsSection(),
                    SizedBox(height: 20), // Add space at the bottom
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Welcome back to your insurance portal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = 3; // Switch to profile tab
              });
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF6366F1),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePolicy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Policy',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    vehicleModel,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Policy Number: $policyNumber',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Valid until: $validUntil',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.camera_alt,
                  iconColor: Color(0xFF6366F1),
                  title: 'Submit Claim',
                  onTap: () {
                    setState(() {
                      _currentIndex = 1; // Switch to Submit Claim tab
                    });
                  },
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.history,
                  iconColor: Color(0xFF6366F1),
                  title: 'Claim History',
                  onTap: () {
                    setState(() {
                      _currentIndex = 2; // Switch to Claim History tab
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.assessment,
                  iconColor: Color(0xFF6366F1),
                  title: 'Damage Assessment',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DamageAssessmentScreen()),
                    );
                  },
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.person,
                  iconColor: Color(0xFF6366F1),
                  title: 'Profile',
                  onTap: () {
                    setState(() {
                      _currentIndex = 3; // Switch to Profile tab
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: iconColor,
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentClaimsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Claims',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 2; // Switch to Claims tab
                  });
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // You would populate this with actual claims data
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.document_scanner_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No recent claims',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your claim history will appear here',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home'),
              _buildNavItem(1, Icons.camera_alt, 'New Claim'),
              _buildNavItem(2, Icons.history, 'Claims'),
              _buildNavItem(3, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildNavItem(int index, IconData icon, String label) {
  final isSelected = _currentIndex == index;
  return InkWell(
    onTap: () {
      setState(() {
        _currentIndex = index;
      });
    },
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xFF6366F1) : Colors.grey,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFF6366F1) : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

}
