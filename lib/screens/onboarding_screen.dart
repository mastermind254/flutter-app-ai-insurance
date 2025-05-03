// screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'AI-Powered Claims',
      icon: Icons.camera_alt,
      description: 'Our advanced AI technology analyzes vehicle damage in real-time, providing accurate assessments within minutes.',
      iconColor: Colors.blue,
    ),
    OnboardingItem(
      title: 'Fast Processing',
      icon: Icons.grid_view,
      description: 'Submit claims quickly with our user-friendly interface and get instant feedback on damage assessment.',
      iconColor: Colors.blue,
    ),
    OnboardingItem(
      title: 'Smart Tracking',
      icon: Icons.list_alt,
      description: 'Track your claim status in real-time and get notifications at every step of the process.',
      iconColor: Colors.blue,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

 void _navigateToLogin() async {
  // Mark onboarding as complete
  await PreferencesService().setOnboardingComplete();
  
  // Navigate to login screen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => AuthScreen()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.blueGrey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _numPages,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingItems[index]);
                },
              ),
            ),
            // Bottom indicators and buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _numPages,
                      (index) => _buildPageIndicator(index == _currentPage),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Next or Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _numPages - 1) {
                          _navigateToLogin();
                        } else {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _numPages - 1 ? 'Get Started' : 'Next',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (_currentPage == _numPages - 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.check, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            'Welcome to AI Insurance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: item.iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 40,
              color: item.iconColor,
            ),
          ),
          SizedBox(height: 30),
          // Feature title
          Text(
            item.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // Description
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final IconData icon;
  final String description;
  final Color iconColor;

  OnboardingItem({
    required this.title,
    required this.icon,
    required this.description,
    required this.iconColor,
  });
}