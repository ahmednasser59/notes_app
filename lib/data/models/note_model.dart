import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String subTitle;

  @HiveField(2)
  final String date;

  @HiveField(3)
  int color;

  @HiveField(4)
  bool isPrivate;

  @HiveField(5)
  List<String> tags;

  @HiveField(6)
  List<String> checklist; // Format: "isChecked:itemText" (e.g. "true:Buy milk")

  NoteModel({
    required this.title,
    required this.subTitle,
    required this.date,
    required this.color,
    this.isPrivate = false,
    this.tags = const [],
    this.checklist = const [],
  });
}
