import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClaimDetailScreen extends StatefulWidget {
  final String claimId;
  final String status;
  final String damageType;
  final DateTime submissionDate;
  final double estimatedCost;
  
  ClaimDetailScreen({
    required this.claimId,
    required this.status,
    required this.damageType,
    required this.submissionDate,
    required this.estimatedCost,
  });

  @override
  _ClaimDetailScreenState createState() => _ClaimDetailScreenState();
}

class _ClaimDetailScreenState extends State<ClaimDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TimelineStatus _currentStatus;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Determine current status based on claim status
    switch (widget.status) {
      case 'Under Review':
        _currentStatus = TimelineStatus.underReview;
        break;
      case 'Approved':
        _currentStatus = TimelineStatus.approved;
        break;
      case 'Rejected':
        _currentStatus = TimelineStatus.rejected;
        break;
      default:
        _currentStatus = TimelineStatus.submitted;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Under Review':
        return Color(0xFF7C3AED); // Purple
      case 'Approved':
        return Color(0xFF34D399); // Green
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Claim #${widget.claimId}'),
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Show options menu
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildOptionsMenu(),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs for switching between timeline and assessment
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: 'Claim Timeline'),
                Tab(text: 'AI Assessment'),
              ],
              onTap: (index) {
                setState(() {});
              },
            ),
            
            // Tab content
            Container(
              height: MediaQuery.of(context).size.height - 150, // Adjust based on screen size
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTimelineTab(),
                  _buildAssessmentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsMenu() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.contact_support_outlined),
            title: Text('Contact Adjuster'),
            onTap: () {
              Navigator.pop(context);
              // Implement contact adjuster functionality
            },
          ),
          ListTile(
            leading: Icon(Icons.add_photo_alternate_outlined),
            title: Text('Upload Additional Evidence'),
            onTap: () {
              Navigator.pop(context);
              // Implement upload functionality
            },
          ),
          if (widget.status == 'Rejected')
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Appeal Decision'),
              onTap: () {
                Navigator.pop(context);
                // Implement appeal functionality
              },
            ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Get Help'),
            onTap: () {
              Navigator.pop(context);
              // Implement help functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Status Card
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Current Status',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.track_changes, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Track Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Claim Timeline Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Claim Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View full timeline details
                },
                child: Text(
                  'View Details',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Timeline
          _buildTimeline(),
          
          SizedBox(height: 24),
          
          // AI Assessment Summary
          if (_currentStatus.index >= TimelineStatus.aiAssessment.index)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Damage Assessment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Damage Type:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            widget.damageType ?? 'Water Damage (Category 2)',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Estimated Repair Cost:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Ksh ${widget.estimatedCost.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssessmentTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Damage Assessment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildAssessmentInfoRow('Damage Type:', 'Collision'),
                _buildAssessmentInfoRow('Affected Areas:', 'front bumper, headlight, fender, hood'),
                _buildAssessmentInfoRow('Estimated Repair Cost:', 'Ksh 4,250', valueColor: Colors.blue),
                _buildAssessmentInfoRow('Confidence Level:', 'High (92%)'),
                
                SizedBox(height: 16),
                Text(
                  'AI Analysis Notes:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'The vehicle requires professional repair. The front bumper, headlight, fender, and possibly the hood need replacement.  An assessment for underlying structural damage is necessary.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Submitted Evidence
          Text(
            'Submitted Evidence',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 1, // Add more as needed
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 12),
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.grey),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssessmentInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final submissionDate = widget.submissionDate;
    final aiAssessmentDate = submissionDate.add(Duration(minutes: 2));
    final reviewStartDate = submissionDate.add(Duration(hours: 1));
    final estimatedApprovalDate = submissionDate.add(Duration(days: 7));
    
    return Column(
      children: [
        _buildTimelineItem(
          status: TimelineStatus.submitted,
          currentStatus: _currentStatus,
          title: 'Claim Submitted',
          date: submissionDate,
          description: 'Your claim for ${widget.damageType?.toLowerCase() ?? 'water damage'} has been received and assigned to an adjuster.',
          isFirst: true,
        ),
        _buildTimelineItem(
          status: TimelineStatus.aiAssessment,
          currentStatus: _currentStatus,
          title: 'AI Assessment Completed',
          date: aiAssessmentDate,
          description: 'Our AI has analyzed your photos and estimated the damage value at \$${widget.estimatedCost.toStringAsFixed(0)}.',
        ),
        _buildTimelineItem(
          status: TimelineStatus.underReview,
          currentStatus: _currentStatus,
          title: 'Under Review',
          date: reviewStartDate,
          description: 'Adjuster John Smith is reviewing your claim and AI assessment.',
        ),
        _buildTimelineItem(
          status: TimelineStatus.approvalPending,
          currentStatus: _currentStatus,
          title: 'Approval Pending',
          date: estimatedApprovalDate,
          description: 'Your claim is awaiting final approval.',
          isEstimated: true,
        ),
        _buildTimelineItem(
          status: TimelineStatus.paymentProcessing,
          currentStatus: _currentStatus,
          title: 'Payment Processing',
          description: '',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required TimelineStatus status,
    required TimelineStatus currentStatus,
    required String title,
    DateTime? date,
    required String description,
    bool isFirst = false,
    bool isLast = false,
    bool isEstimated = false,
  }) {
    final isCompleted = status.index < currentStatus.index;
    final isCurrent = status.index == currentStatus.index;
    final isPending = status.index > currentStatus.index;
    
    Color dotColor;
    Widget dotWidget;
    
    if (isCompleted) {
      dotColor = Colors.green;
      dotWidget = Icon(Icons.check, color: Colors.white, size: 12);
    } else if (isCurrent) {
      dotColor = Color(0xFF7C3AED); // Purple
      dotWidget = Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    } else {
      dotColor = Colors.grey.shade400;
      dotWidget = Container();
    }
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          Column(
            children: [
              // Top line
              if (!isFirst)
                Container(
                  width: 2,
                  height: 15,
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
                ),
                
              // Dot
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: dotWidget),
              ),
              
              // Bottom line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isPending || isCurrent ? Colors.grey.shade300 : Colors.green,
                  ),
                ),
            ],
          ),
          
          SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPending ? Colors.grey : Colors.black,
                      ),
                    ),
                    if (date != null)
                      Text(
                        '${isEstimated ? 'Estimated by ' : ''}${DateFormat('MMM d, yyyy').format(date)} at ${DateFormat('h:mm a').format(date)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isPending ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum TimelineStatus {
  submitted,
  aiAssessment,
  underReview,
  approvalPending,
  paymentProcessing,
  approved,
  rejected,
}