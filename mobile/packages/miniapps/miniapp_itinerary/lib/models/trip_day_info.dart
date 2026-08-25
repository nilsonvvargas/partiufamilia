class TripDayInfo {
  final int dayNumber;
  final DateTime date;
  final String dayLabel;
  final String dateShort;
  final String weekdayShort;
  final String fullDateLabel;
  final String fullWeekdayLabel;

  TripDayInfo({
    required this.dayNumber,
    required this.date,
    required this.dayLabel,
    required this.dateShort,
    required this.weekdayShort,
    required this.fullDateLabel,
    required this.fullWeekdayLabel,
  });

  static List<TripDayInfo> generateDaysForTrip({
    required String? startDateStr,
    required String? endDateStr,
    int? totalDaysCount,
  }) {
    DateTime start;
    try {
      if (startDateStr != null && startDateStr.isNotEmpty) {
        start = DateTime.parse(startDateStr);
      } else {
        start = DateTime.now();
      }
    } catch (_) {
      start = DateTime.now();
    }

    int count = totalDaysCount ?? 5;
    if (endDateStr != null && endDateStr.isNotEmpty) {
      try {
        final end = DateTime.parse(endDateStr);
        final diff = end.difference(start).inDays + 1;
        if (diff > 0 && diff < 60) count = diff;
      } catch (_) {}
    }

    const monthsShort = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    const monthsFull = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    const weekdaysShort = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    const weekdaysFull = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];

    final list = <TripDayInfo>[];
    for (int i = 0; i < count; i++) {
      final current = start.add(Duration(days: i));
      final dayNumber = i + 1;
      final mShort = monthsShort[current.month - 1];
      final mFull = monthsFull[current.month - 1];
      final wShort = weekdaysShort[current.weekday - 1];
      final wFull = weekdaysFull[current.weekday - 1];

      list.add(TripDayInfo(
        dayNumber: dayNumber,
        date: current,
        dayLabel: 'Dia $dayNumber',
        dateShort: '${current.day.toString().padLeft(2, '0')} $mShort',
        weekdayShort: wShort,
        fullDateLabel: '${current.day.toString().padLeft(2, '0')} de $mFull de ${current.year}',
        fullWeekdayLabel: wFull,
      ));
    }

    return list;
  }
}
