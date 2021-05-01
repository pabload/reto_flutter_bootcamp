class Food {
  String? name;
  double? calories;
  Food({required this.name, required this.calories});
  Food.fromMapSQL(Map<String, dynamic> mapSQL) {
    name = mapSQL["name"] ?? '';
    calories = mapSQL["calories"] ?? 0.0;
  }
  Map<String, dynamic> toMapSQL() {
    return {"name": name, "calories": calories};
  }
}
