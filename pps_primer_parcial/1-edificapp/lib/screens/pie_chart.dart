import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import 'package:fl_chart/fl_chart.dart';
import '../state/state.dart';
import '../screens/photo_detail.dart';

class PieChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // Filtrar las fotos "Lindo" y contar los votos
    List<Photo> lindoPhotos = appState.photos
        .where((photo) => photo.type == 'Lindo' && photo.votes > 0)
        .toList();

    // Calcular el total de votos
    int totalVotes = lindoPhotos.fold(0, (sum, photo) => sum + photo.votes);

    // Generar colores dinámicamente (menos saturados)
    List<Color> generateColors(int count) {
      return List.generate(
        count,
        (index) => HSVColor.fromAHSV(
          1.0,
          (360 / count) * index,
          0.45, // Menos saturación
          0.85, // Menos brillo
        ).toColor(),
      );
    }

    List<Color> colors = generateColors(lindoPhotos.length);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Volver',
        ),
        backgroundColor: Color(0xFF388E3C),
        elevation: 1,
        title: Text(
          'Fotos Lindas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF388E3C).withOpacity(0.18),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: lindoPhotos.isNotEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white.withOpacity(0.94),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Gráfico de torta
                          Expanded(
                            flex: 2,
                            child: PieChart(
                              PieChartData(
                                sections:
                                    lindoPhotos.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Photo photo = entry.value;
                                  double percentage =
                                      (photo.votes / totalVotes) * 100;
                                  return PieChartSectionData(
                                    value: photo.votes.toDouble(),
                                    title: '${percentage.toStringAsFixed(1)}%',
                                    color: colors[index],
                                    radius: 100,
                                    titleStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    badgeWidget: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PhotoDetailsPage(photo: photo),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.info,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    ),
                                    badgePositionPercentageOffset: 1.2,
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          // Leyenda centrada dentro de la carta
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: lindoPhotos.asMap().entries.map((entry) {
                              int index = entry.key;
                              Photo photo = entry.value;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: colors[index],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    photo.customName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  'No hay votos para fotos Lindas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
      ),
    );
  }
}
