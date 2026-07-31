import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/features/admin/presentation/providers/admin_providers.dart';
import 'package:lumina/features/admin/presentation/widgets/admin_ui.dart';
import 'package:lumina/theme/app_colors.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Real-time overview of Programming with Eng. Hossam',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoft,
              ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            AdminStatCard(
              label: 'Total students',
              value: '${stats.totalStudents}',
              icon: Icons.people_alt_outlined,
            ),
            AdminStatCard(
              label: 'New today',
              value: '${stats.newToday}',
              icon: Icons.person_add_alt_1_outlined,
              accent: AppColors.secondary,
            ),
            AdminStatCard(
              label: 'Upcoming sessions',
              value: '${stats.upcomingSessions}',
              icon: Icons.event_available_outlined,
              accent: AppColors.accent,
            ),
            AdminStatCard(
              label: 'Attended',
              value: '${stats.attended}',
              icon: Icons.how_to_reg_outlined,
              accent: AppColors.success,
            ),
            AdminStatCard(
              label: 'Certificates issued',
              value: '${stats.certificatesIssued}',
              icon: Icons.workspace_premium_outlined,
            ),
            AdminStatCard(
              label: 'Certificates downloaded',
              value: '${stats.certificatesDownloaded}',
              icon: Icons.download_done_outlined,
              accent: AppColors.secondary,
            ),
            AdminStatCard(
              label: 'Reviews submitted',
              value: '${stats.reviewsSubmitted}',
              icon: Icons.rate_review_outlined,
              accent: AppColors.accent,
            ),
            AdminStatCard(
              label: 'Average rating',
              value: stats.averageRating == 0
                  ? '—'
                  : stats.averageRating.toStringAsFixed(1),
              icon: Icons.star_outline_rounded,
              accent: AppColors.accent,
            ),
          ],
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _ChartCard(
              title: 'Registrations per session',
              child: _BarChart(data: stats.regsPerSession),
            ),
            _ChartCard(
              title: 'Registrations by grade',
              child: _BarChart(data: stats.regsByGrade),
            ),
            _ChartCard(
              title: 'Registrations by city',
              child: _BarChart(data: stats.regsByCity),
            ),
            _ChartCard(
              title: 'Attendance rate',
              child: _RateRing(
                rate: stats.attendanceRate,
                label: '${(stats.attendanceRate * 100).round()}%',
                color: AppColors.success,
              ),
            ),
            _ChartCard(
              title: 'Certificate download rate',
              child: _RateRing(
                rate: stats.downloadRate,
                label: '${(stats.downloadRate * 100).round()}%',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? math.min(360.0, constraints.maxWidth)
            : 360.0;
        return SizedBox(
          width: w,
          height: 280,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(child: child),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.data});
  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data yet', style: TextStyle(color: AppColors.textMuted)),
      );
    }
    final entries = data.entries.toList();
    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: (maxY + 1).toDouble(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                final label = entries[i].key;
                final short = label.length > 10 ? '${label.substring(0, 10)}…' : label;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    short,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < entries.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value.toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RateRing extends StatelessWidget {
  const _RateRing({
    required this.rate,
    required this.label,
    required this.color,
  });

  final double rate;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 48,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    value: (rate.clamp(0, 1) * 100),
                    color: color,
                    radius: 16,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: ((1 - rate.clamp(0, 1)) * 100),
                    color: AppColors.border,
                    radius: 16,
                    showTitle: false,
                  ),
                ],
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
