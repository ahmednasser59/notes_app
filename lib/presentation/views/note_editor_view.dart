import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/core/constants.dart';
import 'package:notes_app/core/utils/feedback_helper.dart';
import 'package:notes_app/data/models/note_model.dart';
import 'package:notes_app/presentation/cubits/auth_cubit/auth_cubit.dart';
import 'package:notes_app/presentation/cubits/notes_cubit/notes_cubit.dart';

class NoteEditorView extends StatefulWidget {
  final NoteModel? note; // Null means create mode

  const NoteEditorView({Key? key, this.note}) : super(key: key);

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late List<String> _tags;
  late List<String> _checklist; // format "isChecked:text"
  late int _selectedColor;
  late bool _isPrivate;

  final TextEditingController _tagInputController = TextEditingController();
  final TextEditingController _checklistItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.subTitle ?? '');
    _tags = List<String>.from(note?.tags ?? []);
    _checklist = List<String>.from(note?.checklist ?? []);
    _selectedColor = note?.color ?? kColors[0].value;
    _isPrivate = note?.isPrivate ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    _checklistItemController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty) {
      FeedbackHelper.showError(context, "Note title cannot be empty");
      return;
    }

    final dateStr = widget.note?.date ?? DateFormat('dd-MM-yyyy').format(DateTime.now());

    if (widget.note == null) {
      // Create mode
      final newNote = NoteModel(
        title: _titleController.text,
        subTitle: _contentController.text,
        date: dateStr,
        color: _selectedColor,
        isPrivate: _isPrivate,
        tags: _tags,
        checklist: _checklist,
      );
      var notesBox = BlocProvider.of<NotesCubit>(context);
      notesBox.searchNotes(''); // Clear search query
      final addCubit = BlocProvider.of<NotesCubit>(context);
      // Save directly to Hive box for simplicity
      final box = Hive.box<NoteModel>(kNotesBox);
      box.add(newNote);
      addCubit.fetchAllNotes();
      FeedbackHelper.showSuccess(context, "Note Added");
    } else {
      // Edit mode
      widget.note!.title = _titleController.text;
      widget.note!.subTitle = _contentController.text;
      widget.note!.color = _selectedColor;
      widget.note!.isPrivate = _isPrivate;
      widget.note!.tags = _tags;
      widget.note!.checklist = _checklist;
      widget.note!.save();
      BlocProvider.of<NotesCubit>(context).fetchAllNotes();
      FeedbackHelper.showSuccess(context, "Note Updated");
    }
    Navigator.of(context).pop();
  }

  void _addTag() {
    final text = _tagInputController.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagInputController.clear();
      });
    }
  }

  void _addChecklistItem() {
    final text = _checklistItemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _checklist.add("false:$text");
        _checklistItemController.clear();
      });
    }
  }

  void _toggleChecklistItem(int index) {
    setState(() {
      final parts = _checklist[index].split(':');
      if (parts.length >= 2) {
        final isChecked = parts[0] == 'true';
        final text = parts.sublist(1).join(':');
        _checklist[index] = "${!isChecked}:$text";
      }
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklist.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121214),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPrivate ? Icons.lock : Icons.lock_open,
              color: _isPrivate ? kPrimaryColor : Colors.white60,
            ),
            onPressed: () async {
              if (!_isPrivate) {
                // Try activating biometrics to lock
                final authCubit = BlocProvider.of<AuthCubit>(context);
                final success = await authCubit.authenticate();
                if (success) {
                  setState(() {
                    _isPrivate = true;
                  });
                  FeedbackHelper.showInfo(context, "Note locked via Biometrics");
                }
              } else {
                setState(() {
                  _isPrivate = false;
                });
                FeedbackHelper.showInfo(context, "Note unlocked");
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.check, color: kPrimaryColor, size: 28),
            onPressed: _saveNote,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            // Tags section
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._tags.map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.black)),
                      backgroundColor: kPrimaryColor.withOpacity(0.8),
                      deleteIcon: const Icon(Icons.close, size: 14, color: Colors.black),
                      onDeleted: () {
                        setState(() {
                          _tags.remove(tag);
                        });
                      },
                    )),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16, color: kPrimaryColor),
                  label: const Text('Add Tag', style: TextStyle(color: kPrimaryColor, fontSize: 12)),
                  backgroundColor: kPrimaryColor.withOpacity(0.08),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xff1e1e24),
                        title: const Text('Add Tag', style: TextStyle(color: Colors.white)),
                        content: TextField(
                          controller: _tagInputController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Enter tag...',
                            hintStyle: TextStyle(color: Colors.white30),
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text('Add', style: TextStyle(color: kPrimaryColor)),
                            onPressed: () {
                              _addTag();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Main editor subtitle text
            TextField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.85), height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Type something...',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            // Checklist Section
            const Text(
              'Checklist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _checklist.length,
              itemBuilder: (context, index) {
                final parts = _checklist[index].split(':');
                final isChecked = parts[0] == 'true';
                final text = parts.sublist(1).join(':');

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Checkbox(
                    value: isChecked,
                    activeColor: kPrimaryColor,
                    onChanged: (val) => _toggleChecklistItem(index),
                  ),
                  title: Text(
                    text,
                    style: TextStyle(
                      color: isChecked ? Colors.white30 : Colors.white,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                    onPressed: () => _removeChecklistItem(index),
                  ),
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checklistItemController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Add checklist item...',
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addChecklistItem(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: kPrimaryColor),
                  onPressed: _addChecklistItem,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Color picker
            const Text(
              'Color Accent',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: kColors.length,
                itemBuilder: (context, index) {
                  final color = kColors[index];
                  final isSelected = _selectedColor == color.value;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color.value;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
