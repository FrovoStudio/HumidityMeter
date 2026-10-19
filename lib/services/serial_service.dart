import 'dart:async';
import 'dart:convert';
import 'package:usb_serial/usb_serial.dart';

class SensorData {
  final double temp;
  final double hum;
  final int gas;
  SensorData(this.temp, this.hum, this.gas);
}

class SerialService {
  UsbPort? _port;
  StreamSubscription<String>? _sub;
  final _controller = StreamController<SensorData>.broadcast();

  Stream<SensorData> get stream => _controller.stream;

  Future<List<UsbDevice>> listDevices() => UsbSerial.listDevices();

  Future<bool> connect() async {
    final devices = await UsbSerial.listDevices();
    if (devices.isEmpty) return false;

    _port = await devices.first.create();
    final opened = await _port!.open();
    if (!opened) return false;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
      115200,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    _sub = _port!.inputStream!
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .listen(_parseLine, onError: (_) {});

    return true;
  }

  void _parseLine(String line) {
    line = line.trim();
    if (line.isEmpty || line.contains('Millis')) return;
    final parts = line.split(',');
    if (parts.length != 4) return;
    try {
      final t = double.parse(parts[1]);
      final h = double.parse(parts[2]);
      final g = int.parse(parts[3]);
      _controller.add(SensorData(t, h, g));
    } catch (_) {}
  }

  Future<void> disconnect() async {
    await _sub?.cancel();
    _sub = null;
    await _port?.close();
    _port = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}