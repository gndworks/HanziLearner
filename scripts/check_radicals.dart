import 'dart:convert';
import 'dart:io';

void main() async {
  // Read all_radicals.json
  final allRadicalsFile = File('assets/radicals/all_radicals.json');
  if (!await allRadicalsFile.exists()) {
    print('Error: assets/radicals/all_radicals.json not found');
    exit(1);
  }

  final allRadicalsContent = await allRadicalsFile.readAsString();
  final allRadicals = List<String>.from(jsonDecode(allRadicalsContent));

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

  // Check for duplicates in all_radicals.json
  final seenInAllRadicals = <String, int>{};
  final duplicatesInAllRadicals = <String>[];
  for (final radical in allRadicals) {
    seenInAllRadicals[radical] = (seenInAllRadicals[radical] ?? 0) + 1;
    if (seenInAllRadicals[radical] == 2) {
      duplicatesInAllRadicals.add(radical);
    }
  }

  // Check for duplicates in radicals_with_tips.json
  final seenInTips = <String, int>{};
  final duplicatesInTips = <String>[];
  for (final radical in radicalsWithTips) {
    final symbol = radical['symbol'] as String;
    seenInTips[symbol] = (seenInTips[symbol] ?? 0) + 1;
    if (seenInTips[symbol] == 2) {
      duplicatesInTips.add(symbol);
    }
  }

  // Create a set of symbols from radicals_with_tips.json
  final symbolsWithTips = radicalsWithTips
      .map((radical) => radical['symbol'] as String)
      .toSet();

  // Create a set of all radicals for quick lookup
  final allRadicalsSet = allRadicals.toSet();

  // Check which radicals from all_radicals.json are missing
  final missingRadicals = <String>[];
  for (final radical in allRadicals) {
    if (!symbolsWithTips.contains(radical)) {
      missingRadicals.add(radical);
    }
  }

  // Check which radicals in radicals_with_tips.json are not in all_radicals.json
  final extraRadicals = <String>[];
  for (final symbol in symbolsWithTips) {
    if (!allRadicalsSet.contains(symbol)) {
      extraRadicals.add(symbol);
    }
  }

  // Report results
  print('Total radicals in all_radicals.json: ${allRadicals.length}');
  print('Total radicals in radicals_with_tips.json: ${radicalsWithTips.length}');
  print('');

  var hasErrors = false;

  // Report duplicates in all_radicals.json
  if (duplicatesInAllRadicals.isNotEmpty) {
    hasErrors = true;
    print('✗ Duplicates found in all_radicals.json (${duplicatesInAllRadicals.length}):');
    for (final radical in duplicatesInAllRadicals) {
      final count = seenInAllRadicals[radical]!;
      print('  - $radical (appears $count times)');
    }
    print('');
  } else {
    print('✓ No duplicates in all_radicals.json');
  }

  // Report duplicates in radicals_with_tips.json
  if (duplicatesInTips.isNotEmpty) {
    hasErrors = true;
    print('✗ Duplicates found in radicals_with_tips.json (${duplicatesInTips.length}):');
    for (final symbol in duplicatesInTips) {
      final count = seenInTips[symbol]!;
      print('  - $symbol (appears $count times)');
    }
    print('');
  } else {
    print('✓ No duplicates in radicals_with_tips.json');
  }

  // Report missing radicals
  if (missingRadicals.isEmpty) {
    print('✓ All radicals from all_radicals.json exist in radicals_with_tips.json!');
  } else {
    hasErrors = true;
    print('✗ Missing radicals (${missingRadicals.length}):');
    for (final radical in missingRadicals) {
      print('  - $radical');
    }
  }

  // Report extra radicals
  if (extraRadicals.isNotEmpty) {
    hasErrors = true;
    print('');
    print('✗ Extra radicals in radicals_with_tips.json not found in all_radicals.json (${extraRadicals.length}):');
    for (final radical in extraRadicals) {
      print('  - $radical');
    }
  } else {
    print('✓ No extra radicals in radicals_with_tips.json');
  }

  // Summary
  print('');
  print('Summary:');
  print('  Unique radicals in all_radicals.json: ${allRadicalsSet.length}');
  print('  Unique radicals in radicals_with_tips.json: ${symbolsWithTips.length}');
  print('  Missing: ${missingRadicals.length}');
  print('  Extra: ${extraRadicals.length}');
  print('  Expected total in radicals_with_tips.json: ${allRadicalsSet.length - missingRadicals.length + extraRadicals.length}');
  print('  Actual total in radicals_with_tips.json: ${radicalsWithTips.length}');

  if (hasErrors) {
    exit(1);
  }
}

