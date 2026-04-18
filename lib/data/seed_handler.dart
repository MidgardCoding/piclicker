import 'dart:math';

void validateUserSeed(String seed) {
  final regExp = RegExp(r'^\d[A-Z]\d{2}[A-Z]{2}\d{3}[A-Z]{3}$');
  if (!regExp.hasMatch(seed)) {
    throw Exception("Invalid seed.");
  }
}

// Random Valid Seed Generator
String generateRandomSeed() {
  final random = Random();
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  String n() => random.nextInt(10).toString();
  String l() => letters[random.nextInt(letters.length)];

  return "${n()}${l()}${n()}${n()}${l()}${l()}${n()}${n()}${n()}${l()}${l()}${l()}";
}

Map<String, dynamic> parseUserSeed(String userSeed) {
  // 1. Generating locationName
  String locationSeed = userSeed.substring(0, 10); // NLNN
  Map<int, String> syllableMap = {
    0: "e",
    1: "di",
    2: "re",
    3: "mi",
    4: "fra",
    5: "so",
    6: "la",
    7: "ve",
    8: "kji",
    9: "gne",
  };
  Map<int, String> syllableMap2 = {
    0: "no",
    1: "re",
    2: "ca",
    3: "upon",
    4: "ave",
    5: "ve",
    6: "ea",
    7: "ou",
    8: "on",
    9: "an",
  };
  Map<int, String> syllableMap3 = {
    0: "for",
    1: "back",
    2: "upon",
    3: "for",
    4: "and",
    5: "per",
    6: "can",
    7: "lea",
    8: "ceou",
    9: "na",
  };

  String s1 = syllableMap[int.parse(locationSeed[0])]!;
  String s2 = syllableMap2[int.parse(locationSeed[2])]!;
  String s3 = syllableMap3[int.parse(locationSeed[3])]!;

  // Connect the syllables
  String locationName = s1 + s2;
  if (locationName.length <= 4) {
    locationName = s2 + s3 + s1;
  } else if (locationName.length >= 6) {
    locationName = s3 + s1 + s2;
  } else {
    locationName = s1 + s2;
  }
  if (locationName.length <= 6) {
    locationName += s3;
  }
  // Capitalize (first letter capitalized, e.g. "Shregne")
  locationName =
      locationName[0].toUpperCase() + locationName.substring(1).toLowerCase();

  // 2. specialManagerId
  String specialManagerId = userSeed.substring(4, 6);

  // 3. primaryLocationColor
  Map<int, String> primaryColors = {
    0: "#D58936",
    1: "#69140E",
    2: "#B8C480",
    3: "#966B9D",
    4: "#334195",
    5: "#0DAB76",
    6: "#462255",
    7: "#9046CF",
    8: "#2F2F2F",
    9: "#C7AC92",
  };
  String primaryLocationColor = primaryColors[int.parse(userSeed[6])]!;

  // 4. secondaryLocationColor
  Map<int, String> secondaryColors = {
    0: "#F2F3AE",
    1: "#D0BCD5",
    2: "#EAE6E5",
    3: "#F2B880",
    4: "#FFFCF2",
    5: "#F0D2D1",
    6: "#FBFFF1",
    7: "#F3F9D2",
    8: "#FDECEF",
    9: "#FFFD98",
  };
  String secondaryLocationColor = secondaryColors[int.parse(userSeed[7])]!;

  // 5. lootPool
  String lootPool = userSeed[8];

  // 6. criticalChanceValue
  String lastThree = userSeed.substring(9, 12);
  double? criticalChanceValue;

  // Check if letters appear in the name (case-insensitive)
  bool allCharsInName = true;
  String nameLower = locationName.toLowerCase();
  for (int i = 0; i < lastThree.length; i++) {
    if (!nameLower.contains(lastThree[i].toLowerCase())) {
      allCharsInName = false;
      break;
    }
  }

  if (allCharsInName) {
    criticalChanceValue = calculateCriticalChance(lastThree);
  }

  // 7. expeditionTime
  String expeditionTime = calculateExpeditionTime(userSeed, lootPool);

  List locationLoot = [];

  return {
    'locationName': locationName,
    'specialManagerId': specialManagerId,
    'primaryLocationColor': primaryLocationColor,
    'secondaryLocationColor': secondaryLocationColor,
    'lootPool': lootPool,
    'criticalChanceValue': criticalChanceValue,
    'expeditionTime': expeditionTime,
  };
}

// Calculate the critical chance
double calculateCriticalChance(String chars) {
  List<int> codes = chars.runes.toList();

  // Rule 1: All the same
  if (chars[0] == chars[1] && chars[1] == chars[2]) return 3.0;

  // Rule 2: Consecutive (ABC, XYZ)
  List<int> sortedCodes = List.from(codes)..sort();
  if (sortedCodes[1] == sortedCodes[0] + 1 &&
      sortedCodes[2] == sortedCodes[1] + 1)
    return 2.5;

  // Rule 3: Max distance < 5
  int maxVal = sortedCodes.reduce(max);
  int minVal = sortedCodes.reduce(min);
  if (maxVal - minVal < 5) return 2.0;

  // Rule 4: All Consonants
  String vowels = "AEIOUY";
  bool allConsonants = chars.split('').every((char) => !vowels.contains(char));
  if (allConsonants) return 1.5;

  // Rule 5: All vowels
  bool allVowels = chars.split('').every((char) => vowels.contains(char));
  if (allVowels) return 1.0;

  return 0.0; // Default value if no rule matches (out of specification)
}

// Calculates expeditionTime based on the digits in the seed
String calculateExpeditionTime(String userSeed, String lootPool) {
  // Pull all the numbers out of the seed
  List<int> digits = [];
  for (int i = 0; i < userSeed.length; i++) {
    if (userSeed[i].codeUnitAt(0) >= 48 && userSeed[i].codeUnitAt(0) <= 57) {
      digits.add(int.parse(userSeed[i]));
    }
  }

  // Calculate the sum of the digits
  int sum = digits.reduce((a, b) => a + b);

  // Convert lootPool to number
  int lootPoolValue = int.parse(lootPool);

  // Use the rules
  if (sum > 27 && lootPoolValue < 4) {
    return "${sum} minutes";
  } else if (sum <= 27 && sum > 18 && lootPoolValue >= 4) {
    return "${sum} hours";
  } else if (sum <= 18 && sum > 9 && lootPoolValue >= 6) {
    return "${sum} days";
  } else if (sum <= 9 && lootPoolValue >= 8) {
    return "${sum} weeks";
  } else {
    // Default
    return "1 hour";
  }
}
