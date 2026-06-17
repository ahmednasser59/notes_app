import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:notes_app/constants.dart';
import 'package:notes_app/models/note_model.dart';

import '../../constants.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit() : super(NotesInitial());

  List<NoteModel>? notes;
  fetchAllNotes() {
    var notesBox = Hive.box<NoteModel>(kNotesBox);

    notes = notesBox.values.toList();
    emit(NotesSuccess());
  }

  void searchNotes(String query) {
    var notesBox = Hive.box<NoteModel>(kNotesBox);
    notes = notesBox.values.where((note) {
      return note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.subTitle.toLowerCase().contains(query.toLowerCase());
    }).toList();
    emit(NotesSuccess());
  }
}
