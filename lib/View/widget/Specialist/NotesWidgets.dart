import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/widget/Specialist/upload_notes_screen.dart';
import 'package:youseuf_app/ViewModel/children/NotesViewModel.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';

class NotesWidgets extends StatefulWidget {
  final String childrenId;
  const NotesWidgets({Key? key, required this.childrenId}) : super(key: key);

  @override
  State<NotesWidgets> createState() => _NotesWidgetsState();
}

class _NotesWidgetsState extends State<NotesWidgets> {
  late NotesViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = NotesViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchNotes(widget.childrenId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<NotesViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UploadNotesScreen(childrenId: widget.childrenId),
                      ),
                    );
                    if (result == true) {
                      await vm.fetchNotes(widget.childrenId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    'إضافة ملحوظة +',
                    style: TextStyle(
                      color: white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: vm.isLoading
                    ?  Center(child: CircularProgressIndicator(color: blue))
                    : vm.errorMessage != null 
                    ? Center(child: Text(vm.errorMessage!))
                    : vm.notes.isEmpty
                        ? const Center(child: Text('لا توجد ملاحظات متاحة'))
                        : ListView.builder(
                            itemCount: vm.notes.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              final note = vm.notes[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 30,
                                  decoration: BoxDecoration(
                                    color: white,
                                    border:
                                        Border.all(color: grey500),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 17),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          note.title ?? 'بدون عنوان',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          note.content ?? 'لا توجد محتويات',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            height: 2.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
