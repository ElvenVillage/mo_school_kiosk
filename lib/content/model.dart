class CityModel {
  final String name;
  final double lat;
  final double lon;

  factory CityModel.fromJson(String name, Map<String, dynamic> json) =>
      CityModel(name, json['lat'], json['lon']);

  const CityModel(this.name, this.lat, this.lon);
}

class SchoolModel {
  final String name;
  final String assetName;
  final String id;
  final String city;

  CityModel? coords;

  factory SchoolModel.fromJson(Map<String, dynamic> json) => SchoolModel(
        json['name'],
        json['logo'],
        json['id'],
        json['city'],
      );

  SchoolModel(this.name, this.assetName, this.id, this.city);
}

class StructureModel {
  final String name;
  final String asset;
  final int count;

  static final _digitsRegex = RegExp(r'[^0-9]');

  final List<SchoolModel>? schools;

  factory StructureModel.fromJson(Map<String, dynamic> json) {
    final String title = json['title'];

    final match = _digitsRegex.firstMatch(title)!;

    final count = int.parse(title.substring(0, match.end).trim());

    final schools = (json['schools'] as List)
        .map<SchoolModel>((e) => SchoolModel.fromJson(e))
        .toList();

    return StructureModel(title.replaceAll(count.toString(), "").trim(),
        'assets/schools/${json["logo"]}.png', count, schools);
  }

  const StructureModel(this.name, this.asset, this.count, [this.schools]);
}
