import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/edit_personal_info_screen.dart';
import '../widgets/edit_vehicle_info_screen.dart';
import '../widgets/help_center_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserProfile();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data: $e')),
      );
    }
  }

  Future<void> _handleLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      );

      await _authService.logout();
      Navigator.pop(context);
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    bool isEditable,
    VoidCallback? onEdit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            if (isEditable)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.white, size: 18),
                  onPressed: onEdit,
                  constraints: BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.all(9),
                ),
              ),
          ],
        ),
        Divider(height: 20),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: TextStyle(fontSize: 14, color: Colors.black54)
        ),
        SizedBox(height: 4),
        Text(
          value, 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
        ),
        SizedBox(height: 16),
        Divider(height: 1),
      ],
    );
  }

  Widget _buildPersonalInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Personal Information',
          'Manage your account details',
          true,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPersonalInfoScreen(userData: _userData),
              ),
            ).then((updatedData) {
              if (updatedData != null) {
                setState(() {
                  _userData = {..._userData, ...updatedData};
                });
              }
            });
          },
        ),
        _buildInfoItem('Username', _userData['username'] ?? 'Not available'),
        _buildInfoItem('Email', _userData['email'] ?? 'Not available'),
        _buildInfoItem(
          'Phone',
          _userData['phone'] ?? 'Not set - Please update your profile',
        ),
        _buildInfoItem(
          'Address',
          _userData['address'] ?? 'Not set - Please update your profile',
        ),
      ],
    );
  }

  Widget _buildVehicleInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Vehicle Information',
          'Your insured vehicle details',
          true,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditVehicleInfoScreen(
                  vehicleData: _userData['vehicle'] ?? {},
                ),
              ),
            ).then((_) => _loadUserData());
          },
        ),
        _buildInfoItem(
          'Vehicle',
          _userData['vehicle']?['model'] ?? 'Not available',
        ),
        _buildInfoItem(
          'License Plate',
          _userData['vehicle']?['license_plate'] ?? 'Not available',
        ),
        _buildInfoItem(
          'VIN',
          _userData['vehicle']?['vin'] ?? 'Not available',
        ),
      ],
    );
  }

  Widget _buildInsuranceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Insurance Details',
          'Your coverage information',
          false,
          null,
        ),
        _buildInfoItem(
          'Policy Type',
          _userData['insurance_detail']?['policy_type'] ?? 'Comprehensive Coverage',
        ),
        _buildInfoItem(
          'Policy Number',
          _userData['insurance_detail']?['policy_number'] ?? 'Not available',
        ),
        _buildInfoItem(
          'Renewal Date',
          _userData['insurance_detail']?['renewal_date'] ?? 'Not available',
        ),
        _buildInfoItem(
          'Monthly Premium',
          _userData['insurance_detail']?['monthly_premium'] ?? 'Not available',
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    return Container(
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.help_outline, color: Color(0xFF6366F1)),
        ),
        title: Text(
          'Customer Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Get help with your account or claims'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6366F1)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelpCenterScreen()),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _handleLogout,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        backgroundColor: Colors.red.shade700,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.logout),
          SizedBox(width: 8),
          Text(
            'Logout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7F9),
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: Color(0xFF6366F1),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: Color(0xFF6366F1),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header with gradient background
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userData['full_name'] ?? _userData['username'] ?? 'User',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Policy Number: ${_userData['insurance_detail']?['policy_number'] ?? 'Not Available'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Personal Info
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
                      child: _buildPersonalInformation(),
                    ),
                    SizedBox(height: 16),

                    // Vehicle Info
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
                      child: _buildVehicleInformation(),
                    ),
                    SizedBox(height: 16),

                    // Insurance Info
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
                      child: _buildInsuranceDetails(),
                    ),
                    SizedBox(height: 16),

                    // Help Center
                    _buildHelpSection(),
                    SizedBox(height: 16),

                    // Logout Button
                    _buildLogoutButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}