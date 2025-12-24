import 'dart:convert';
import 'dart:io';

void main() {
  final hskDir = Directory('assets/hsk');
  final outputFile = File('assets/radicals/radicals_dictionary.json');
  
  // Ensure output directory exists
  outputFile.parent.createSync(recursive: true);
  
  final Map<String, String> radicalsDictionary = {};
  int totalSymbolsProcessed = 0;
  int newKeysCreated = 0;
  
  // Get all min.json files
  final minJsonFiles = hskDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.min.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  
  print('Found ${minJsonFiles.length} min.json files to process');
  
  // Process each min.json file
  for (final file in minJsonFiles) {
    print('Processing ${file.path}...');
    
    try {
      final content = file.readAsStringSync();
      final List<dynamic> data = jsonDecode(content);
      
      for (final entry in data) {
        if (entry is Map<String, dynamic>) {
          final symbol = entry['s'] as String?; // 's' is the simplified symbol
          final radical = entry['r'] as String?; // 'r' is the radical
          
          if (symbol != null && radical != null) {
            // Count all symbols processed
            totalSymbolsProcessed++;
            
            // Only add symbols that are exactly 1 character long to the dictionary
            if (symbol.length == 1) {
              // Check if this is a new key
              if (!radicalsDictionary.containsKey(symbol)) {
                radicalsDictionary[symbol] = radical;
                newKeysCreated++;
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error processing ${file.path}: $e');
    }
  }
  
  // Write the dictionary to JSON file
  final jsonOutput = jsonEncode(radicalsDictionary);
  outputFile.writeAsStringSync(jsonOutput);
  
  // Print statistics
  print('\n=== Statistics ===');
  print('Total symbols processed: $totalSymbolsProcessed');
  print('New keys created: $newKeysCreated');
  print('Total unique symbols in dictionary: ${radicalsDictionary.length}');
  print('Output written to: ${outputFile.path}');
}

