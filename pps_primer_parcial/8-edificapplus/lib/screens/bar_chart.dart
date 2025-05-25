import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import 'package:fl_chart/fl_chart.dart';
import '../state/state.dart';
import '../screens/photo_detail.dart';
import 'dart:math';

class BarChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // Filtrar las fotos "Feo" con votos
    List<Photo> lindoPhotos = appState.photos
        .where((photo) => photo.type == 'Feo' && photo.votes > 0)
        .toList();

    // Ordenar las fotos por votos (de mayor a menor)
    lindoPhotos.sort((a, b) => b.votes.compareTo(a.votes));

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
        backgroundColor: Color(0xFFB71C1C),
        elevation: 1,
        title: Text(
          'Fotos Feas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB71C1C).withOpacity(0.18),
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
                          // Gráfico de barras
                          Expanded(
                            flex: 2,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: lindoPhotos
                                        .map((p) => p.votes)
                                        .reduce(max) *
                                    1.2,
                                barGroups:
                                    lindoPhotos.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Photo photo = entry.value;

                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: photo.votes.toDouble(),
                                        color: colors[index],
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                        backDrawRodData:
                                            BackgroundBarChartRodData(
                                          show: true,
                                          toY: lindoPhotos
                                                  .map((p) => p.votes)
                                                  .reduce(max) *
                                              1.2,
                                          color: Colors.grey[200],
                                        ),
                                      ),
                                    ],
                                    showingTooltipIndicators: [0],
                                  );
                                }).toList(),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[700],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        if (value.toInt() <
                                            lindoPhotos.length) {
                                          final photo =
                                              lindoPhotos[value.toInt()];
                                          final displayName = photo.customName;

                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PhotoDetailsPage(
                                                          photo: photo),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              displayName,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          );
                                        }
                                        return SizedBox.shrink();
                                      },
                                      reservedSize: 40,
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(show: true),
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBorder: BorderSide(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      width: 1,
                                    ), // Borde sutil
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      final photo =
                                          lindoPhotos[group.x.toInt()];
                                      final percentage =
                                          (photo.votes / totalVotes) * 100;
                                      return BarTooltipItem(
                                        '${percentage.toStringAsFixed(1)}%',
                                        TextStyle(
                                          color: const Color.fromARGB(
                                              221,
                                              255,
                                              255,
                                              255), // Texto oscuro para contraste
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          // Leyenda/referencias dentro de la carta
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: lindoPhotos.asMap().entries.map((entry) {
                              int index = entry.key;
                              Photo photo = entry.value;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PhotoDetailsPage(photo: photo),
                                    ),
                                  );
                                },
                                child: Row(
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
                                ),
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
                  'No hay votos para fotos Feas',
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
