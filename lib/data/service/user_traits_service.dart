import 'package:meetmern/main.dart';

class UserTraitsService {
  UserTraitsService._();

  static const String _table = 'user_traits';

  static List<String> _dedupeOrdered(Iterable<String> values) {
    final seen = <String>{};
    final output = <String>[];
    for (final raw in values) {
      final value = raw.trim();
      if (value.isEmpty) continue;
      final key = value.toLowerCase();
      if (!seen.add(key)) continue;
      output.add(value);
    }
    return output;
  }

  static Future<Map<String, List<String>>> fetchTraitOptions() async {
    final Map<String, List<String>> grouped = <String, List<String>>{};

    try {
      final rowsRaw = await supabase
          .from(_table)
          .select('trait_key, trait_value, sort_order')
          .eq('is_active', true)
          .order('trait_key', ascending: true)
          .order('sort_order', ascending: true)
          .order('trait_value', ascending: true);

      for (final raw in List<Map<String, dynamic>>.from(rowsRaw)) {
        final row = Map<String, dynamic>.from(raw);
        final traitKey = row['trait_key']?.toString().trim() ?? '';
        final traitValue = row['trait_value']?.toString().trim() ?? '';
        if (traitKey.isEmpty || traitValue.isEmpty) continue;
        final values = grouped.putIfAbsent(traitKey, () => <String>[]);
        values.add(traitValue);
      }

      grouped.updateAll((_, values) => _dedupeOrdered(values));
      return grouped;
    } catch (_) {
      return <String, List<String>>{};
    }
  }
}
