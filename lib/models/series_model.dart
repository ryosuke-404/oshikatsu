import 'package:hive/hive.dart';

part 'series_model.g.dart';

@HiveType(typeId: 120)
class Series extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int order;

  Series({required this.name, required this.order});
}
