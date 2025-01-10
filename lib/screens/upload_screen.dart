// lib/screens/file_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AstraDBService {
  final String token = dotenv.env['APP_TOKEN'] ?? '';
  final String endpoint = dotenv.env['API_URL'] ?? '';
  final String keyspace = "default_keyspace";

  Future<void> insertData(String collection, List<Map<String, dynamic>> data) async {
    final url = Uri.parse('$endpoint/api/rest/v2/keyspaces/$keyspace/$collection');
    
    try {
      for (var document in data) {
        await http.post(
          url,
          headers: {
            'X-Cassandra-Token': token,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(document),
        );
      }
    } catch (e) {
      throw Exception('Failed to insert data: $e');
    }
  }
}

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final AstraDBService _astraService = AstraDBService();
  bool _isLoading = false;
  String _status = '';
  List<Map<String, dynamic>> _processedData = [];

  Future<void> _processCSV(File file) async {
    try {
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      if (fields.isEmpty) return;

      // Assuming first row contains headers
      final headers = List<String>.from(fields[0]);
      _processedData = [];

      // Convert rows to maps
      for (var i = 1; i < fields.length; i++) {
        final map = <String, dynamic>{};
        for (var j = 0; j < headers.length; j++) {
          map[headers[j]] = fields[i][j];
        }
        _processedData.add(map);
      }
    } catch (e) {
      throw Exception('Failed to process CSV: $e');
    }
  }

  Future<void> _processPDF(File file) async {
    try {
      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: file.readAsBytesSync());
      final String text = PdfTextExtractor(document).extractText();
      
      // Process the extracted text into structured data
      // This is a simple example - modify according to your PDF structure
      _processedData = [{
        'content': text,
        'filename': file.path.split('/').last,
        'timestamp': DateTime.now().toIso8601String(),
      }];

      document.dispose();
    } catch (e) {
      throw Exception('Failed to process PDF: $e');
    }
  }

  Future<void> _pickAndProcessFile() async {
    setState(() {
      _isLoading = true;
      _status = 'Selecting file...';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase();

        setState(() => _status = 'Processing file...');

        if (extension == 'csv') {
          await _processCSV(file);
        } else if (extension == 'pdf') {
          await _processPDF(file);
        }

        setState(() => _status = 'Uploading to database...');
        
        // Upload to AstraDB
        await _astraService.insertData('processed_files', _processedData);

        setState(() => _status = 'Data uploaded successfully!');
      }
    } catch (e) {
      setState(() => _status = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload PDF or CSV Files',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select a file to process and upload to the database',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _pickAndProcessFile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_isLoading ? 'Processing...' : 'Select File'),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const LinearProgressIndicator()
            else if (_status.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        _status.contains('Error')
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        color: _status.contains('Error')
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _status.contains('Error')
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_processedData.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Processed Data Preview:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _processedData.length,
                    itemBuilder: (context, index) {
                      final data = _processedData[index];
                      return ListTile(
                        title: Text('Record ${index + 1}'),
                        subtitle: Text(data.toString()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}