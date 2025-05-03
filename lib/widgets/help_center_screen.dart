import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text('FAQs'),
            subtitle: Text('Frequently Asked Questions'),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('FAQs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      ExpansionTile(
                        title: Text('What is this app about?'),
                        children: [Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('This app helps you manage your insurance policies efficiently.'),
                        )],
                      ),
                      ExpansionTile(
                        title: Text('How do I contact support?'),
                        children: [Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('You can contact support via the Contact Support option in the Help Center.'),
                        )],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Contact Support'),
            subtitle: Text('Call or email support team'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Contact Support'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.phone),
                          title: Text('Call Us'),
                          subtitle: Text('+1 234 567 890'),
                          onTap: () {
                            // Add functionality to call
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.email),
                          title: Text('Email Us'),
                          subtitle: Text('support@insureai.com'),
                          onTap: () {
                            // Add functionality to email
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Send Feedback'),
            subtitle: Text('Let us know what you think!'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Send Feedback'),
                    content: TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Write your feedback here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Add functionality to submit feedback
                          Navigator.of(context).pop();
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
