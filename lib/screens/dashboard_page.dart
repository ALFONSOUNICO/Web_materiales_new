import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/material.dart';

class DashboardPage extends StatelessWidget {
  final List<MaterialSap> materiales;
  final String fechaDesde;
  final String fechaHasta;
  final int totalEsperado;

  const DashboardPage({
    super.key,
    required this.materiales,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.totalEsperado,
  });

  int get conVbap => materiales.where((m) => m.vbap.isNotEmpty).length;
  int get sinVbap => materiales.where((m) => m.vbap.isEmpty).length;
  int get totalPosiciones => materiales.fold(0, (t, m) => t + m.vbap.length);
  double get totalWavwr => materiales.fold(
        0,
        (t, m) => t + m.vbap.fold(0.0, (s, p) => s + p.wavwr),
      );
  double get totalMwsbp => materiales.fold(
        0,
        (t, m) => t + m.vbap.fold(0.0, (s, p) => s + p.mwsbp),
      );

  List<_MaterialMetric> get _topMaterialesPorWavwr {
    final lista = materiales
        .map((m) => _MaterialMetric(
              m.matnr,
              m.vbap.fold(0.0, (s, p) => s + p.wavwr),
            ))
        .where((m) => m.valor > 0)
        .toList();
    lista.sort((a, b) => b.valor.compareTo(a.valor));
    return lista.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    final porcentajeCon = materiales.isEmpty ? 0.0 : conVbap / materiales.length;
    final porcentajeSin = materiales.isEmpty ? 0.0 : sinVbap / materiales.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Row(
          children: [
            Icon(Icons.dashboard_rounded),
            SizedBox(width: 12),
            Text('Dashboard de materiales SAP', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Análisis de resultados',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF123B66)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Indicadores construidos con los ${materiales.length} materiales recuperados de la consulta.',
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver a resultados'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Periodo: $fechaDesde al $fechaHasta',
                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1000 ? 4 : 2;
                    final itemWidth = (constraints.maxWidth - (columns - 1) * 14) / columns;
                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        _DashboardKpi(width: itemWidth, title: 'Total materiales', value: '$totalEsperado', subtitle: 'Rango consultado', icon: Icons.inventory_2_outlined),
                        _DashboardKpi(width: itemWidth, title: 'Con posiciones VBAP', value: '$conVbap', subtitle: '${(porcentajeCon * 100).toStringAsFixed(1)} % del total', icon: Icons.check_circle_outline),
                        _DashboardKpi(width: itemWidth, title: 'Sin posiciones VBAP', value: '$sinVbap', subtitle: '${(porcentajeSin * 100).toStringAsFixed(1)} % del total', icon: Icons.info_outline),
                        _DashboardKpi(width: itemWidth, title: 'Posiciones VBAP', value: '$totalPosiciones', subtitle: 'Registros encontrados', icon: Icons.description_outlined),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final actividad = _DashboardCard(
                      title: 'Materiales con y sin posiciones VBAP',
                      subtitle: 'Distribución de materiales según su actividad en el periodo seleccionado.',
                      child: SizedBox(height: 370, child: _DonutChart(conVbap: conVbap, sinVbap: sinVbap)),
                    );
                    final ranking = _DashboardCard(
                      title: 'Top 10 materiales por WAVWR acumulado',
                      subtitle: 'Suma de WAVWR de las posiciones VBAP encontradas por material.',
                      child: SizedBox(height: 370, child: _HorizontalBarChart(data: _topMaterialesPorWavwr)),
                    );
                    if (constraints.maxWidth < 1050) {
                      return Column(children: [actividad, const SizedBox(height: 18), ranking]);
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Expanded(child: actividad), const SizedBox(width: 18), Expanded(child: ranking)],
                    );
                  },
                ),
                const SizedBox(height: 18),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: 36,
                      runSpacing: 14,
                      children: [
                        _MetricFooter(label: 'WAVWR acumulado', value: totalWavwr.toStringAsFixed(2), icon: Icons.trending_up_rounded),
                        _MetricFooter(label: 'MWSBP acumulado', value: totalMwsbp.toStringAsFixed(2), icon: Icons.account_balance_outlined),
                        _MetricFooter(label: 'Materiales analizados', value: '${materiales.length} / $totalEsperado', icon: Icons.analytics_outlined),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaterialMetric {
  final String material;
  final double valor;
  const _MaterialMetric(this.material, this.valor);
}

class _DashboardKpi extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _DashboardKpi({required this.width, required this.title, required this.value, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFE8F1FC), borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: const Color(0xFF1565C0)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF123B66))),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _DashboardCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF123B66))),
            const SizedBox(height: 5),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricFooter extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricFooter({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF1565C0), size: 25),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF123B66))),
          ],
        ),
      ],
    );
  }
}

class _DonutChart extends StatelessWidget {
  final int conVbap;
  final int sinVbap;
  const _DonutChart({required this.conVbap, required this.sinVbap});

  @override
  Widget build(BuildContext context) {
    final total = conVbap + sinVbap;
    if (total == 0) return const Center(child: Text('No hay datos para graficar.'));

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: _DonutPainter(conVbap: conVbap, sinVbap: sinVbap),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$total', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF123B66))),
                      Text('materiales', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DonutLegend(color: const Color(0xFF1565C0), title: 'Con posiciones VBAP', value: conVbap, total: total),
              const SizedBox(height: 20),
              _DonutLegend(color: const Color(0xFFB0BEC5), title: 'Sin posiciones VBAP', value: sinVbap, total: total),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutLegend extends StatelessWidget {
  final Color color;
  final String title;
  final int value;
  final int total;
  const _DonutLegend({required this.color, required this.title, required this.value, required this.total});

  @override
  Widget build(BuildContext context) {
    final porcentaje = total == 0 ? 0.0 : value / total * 100;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 12, height: 12, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 3),
              Text('$value · ${porcentaje.toStringAsFixed(1)} %', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int conVbap;
  final int sinVbap;
  _DonutPainter({required this.conVbap, required this.sinVbap});

  @override
  void paint(Canvas canvas, Size size) {
    final total = conVbap + sinVbap;
    if (total == 0) return;
    final center = size.center(Offset.zero);
    final dimension = math.min(size.width, size.height);
    final radio = dimension * .34;
    final stroke = dimension * .12;
    final rect = Rect.fromCircle(center: center, radius: radio);

    final fondo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFE8EDF3);
    canvas.drawCircle(center, radio, fondo);

    final anguloCon = 2 * math.pi * conVbap / total;
    final con = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = const Color(0xFF1565C0);
    canvas.drawArc(rect, -math.pi / 2, anguloCon, false, con);

    final sin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = const Color(0xFFB0BEC5);
    canvas.drawArc(rect, -math.pi / 2 + anguloCon, 2 * math.pi - anguloCon, false, sin);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.conVbap != conVbap || oldDelegate.sinVbap != sinVbap;
}

class _HorizontalBarChart extends StatelessWidget {
  final List<_MaterialMetric> data;
  const _HorizontalBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('No hay valores WAVWR positivos para graficar.'));
    final maximo = data.map((item) => item.valor).reduce(math.max);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 8, 6),
      child: Column(
        children: data.map((item) {
          final porcentaje = maximo == 0 ? 0.0 : item.valor / maximo;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 132,
                  child: Text(item.material, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(height: 23, decoration: BoxDecoration(color: const Color(0xFFEAF0F6), borderRadius: BorderRadius.circular(7))),
                      FractionallySizedBox(
                        widthFactor: porcentaje,
                        child: Container(
                          height: 23,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                SizedBox(
                  width: 76,
                  child: Text(item.valor.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF123B66))),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

