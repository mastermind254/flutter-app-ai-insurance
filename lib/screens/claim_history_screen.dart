import 'package:flutter/material.dart';
import 'claim_detail_screen.dart';
import 'package:intl/intl.dart';
import 'submit_claim_screen.dart';

class Claim {
  final String id;
  final String status;
  final String vehicle;
  final DateTime date;
  final String severity;
  final double estimatedCost;
  final String fraudRisk;

  Claim({
    required this.id,
    required this.status,
    required this.vehicle,
    required this.date,
    required this.severity,
    required this.estimatedCost,
    required this.fraudRisk,
  });
}

class ClaimHistoryScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const ClaimHistoryScreen({Key? key, this.onTabChange}) : super(key: key);

  @override
  _ClaimHistoryScreenState createState() => _ClaimHistoryScreenState();
}

class _ClaimHistoryScreenState extends State<ClaimHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _statusFilter = 'All Statuses';
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data to match screenshot
  final List<Claim> _allClaims = [
    Claim(
      id: 'C1156',
      status: 'Under Review',
      vehicle: '2020 Toyota Camry',
      date: DateTime(2023, 3, 15),
      severity: 'Moderate',
      estimatedCost: 2800.00,
      fraudRisk: 'Low Risk',
    ),
    Claim(
      id: 'C1032',
      status: 'Approved',
      vehicle: '2019 Honda Civic',
      date: DateTime(2023, 2, 10),
      severity: 'Minor',
      estimatedCost: 1500.00,
      fraudRisk: 'Low Risk',
    ),
    Claim(
      id: 'C1031',
      status: 'Rejected',
      vehicle: '2011 Honda Civic',
      date: DateTime(2021, 2, 10),
      severity: 'Severe',
      estimatedCost: 2000.00,
      fraudRisk: 'Low Risk',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Claim> get filteredClaims {
    return _allClaims.where((claim) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          claim.vehicle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          claim.id.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Apply status filter
      final matchesStatus = _statusFilter == 'All Statuses' ||
          (_statusFilter == 'Active' && claim.status == 'Under Review') ||
          (_statusFilter == 'Approved' && claim.status == 'Approved') ||
          (_statusFilter == 'Rejected' && claim.status == 'Rejected');
      
      // Apply tab filter
      final currentTab = _tabController.index;
      final matchesTab = currentTab == 0 || // All Claims tab
          (currentTab == 1 && claim.status == 'Under Review') || // Active tab
          (currentTab == 2 && claim.status == 'Approved') || // Approved tab
          (currentTab == 3 && claim.status == 'Rejected'); // Rejected tab
      
      return matchesSearch && matchesStatus && matchesTab;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Under Review':
        return Color(0xFFF7BA57);
      case 'Approved':
        return Color(0xFF34D399);
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildClaimCard(Claim claim) {
    final statusColor = _getStatusColor(claim.status);
    final borderColor = claim.status == 'Under Review' 
        ? Colors.blue 
        : claim.status == 'Approved' 
            ? Colors.green 
            : Colors.red;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        claim.id,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            claim.status == 'Under Review' 
                                ? Icons.access_time 
                                : claim.status == 'Approved' 
                                    ? Icons.check_circle_outline 
                                    : Icons.cancel_outlined,
                            size: 16,
                            color: statusColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            claim.status,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  claim.vehicle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      DateFormat('M/d/yyyy').format(claim.date),
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Severity',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          claim.severity,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Est. Cost',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Ksh${claim.estimatedCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fraud Assessment',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF34D399).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        claim.fraudRisk,
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // Navigate to claim details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClaimDetailScreen(
                    claimId: claim.id,
                    status: claim.status,
                    damageType: claim.severity == 'Moderate' ? 'Water Damage' : claim.severity + ' Damage',
                    submissionDate: claim.date,
                    estimatedCost: claim.estimatedCost,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6366F1),
        title: Text('History', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'View and manage all your claims',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 3,
                        ),
                        insets: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'All Claims'),
                        Tab(text: 'Active'),
                        Tab(text: 'Approved'),
                        Tab(text: 'Rejected'),
                      ],
                      onTap: (_) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search claims...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter,
                      icon: Icon(Icons.filter_list),
                      items: <String>[
                        'All Statuses',
                        'Active',
                        'Approved',
                        'Rejected',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _statusFilter = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredClaims.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No claims found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredClaims.length,
                    itemBuilder: (context, index) {
                      return _buildClaimCard(filteredClaims[index]);
                    },
                  ),
          ),
          SizedBox(height: 24),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to SubmitClaimScreen when FAB is pressed
          if (widget.onTabChange != null) {
            // If within HomeScreen's tab structure, use the callback
            widget.onTabChange!(1); // Index 1 is for the Submit Claim tab
          } else {
            // Otherwise, navigate using push
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmitClaimScreen(
                  onSubmissionComplete: () {
                    // Refresh the claims list when returning from submission
                    setState(() {});
                  },
                ),
              ),
            );
          }
        },
        backgroundColor: Color(0xFF3366FF),
        icon: Icon(Icons.add),
        label: Text('File New Claim', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}