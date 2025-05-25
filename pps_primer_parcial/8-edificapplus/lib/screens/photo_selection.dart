import 'dart:convert';
import 'dart:io';
import 'package:edificappro/models/photo.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart'; // Importar FilePicker
import '../state/state.dart';
import 'package:provider/provider.dart';
import '../widgets/loading_dialog.dart';

const String defaultBase64Image =
    'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';

class PhotoSelectionPage extends StatefulWidget {
  final String type; // "Lindo" o "Feo"

  PhotoSelectionPage({required this.type});

  @override
  _PhotoSelectionPageState createState() => _PhotoSelectionPageState();
}

class _PhotoSelectionPageState extends State<PhotoSelectionPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> selectedPhotos = []; // Lista de fotos seleccionadas o tomadas
  final TextEditingController _nameController =
      TextEditingController(); // Controlador para el nombre personalizado

  Future<void> _takePhoto() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Tomar una foto con la cámara
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          selectedPhotos.add(File(image.path));
        });
      }
    } else if (Platform.isLinux) {
      // Seleccionar una imagen desde la máquina en Linux
      /* final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false, // Solo permitir una imagen
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedPhotos.add(File(result.files.single.path!));
        });
      } */
    }
  }

  Future<void> _selectMultiplePhotos() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Seleccionar múltiples fotos de la galería
      final List<XFile>? images = await _picker.pickMultiImage();

      if (images != null && images.isNotEmpty) {
        setState(() {
          selectedPhotos.addAll(images.map((image) => File(image.path)));
        });
      }
    } else if (Platform.isLinux) {
      // Seleccionar imágenes en Linux usando FilePicker
      /* final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedPhotos.addAll(result.files.map((file) => File(file.path!)));
        });
      } */
    }
  }

  Future<void> _sendPhotos(BuildContext context) async {
    var appState = context.read<MyAppState>();

    try {
      // Mostrar el panel de carga
      LoadingDialog.show(context, message: 'Cargando imágenes...');

      await _runWithLoading(() async {
        for (var photo in selectedPhotos) {
          final bytes = await photo.readAsBytes();
          final base64Image = base64Encode(bytes);

          // Generar un nombre predeterminado si no se proporciona uno
          final randomNumber = DateTime.now().millisecondsSinceEpoch % 1000;
          final defaultName = '${widget.type}-$randomNumber';

          // Crear el objeto Photo con el nombre personalizado o el predeterminado
          final photoObject = Photo(
            type: widget.type,
            user: appState.activeUser!,
            randomNumber: randomNumber,
            dateAdded: DateTime.now(),
            base64Image: base64Image,
            customName: _nameController.text.isNotEmpty
                ? _nameController.text
                : defaultName, // Usar el nombre personalizado o el predeterminado
          );

          // Llamar al método addPhoto del estado global
          await appState.addPhoto(photoObject);
        }
      });

      // Mostrar un mensaje de éxito
      _showFloatingMessage(
          context, 'Fotos enviadas con éxito', Colors.white, Colors.green);
    } catch (e) {
      // Mostrar un mensaje de error
      _showFloatingMessage(context, 'Error al enviar las fotos: $e',
          Colors.orange.shade100, Colors.red);
    } finally {
      LoadingDialog.hide(context); // Cerrar el panel de carga

      // Volver al HomePage
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  void _showFloatingMessage(BuildContext context, String message,
      Color backgroundColor, Color textColor) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50, // Posición flotante en la parte inferior
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor, // Fondo dinámico
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor, // Color del texto dinámico
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Eliminar el mensaje después de 2 segundos
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<void> _runWithLoading(Future<void> Function() task) async {
    await task();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final bool isLindo = widget.type == 'Lindo';
    final Color mainColor = isLindo ? Color(0xFF388E3C) : Color(0xFFB71C1C);

    // Título personalizado
    final String titulo =
        isLindo ? 'Seleccionar Fotos Lindas' : 'Seleccionar Fotos Feas';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              isLindo
                  ? Icons.sentiment_satisfied_alt
                  : Icons.sentiment_dissatisfied,
              color: Colors.white,
              size: 26,
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 1,
      ),
      // Fondo degradado elegante
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              mainColor.withOpacity(0.15),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double margin = 20.0;
            return Padding(
              padding: const EdgeInsets.all(margin),
              child: Column(
                children: [
                  // Tarjeta principal
                  Expanded(
                    child: Card(
                      color: Colors.white.withOpacity(0.96),
                      elevation: 7,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información del usuario
                            Row(
                              children: [
                                Icon(Icons.person, size: 24, color: mainColor),
                                SizedBox(width: 8),
                                Text(
                                  appState.activeUser ?? 'Usuario desconocido',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Campo para el nombre personalizado
                            Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme:
                                    Theme.of(context).colorScheme.copyWith(
                                          primary: Colors.grey[800],
                                        ),
                              ),
                              child: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nombre personalizado (opcional)',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey[800]!,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Botones de acción
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _takePhoto,
                                    icon: Icon(Icons.camera_alt,
                                        color: Colors.white),
                                    label: Text('Tomar Foto'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          mainColor.withOpacity(0.92),
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      elevation: 2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _selectMultiplePhotos,
                                    icon: Icon(Icons.photo_library,
                                        color: Colors.white),
                                    label: Text('Seleccionar Fotos'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          mainColor.withOpacity(0.92),
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      elevation: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Caja de fotos expandida
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: selectedPhotos.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No se han seleccionado fotos',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600]),
                                        ),
                                      )
                                    : GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                        itemCount: selectedPhotos.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                  selectedPhotos[index],
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedPhotos
                                                          .removeAt(index);
                                                    });
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: Colors.red,
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Botón de enviar dentro de la tarjeta
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: selectedPhotos.isNotEmpty
                                    ? () => _sendPhotos(context)
                                    : null,
                                icon: Icon(Icons.upload, color: Colors.white),
                                label: Text('Enviar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
