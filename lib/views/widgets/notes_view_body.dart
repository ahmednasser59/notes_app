import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/notes_cubit/notes_cubit.dart';
import 'custom_app_bar.dart';
import 'note_item.dart';
import 'notes_list_view.dart';

class NotesViewBody extends StatefulWidget {
  const NotesViewBody({Key? key}) : super(key: key);

  @override
  State<NotesViewBody> createState() => _NotesViewBodyState();
}

class _NotesViewBodyState extends State<NotesViewBody> {
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    BlocProvider.of<NotesCubit>(context).fetchAllNotes();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 50),
          isSearching
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        cursorColor: const Color(0xff6366f1),
                        decoration: InputDecoration(
                          hintText: 'Search notes...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(.05),
                          prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        ),
                        onChanged: (value) {
                          BlocProvider.of<NotesCubit>(context).searchNotes(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            isSearching = false;
                            _searchController.clear();
                          });
                          BlocProvider.of<NotesCubit>(context).fetchAllNotes();
                        },
                      ),
                    ),
                  ],
                )
              : CustomAppBar(
                  title: 'Notes',
                  icon: Icons.search,
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                ),
          const Expanded(child: NotesListView()),
        ],
      ),
    );
  }
}
