// widgets/result_card.dart
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultCard({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if there's an error in the result
    if (result.containsKey('error')) {
      return _buildErrorCard(result['error'], result['message'] ?? 'No additional details available');
    }

    // Check if the image contains a vehicle
    if (!(result['isVehicle'] ?? true)) {
      return _buildNonVehicleCard();
    }

    // Get the severity level and assign color
    String severity = result['severity'] ?? 'Unknown';
    Color severityColor = _getSeverityColor(severity);
    
    // Get the fraud risk and assign color
    String fraudRisk = result['fraudRisk'] ?? 'Unknown';
    Color fraudRiskColor = _getFraudRiskColor(fraudRisk);

    List<dynamic> damagedParts = result['damaged_parts'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Severity and Cost Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Damage Severity',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            severity,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Cost',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '\$${(result['estimatedCost'] ?? 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fraud Risk',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: fraudRiskColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            fraudRisk,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: fraudRiskColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Damaged Parts Section
        if (damagedParts.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Damaged Parts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    damagedParts.length,
                    (index) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        damagedParts[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        SizedBox(height: 16),
        
        // Description Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Damage Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                result['description'] ?? 'No description available.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Repair Advice Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Repair Advice',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                result['repair_advice'] ?? 'No repair advice available.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24),
        
        // Action Buttons Row
        Row(
          children: [
            // Save PDF Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _generateAndSavePdf(context),
                icon: Icon(Icons.save_alt),
                label: Text('Save PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(width: 10),
            // Share Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _generateAndSharePdf(context),
                icon: Icon(Icons.share),
                label: Text('Share Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Generate PDF document
  Future<File> _generatePdf() async {
    final pdf = pw.Document();
    
    // Format date for filename and report
    final now = DateTime.now();
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');
    final dateFormatFilename = DateFormat('yyyyMMdd_HHmmss');
    final formattedDate = dateFormat.format(now);
    
    // Get data from result map
    final severity = result['severity'] ?? 'Unknown';
    final estimatedCost = '\$${(result['estimatedCost'] ?? 0).toStringAsFixed(2)}';
    final fraudRisk = result['fraudRisk'] ?? 'Unknown';
    final damagedParts = (result['damaged_parts'] as List<dynamic>?) ?? [];
    final description = result['description'] ?? 'No description available.';
    final repairAdvice = result['repair_advice'] ?? 'No repair advice available.';

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Vehicle Damage Assessment Report',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on $formattedDate',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Main Info Section
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Row 1: Severity and Cost
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Damage Severity',
                                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                              pw.SizedBox(height: 4),
                              pw.Container(
                                padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: pw.BoxDecoration(
                                  color: _getSeverityPdfColor(severity),
                                  borderRadius: pw.BorderRadius.circular(12),
                                ),
                                child: pw.Text(severity,
                                    style: pw.TextStyle(fontSize: 14, color: PdfColors.white)),
                              ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Estimated Cost',
                                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                              pw.SizedBox(height: 4),
                              pw.Text(estimatedCost,
                                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    pw.SizedBox(height: 12),
                    
                    // Row 2: Fraud Risk
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Fraud Risk',
                                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                              pw.SizedBox(height: 4),
                              pw.Container(
                                padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: pw.BoxDecoration(
                                  color: _getFraudRiskPdfColor(fraudRisk),
                                  borderRadius: pw.BorderRadius.circular(12),
                                ),
                                child: pw.Text(fraudRisk,
                                    style: pw.TextStyle(fontSize: 14, color: PdfColors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 16),
              
              // Damaged Parts Section
              if (damagedParts.isNotEmpty) ...[
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Damaged Parts',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: List.generate(
                          damagedParts.length,
                          (index) => pw.Container(
                            padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.indigo50,
                              border: pw.Border.all(color: PdfColors.indigo200),
                              borderRadius: pw.BorderRadius.circular(12),
                            ),
                            child: pw.Text(
                              damagedParts[index],
                              style: pw.TextStyle(fontSize: 10, color: PdfColors.indigo700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
              ],
              
              // Description Section
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Damage Description',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text(description,
                        style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 16),
              
              // Repair Advice Section
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Repair Advice',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text(repairAdvice,
                        style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Footer
              pw.Center(
                child: pw.Text(
                  'This report was generated automatically and may need professional verification.',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF
    final output = await getTemporaryDirectory();
    final fileName = 'damage_report_${dateFormatFilename.format(now)}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Save PDF to device
  Future<void> _generateAndSavePdf(BuildContext context) async {
    try {
      // Show loading indicator
      _showLoadingDialog(context, 'Generating PDF...');
      
      // Generate the PDF
      final file = await _generatePdf();
      
      // Get the documents directory for saving
      final directory = await getApplicationDocumentsDirectory();
      final fileName = file.path.split('/').last;
      final savedFile = await File(file.path).copy('${directory.path}/$fileName');
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message with path
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved to Documents folder'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Generate and share PDF
  Future<void> _generateAndSharePdf(BuildContext context) async {
    try {
      // Show loading indicator
      _showLoadingDialog(context, 'Preparing report for sharing...');
      
      // Generate the PDF
      final file = await _generatePdf();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Vehicle Damage Assessment Report',
      );
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show loading dialog
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(String title, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Could trigger a retry or some other action
            },
            child: Text(
              'Try Again',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNonVehicleCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.no_crash,
            color: Colors.amber,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'No Vehicle Detected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The uploaded image does not appear to contain a vehicle. Please upload a clear image of the damaged vehicle.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'minor':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'major':
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  PdfColor _getSeverityPdfColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'minor':
        return PdfColors.green700;
      case 'moderate':
        return PdfColors.orange700;
      case 'major':
      case 'severe':
        return PdfColors.red700;
      default:
        return PdfColors.grey700;
    }
  }

  Color _getFraudRiskColor(String risk) {
    if (risk.toLowerCase().contains('low')) {
      return Colors.green;
    } else if (risk.toLowerCase().contains('medium')) {
      return Colors.orange;
    } else if (risk.toLowerCase().contains('high')) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  PdfColor _getFraudRiskPdfColor(String risk) {
    if (risk.toLowerCase().contains('low')) {
      return PdfColors.green700;
    } else if (risk.toLowerCase().contains('medium')) {
      return PdfColors.orange700;
    } else if (risk.toLowerCase().contains('high')) {
      return PdfColors.red700;
    } else {
      return PdfColors.grey700;
    }
  }
}