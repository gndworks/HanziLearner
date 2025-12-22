import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length != 2) {
    print('Usage: dart minify_json.dart <input.json> <output.json>');
    exit(1);
  }

  final inputPath = args[0];
  final outputPath = args[1];

  try {
    // Read the input JSON file
    final inputFile = File(inputPath);
    if (!inputFile.existsSync()) {
      print('Error: Input file "$inputPath" not found');
      exit(1);
    }

    final inputContent = inputFile.readAsStringSync();
    final jsonData = jsonDecode(inputContent);

    // Ensure the input is an array
    if (jsonData is! List) {
      print('Error: Input JSON must be an array');
      exit(1);
    }

    // Map to only include the "s" property and add empty "t" property
    final mappedData = jsonData
        .map((item) {
          if (item is Map && item.containsKey('s')) {
            return {
              's': item['s'],
              't': ''
            };
          }
          return null;
        })
        .where((item) => item != null)
        .toList();

    // Write the output JSON file
    final outputFile = File(outputPath);
    final outputContent = jsonEncode(mappedData);
    outputFile.writeAsStringSync(outputContent);

    print('Successfully created $outputPath');
    print('Original items: ${jsonData.length}');
    print('Mapped items: ${mappedData.length}');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

