class Photo {
  final String type; // "Lindo" o "Feo"
  final String user; // Usuario que lo agregó
  final int randomNumber; // Número aleatorio
  int votes; // Número de votos
  Set<String> votedUsers; // Usuarios que ya han votado
  final DateTime dateAdded; // Fecha en que se agregó la foto
  final String base64Image; // Imagen codificada en Base64
  final String customName; // Nombre personalizado opcional

  Photo({
    required this.type,
    required this.user,
    required this.randomNumber,
    this.votes = 0,
    Set<String>? votedUsers,
    required this.dateAdded,
    required this.base64Image,
    required this.customName, // Inicializar el nombre personalizado
  }) : votedUsers = votedUsers ?? {};
}
