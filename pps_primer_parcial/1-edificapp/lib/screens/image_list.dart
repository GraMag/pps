import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Importar intl para formatear fechas
import 'package:intl/date_symbol_data_local.dart'; // Importar para inicializar locales
import '../models/photo.dart';
import '../state/state.dart';
import 'photo_selection.dart';
import 'pie_chart.dart';
import 'bar_chart.dart';

class ImageListPage extends StatefulWidget {
  final String type; // "Lindo" o "Feo"

  ImageListPage({required this.type});

  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Inicializar la configuración regional para fechas
    initializeDateFormatting('es_ES', null);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    List<Photo> filteredPhotos = appState.photos
        .where((photo) => photo.type == widget.type)
        .toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    Photo? currentPhoto =
        filteredPhotos.isNotEmpty ? filteredPhotos[currentIndex] : null;

    final Color mainColor =
        widget.type == 'Lindo' ? Color(0xFF388E3C) : Color(0xFFB71C1C);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Volver',
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                widget.type == 'Lindo' ? Icons.pie_chart : Icons.bar_chart,
                color: Colors.white,
              ),
              tooltip: widget.type == 'Lindo'
                  ? 'Ver gráfico de torta'
                  : 'Ver gráfico de barras',
              onPressed: () {
                if (widget.type == 'Lindo') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PieChartPage()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BarChartPage()),
                  );
                }
              },
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PhotoSelectionPage(type: widget.type),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5F5F7),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  elevation: 1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, size: 22, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(
                      'Subir imagen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      widget.type == 'Lindo'
                          ? Icons.sentiment_satisfied
                          : Icons.sentiment_dissatisfied,
                      size: 22,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              mainColor.withOpacity(0.18),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Imagen actual y detalles
            Expanded(
              child: currentPhoto != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Card(
                        elevation: 6,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        color: Colors.white.withOpacity(0.92),
                        child: Column(
                          children: [
                            // Encabezado con el título de la imagen y el usuario
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentPhoto.customName.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.person,
                                          size: 16, color: Colors.grey[600]),
                                      SizedBox(width: 8),
                                      Text(
                                        'Subido por ${currentPhoto.user}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Imagen
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10)),
                                child: Image.memory(
                                  base64Decode(currentPhoto.base64Image),
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            // Votos, botón de votar y fecha
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: currentPhoto.votedUsers
                                            .contains(appState.activeUser)
                                        ? null
                                        : () {
                                            appState.votePhoto(
                                                currentPhoto, true);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                    ),
                                    icon: Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          size: 20,
                                          color: currentPhoto.votedUsers
                                                  .contains(appState.activeUser)
                                              ? Colors.grey
                                              : Colors.blue,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${currentPhoto.votes}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    label: Text(
                                      currentPhoto.votedUsers
                                              .contains(appState.activeUser)
                                          ? 'Ya votaste'
                                          : 'Votar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 16, color: Colors.grey[700]),
                                      SizedBox(width: 8),
                                      Text(
                                        DateFormat('d \'de\' MMMM \'de\' yyyy',
                                                'es_ES')
                                            .format(currentPhoto.dateAdded),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'No hay imágenes ${widget.type.toLowerCase()} disponibles.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
            ),
            // Indicadores de navegación y posición
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Botón Anterior
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          minimumSize: Size(44, 44),
                        ),
                        onPressed: currentIndex > 0
                            ? () {
                                setState(() {
                                  currentIndex--;
                                });
                              }
                            : null,
                        child: Icon(Icons.chevron_left,
                            size: 22, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 8), // Separación entre botón y contador
                  // Contador de páginas
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          '${filteredPhotos.isEmpty ? 0 : currentIndex + 1}/${filteredPhotos.length}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8), // Separación entre contador y botón
                  // Botón Siguiente
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          minimumSize: Size(44, 44),
                        ),
                        onPressed: currentIndex < filteredPhotos.length - 1
                            ? () {
                                setState(() {
                                  currentIndex++;
                                });
                              }
                            : null,
                        child: Icon(Icons.chevron_right,
                            size: 22, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
