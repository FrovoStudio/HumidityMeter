import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/serial_service.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _serial = SerialService();
  StreamSubscription<SensorData>? _sub;
  bool _connected = false;
  String _statusMsg = 'Desconectado';
  double _temp = 0, _hum = 0;
  int _gas = 0, _samples = 0;
  final List<FlSpot> _tempSpots = [];
  final List<FlSpot> _humSpots = [];

  @override
  void initState() {
    super.initState();
    _sub = _serial.stream.listen(_onData);
  }

  void _onData(SensorData d) {
    if (!mounted) return;
    setState(() {
      _temp = d.temp;
      _hum = d.hum;
      _gas = d.gas;
      _samples++;
      _tempSpots.add(FlSpot(_samples.toDouble(), d.temp));
      _humSpots.add(FlSpot(_samples.toDouble(), d.hum));
      if (_tempSpots.length > 50) _tempSpots.removeAt(0);
      if (_humSpots.length > 50) _humSpots.removeAt(0);
    });
  }

  Future<void> _toggleConnection() async {
    if (_connected) {
      await _serial.disconnect();
      if (mounted) {
        setState(() {
          _connected = false;
          _statusMsg = 'Desconectado';
        });
      }
      return;
    }
    setState(() => _statusMsg = 'Conectando...');
    final devices = await _serial.listDevices();
    if (devices.isEmpty) {
      if (mounted) {
        setState(() => _statusMsg = 'No hay dispositivo USB');
        _snack('Conecta el Arduino por USB-C (OTG)');
      }
      return;
    }
    final ok = await _serial.connect();
    if (mounted) {
      setState(() {
        _connected = ok;
        _statusMsg = ok ? 'Conectado' : 'Error';
      });
      _snack(ok ? '✓ Conectado' : '✗ Falló la conexión');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  (String, Color) _sTemp(double v) {
    if (v >= 18 && v <= 26) return ('✓ Óptimo', const Color(0xFF34D399));
    if (v >= 15 && v <= 32) return ('⚠ Aceptable', const Color(0xFFFBBF24));
    return ('✗ Fuera de rango', const Color(0xFFF43F5E));
  }

  (String, Color) _sHum(double v) {
    if (v >= 40 && v <= 60) return ('✓ Óptimo', const Color(0xFF34D399));
    if (v >= 30 && v <= 70) return ('⚠ Aceptable', const Color(0xFFFBBF24));
    return ('✗ Fuera de rango', const Color(0xFFF43F5E));
  }

  (String, Color) _sGas(int v) {
    if (v < 300) return ('✓ Limpio', const Color(0xFF34D399));
    if (v < 600) return ('⚠ Moderado', const Color(0xFFFBBF24));
    return ('✗ Contaminado', const Color(0xFFF43F5E));
  }

  @override
  void dispose() {
    _sub?.cancel();
    _serial.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sT = _sTemp(_temp);
    final sH = _sHum(_hum);
    final sG = _sGas(_gas);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text('✨ Masterpiece',
            style: TextStyle(color: Color(0xFF38BDF8))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _toggleConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: _connected
                    ? const Color(0xFFF43F5E)
                    : const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF070A12),
              ),
              icon: Icon(_connected ? Icons.link_off : Icons.bolt),
              label: Text(_connected ? 'Desconectar' : 'Conectar'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.95,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MetricCard(
                  title: 'Temperatura',
                  subtitle: 'Calor del aire',
                  icon: '🌡',
                  unit: '°C',
                  value: _temp,
                  accent: const Color(0xFFF472B6),
                  statusText: sT.$1,
                  statusColor: sT.$2,
                  max: 50,
                ),
                MetricCard(
                  title: 'Humedad',
                  subtitle: 'Vapor de agua',
                  icon: '💧',
                  unit: '%',
                  value: _hum,
                  accent: const Color(0xFF38BDF8),
                  statusText: sH.$1,
                  statusColor: sH.$2,
                ),
                MetricCard(
                  title: 'Aire',
                  subtitle: 'CO₂ · NH₃',
                  icon: '🌿',
                  unit: 'ADC',
                  value: _gas.toDouble(),
                  accent: const Color(0xFF34D399),
                  statusText: sG.$1,
                  statusColor: sG.$2,
                  max: 1023,
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF374151)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estado',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_statusMsg,
                          style: TextStyle(
                              color: _connected
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF9CA3AF))),
                      const Spacer(),
                      Text('Muestras: $_samples',
                          style: const TextStyle(
                              color: Color(0xFF9CA3AF), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF374151)),
              ),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => const FlLine(
                        color: Color(0xFF374151), strokeWidth: 1),
                  ),
                  titlesData: const FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _tempSpots,
                      isCurved: true,
                      color: const Color(0xFFF472B6),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _humSpots,
                      isCurved: true,
                      color: const Color(0xFF38BDF8),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}