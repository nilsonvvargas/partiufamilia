import 'dart:async';
import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class TripCountdownCard extends StatefulWidget {
  final String? startDateStr;
  final String? endDateStr;
  final String destination;

  const TripCountdownCard({
    super.key,
    required this.startDateStr,
    required this.endDateStr,
    required this.destination,
  });

  @override
  State<TripCountdownCard> createState() => _TripCountdownCardState();
}

class _TripCountdownCardState extends State<TripCountdownCard> {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startDateStr == null || widget.startDateStr!.isEmpty) {
      return const SizedBox.shrink();
    }

    DateTime? start;
    DateTime? end;
    try {
      start = DateTime.parse(widget.startDateStr!);
    } catch (_) {}

    try {
      if (widget.endDateStr != null && widget.endDateStr!.isNotEmpty) {
        end = DateTime.parse(widget.endDateStr!);
      }
    } catch (_) {}

    if (start == null) return const SizedBox.shrink();

    // Start at midnight of start date
    final startDay = DateTime(start.year, start.month, start.day);
    final today = DateTime(_now.year, _now.month, _now.day);

    final diff = start.difference(_now);
    final daysRemaining = startDay.difference(today).inDays;

    final isToday = daysRemaining == 0;
    final isPast = daysRemaining < 0;

    bool isHappeningNow = false;
    if (isPast && end != null) {
      final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
      if (_now.isBefore(endDay)) {
        isHappeningNow = true;
      }
    }

    if (isHappeningNow) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: MaceioColors.palmGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MaceioColors.palmGreen.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MaceioColors.palmGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VIAGEM EM ANDAMENTO! 🌴',
                    style: TextStyle(
                      color: MaceioColors.palmGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Aproveite cada momento em ${widget.destination}!',
                    style: MaceioTypography.titleMedium.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (isToday) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [MaceioColors.coralAccent, MaceioColors.sunYellow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MaceioColors.coralAccent.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'É HOJE! PARTIU VIAGEM! ✈️',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Mala pronta? O paraíso te espera!',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (isPast) {
      return const SizedBox.shrink();
    }

    // Future trip countdown
    final hours = (diff.inHours % 24).clamp(0, 23);
    final minutes = (diff.inMinutes % 60).clamp(0, 59);

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MaceioColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MaceioColors.turquoisePrimary.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: MaceioColors.turquoisePrimary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: MaceioColors.coralAccent),
                  const SizedBox(width: 6),
                  Text(
                    'CONTAGEM REGRESSIVA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: MaceioColors.coralAccent,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: MaceioColors.oceanLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Faltam $daysRemaining ${daysRemaining == 1 ? "dia" : "dias"} ✈️',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: MaceioColors.turquoiseDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUnitBox(daysRemaining.toString().padLeft(2, '0'), 'DIAS', MaceioColors.turquoiseDark),
              _buildColon(),
              _buildUnitBox(hours.toString().padLeft(2, '0'), 'HORAS', MaceioColors.oceanDeep),
              _buildColon(),
              _buildUnitBox(minutes.toString().padLeft(2, '0'), 'MINUTOS', MaceioColors.coralAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitBox(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: MaceioColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildColon() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: MaceioColors.textMuted.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
