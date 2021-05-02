class Food {
  int? idServer;
  String? name;
  double? calories;
  Food(
      {
      required this.idServer,
      required this.name,
      required this.calories});
  Food.fromMapSQL(Map<String, dynamic> mapSQL) {
    idServer = mapSQL["idServer"] ?? null;
    name = mapSQL["name"] ?? '';
    calories = mapSQL["calories"] ?? 0.0;
  }
  Map<String, dynamic> toMapSQL() {
    return {
      "idServer": idServer,
      "name": name,
      "calories": calories
    };
  }
}
