import 'dart:convert';
import 'dart:io';

void main() async {
  // Read radicals_with_tips.json
  final radicalsWithTipsFile = File('assets/radicals/radicals_with_tips.json');
  if (!await radicalsWithTipsFile.exists()) {
    print('Error: assets/radicals/radicals_with_tips.json not found');
    exit(1);
  }

  final radicalsWithTipsContent = await radicalsWithTipsFile.readAsString();
  final radicalsWithTips = List<Map<String, dynamic>>.from(
    jsonDecode(radicalsWithTipsContent),
  );

  // Create a set that includes both symbol and alternateSymbols
  final Set<String> allRadicalsSet = {};
  for (final radical in radicalsWithTips) {
    final symbol = radical['symbol'] as String?;
    
    if (symbol != null && symbol.isNotEmpty) {
      allRadicalsSet.add(symbol);
    }
    
    // Handle both old format (alternateSymbol) and new format (alternateSymbols)
    if (radical['alternateSymbols'] != null) {
      final alternateSymbols = radical['alternateSymbols'] as List<dynamic>;
      for (final alt in alternateSymbols) {
        if (alt != null && alt.toString().isNotEmpty) {
          allRadicalsSet.add(alt.toString());
        }
      }
    } else if (radical['alternateSymbol'] != null) {
      // Backward compatibility
      final alternateSymbol = radical['alternateSymbol'] as String?;
      if (alternateSymbol != null && alternateSymbol.isNotEmpty) {
        allRadicalsSet.add(alternateSymbol);
      }
    }
  }

  print('Loaded ${radicalsWithTips.length} radicals from radicals_with_tips.json');
  print('Total unique symbols (including alternates): ${allRadicalsSet.length}\n');

  // Get all HSK JSON files (excluding minified folder)
  final hskDir = Directory('assets/hsk');
  if (!await hskDir.exists()) {
    print('Error: assets/hsk directory not found');
    exit(1);
  }

  final hskFiles = hskDir
      .listSync()
      .whereType<File>()
      .where((file) => 
          file.path.endsWith('.json') && 
          !file.path.contains('minified'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (hskFiles.isEmpty) {
    print('Error: No HSK JSON files found in assets/hsk');
    exit(1);
  }

  print('Found ${hskFiles.length} HSK JSON files to process:');
  for (final file in hskFiles) {
    print('  - ${file.path}');
  }
  print('');

  // Collect all unique radicals from HSK files
  final Set<String> radicalsFromHsk = {};
  final Map<String, Set<String>> radicalToFiles = {}; // Track which files contain each radical

  for (final file in hskFiles) {
    try {
      print('Processing ${file.path}...');
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      int entriesProcessed = 0;
      for (final entry in data) {
        if (entry is Map<String, dynamic>) {
          final radical = entry['radical'] as String?;
          if (radical != null && radical.isNotEmpty) {
            radicalsFromHsk.add(radical);
            radicalToFiles.putIfAbsent(radical, () => <String>{}).add(file.path);
            entriesProcessed++;
          }
        }
      }
      print('  Processed $entriesProcessed entries');
    } catch (e) {
      print('  Error processing ${file.path}: $e');
    }
  }

  print('');
  print('Found ${radicalsFromHsk.length} unique radicals in HSK files\n');

  // Check which radicals from HSK files are missing from radicals_with_tips.json
  final missingRadicals = <String>[];
  for (final radical in radicalsFromHsk) {
    if (!allRadicalsSet.contains(radical)) {
      missingRadicals.add(radical);
    }
  }

  // Report results
  print('=== Results ===');
  print('Total unique radicals in HSK files: ${radicalsFromHsk.length}');
  print('Total radicals in radicals_with_tips.json: ${radicalsWithTips.length}');
  print('Total unique symbols (including alternates): ${allRadicalsSet.length}');
  print('');

  var hasErrors = false;

  if (missingRadicals.isEmpty) {
    print('✓ All radicals from HSK files appear in radicals_with_tips.json (including alternateSymbols)!');
  } else {
    hasErrors = true;
    print('✗ Missing radicals (${missingRadicals.length}):');
    for (final radical in missingRadicals) {
      final files = radicalToFiles[radical] ?? <String>{};
      final fileList = files.toList()..sort();
      print('  - $radical (found in: ${fileList.join(", ")})');
    }
  }

  // Also check for radicals in radicals_with_tips.json that are not used in HSK files
  final unusedRadicals = allRadicalsSet.difference(radicalsFromHsk);
  print('');
  print('Radicals in radicals_with_tips.json but not found in HSK files: ${unusedRadicals.length}');
  if (unusedRadicals.length <= 20) {
    print('  (This is normal - not all radicals may be used in HSK levels)');
  }

  // Summary
  print('');
  print('=== Summary ===');
  print('  Radicals in HSK files: ${radicalsFromHsk.length}');
  print('  Radicals in radicals_with_tips.json: ${radicalsWithTips.length}');
  print('  Unique symbols (including alternates): ${allRadicalsSet.length}');
  print('  Missing from radicals_with_tips.json: ${missingRadicals.length}');
  print('  Unused in HSK files: ${unusedRadicals.length}');

  if (hasErrors) {
    exit(1);
  }
}

