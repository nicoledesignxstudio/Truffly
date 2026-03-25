import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

enum SeasonalHighlightMode {
  active,
  countdown;

  static SeasonalHighlightMode fromValue(String value) {
    return switch (value.trim().toLowerCase()) {
      'active' => SeasonalHighlightMode.active,
      _ => SeasonalHighlightMode.countdown,
    };
  }
}

final class SeasonalHighlightResponse {
  const SeasonalHighlightResponse({
    required this.mode,
    required this.cards,
    required this.countdown,
  });

  final SeasonalHighlightMode mode;
  final List<SeasonalHighlightCardItem> cards;
  final SeasonalHighlightCountdown? countdown;

  factory SeasonalHighlightResponse.fromJson(Map<String, dynamic> json) {
    final rawCards = (json['cards'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    final rawCountdown = json['countdown'];

    return SeasonalHighlightResponse(
      mode: SeasonalHighlightMode.fromValue(json['mode'] as String? ?? ''),
      cards: rawCards.map(SeasonalHighlightCardItem.fromJson).toList(growable: false),
      countdown: rawCountdown is Map<String, dynamic>
          ? SeasonalHighlightCountdown.fromJson(rawCountdown)
          : null,
    );
  }
}

final class SeasonalHighlightCardItem {
  const SeasonalHighlightCardItem({
    required this.truffleType,
    required this.priority,
    required this.title,
    required this.subtitle,
    required this.imageKey,
    required this.startDate,
    required this.endDate,
  });

  final TruffleType truffleType;
  final int priority;
  final String title;
  final String subtitle;
  final String? imageKey;
  final DateTime startDate;
  final DateTime endDate;

  factory SeasonalHighlightCardItem.fromJson(Map<String, dynamic> json) {
    return SeasonalHighlightCardItem(
      truffleType: TruffleType.fromDbValue((json['truffle_type'] as String? ?? '').trim()),
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String? ?? '').trim(),
      subtitle: (json['subtitle'] as String? ?? '').trim(),
      imageKey: (json['image_key'] as String?)?.trim(),
      startDate: DateTime.parse(json['start_date'] as String? ?? ''),
      endDate: DateTime.parse(json['end_date'] as String? ?? ''),
    );
  }
}

final class SeasonalHighlightCountdown {
  const SeasonalHighlightCountdown({
    required this.truffleType,
    required this.title,
    required this.subtitle,
    required this.imageKey,
    required this.targetDate,
    required this.daysRemaining,
  });

  final TruffleType truffleType;
  final String title;
  final String subtitle;
  final String? imageKey;
  final DateTime targetDate;
  final int daysRemaining;

  factory SeasonalHighlightCountdown.fromJson(Map<String, dynamic> json) {
    return SeasonalHighlightCountdown(
      truffleType: TruffleType.fromDbValue((json['truffle_type'] as String? ?? '').trim()),
      title: (json['title'] as String? ?? '').trim(),
      subtitle: (json['subtitle'] as String? ?? '').trim(),
      imageKey: (json['image_key'] as String?)?.trim(),
      targetDate: DateTime.parse(json['target_date'] as String? ?? ''),
      daysRemaining: (json['days_remaining'] as num?)?.toInt() ?? 0,
    );
  }
}
