import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isProcessing = false;
  int _creditoActual = 0;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _cargarCredito();
  }

  Future<void> _cargarCredito() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('balances')
        .select('balance')
        .eq('user_id', user.id);

    int total = 0;
    for (var item in response) {
      total += (item['balance'] ?? 0) as int;
    }

    setState(() {
      _creditoActual = total;
    });
  }

  Future<void> _borrarCredito() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('balances').delete().eq('user_id', user.id);
    setState(() {
      _creditoActual = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Crédito borrado.')),
    );
  }

  void _logout(BuildContext context) {
    supabase.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _handleBarcode(
      BarcodeCapture barcodes, BuildContext context) async {
    if (_isProcessing) return;

    final scannedCode = barcodes.barcodes.first.displayValue?.trim();
    if (scannedCode == null) {
      _showSnackBar(context, 'No se pudo leer el código.', Colors.orange);
      if (context.mounted) {
        Navigator.pop(context); // Regresar a la pantalla de inicio
      }
      return;
    }

    print('Código escaneado: $scannedCode');
    _isProcessing = true;

    final knownCodes = {
      '8c95def646b6127282ed50454b73240300dccabc': 10,
      'ae338e4e0cbb4e4bcffaf9ce5b409feb8edd5172': 50,
      '2786f4877b9091dcad7f35751bfcf5d5ea712b2f': 100,
    };

    if (knownCodes.containsKey(scannedCode)) {
      final credito = knownCodes[scannedCode]!;
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        try {
          // Verificar si el usuario es admin
          final isAdmin = user.email == 'admin@admin.com';

          final response = await supabase
              .from('balances')
              .select('id')
              .eq('user_id', user.id)
              .eq('redeemed_code', scannedCode);

          final data = response as List<dynamic>?;

          final canjeos = data?.length ?? 0;

          if (!isAdmin && canjeos > 0) {
            // Usuario normal: no puede canjear más de una vez
            _showSnackBar(context, 'Este código ya fue canjeado.', Colors.red);
          } else if (isAdmin && canjeos >= 2) {
            // Admin: no puede canjear más de 2 veces
            _showSnackBar(
                context, 'Este código ya fue canjeado 2 veces.', Colors.red);
          } else {
            // Insertar el nuevo código
            await Supabase.instance.client.from('balances').insert({
              'user_id': user.id,
              'redeemed_code': scannedCode,
              'balance': credito,
            });

            _showSnackBar(
                context, 'Crédito actualizado: +$credito', Colors.green);
            await _cargarCredito();
          }
        } catch (e) {
          _showSnackBar(context, 'Error: $e', Colors.red);
        }
      }
    } else {
      _showSnackBar(context, 'Código desconocido.', Colors.orange);
    }

    // Regresar automáticamente a la pantalla de inicio
    if (context.mounted) {
      Navigator.pop(context); // Cierra la pantalla de la cámara
    }

    _isProcessing = false;
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final isAdmin = user?.email == 'admin@admin.com';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Usuario y botón de logout en una tarjeta
              if (user != null)
                Card(
                  color: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  margin: EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Color(0xFF0D47A1),
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 22),
                                ),
                                if (user.email == 'admin@admin.com')
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 9,
                                      backgroundColor: Colors.amber,
                                      child: Icon(Icons.star,
                                          color: Colors.white, size: 14),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Row(
                              children: [
                                Text(
                                  user.email ?? 'Usuario',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.logout, color: Colors.red),
                          onPressed: () => _logout(context),
                          tooltip: 'Cerrar sesión',
                        ),
                      ],
                    ),
                  ),
                ),
              // Espaciado igual entre usuario y crédito, y entre crédito y cargar crédito
              SizedBox(height: 24),
              // Crédito disponible bien grande, en una tarjeta blanca
              Expanded(
                flex: 2,
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  margin: EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 36, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Crédito disponible',
                              style: TextStyle(
                                fontSize: 22,
                                color: Color(0xFF0D47A1),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.delete_forever,
                                  color: Colors.red, size: 22),
                              tooltip: 'Borrar crédito',
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded,
                                            color: Color(0xFF0D47A1)),
                                        SizedBox(width: 8),
                                        Text('Confirmar',
                                            style: TextStyle(
                                                color: Color(0xFF0D47A1),
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    content: Text(
                                      '¿Seguro que deseas borrar el crédito? Esta acción no se puede deshacer.',
                                      style:
                                          TextStyle(color: Color(0xFF0D47A1)),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text('Cancelar',
                                            style: TextStyle(
                                                color: Color(0xFF0D47A1),
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text('Borrar',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _borrarCredito();
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                        Center(
                          child: Text(
                            '\$$_creditoActual',
                            style: TextStyle(
                              fontSize: 100, // aumentado
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                              letterSpacing: 2,
                              fontFamily: 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Botón de cargar crédito (leer QR), ocupa como una tarjeta pero más pequeño
              SizedBox(
                height: 140,
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRScannerScreen(
                            onDetect: (barcodes) =>
                                _handleBarcode(barcodes, context),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.qrcode,
                              color: Color(0xFF0D47A1), size: 60),
                          SizedBox(height: 10),
                          Text(
                            'Cargar crédito',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                              fontFamily: 'Roboto',
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFF0D47A1),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  final Function(BarcodeCapture) onDetect;

  const QRScannerScreen({required this.onDetect});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear Código QR'),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture barcodes) async {
          if (_hasScanned) return;
          _hasScanned = true;

          await widget.onDetect(barcodes);
        },
      ),
    );
  }
}
