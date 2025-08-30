import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';
import 'package:youseuf_app/ViewModel/Children/upload_note_view_model.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';

class UploadNotesScreen extends StatelessWidget {
  final String childrenId;
  const UploadNotesScreen({Key? key, required this.childrenId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UploadNoteViewModel(),
      child: _UploadNotesScreenBody(childrenId: childrenId),
    );
  }
}

class _UploadNotesScreenBody extends StatelessWidget {
  final String childrenId;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  _UploadNotesScreenBody({Key? key, required this.childrenId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UploadNoteViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightpink,
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: 85,
        leadingWidth: 120,
        elevation: 0,
        leading: const Row(
          children: [
            SizedBox(width: 10),
            BackLeading(),
          ],
        ),
        title: const Text('كتابة ملحوظة',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            // حقل العنوان
            TextField(
              controller: _titleController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                filled: true,
                fillColor: white,
                hintText: "عنوان الملحوظة",
                hintTextDirection: TextDirection.rtl,
                hintStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: grey500,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 13),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                ),
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 15),

            // حقل نص الملحوظة
            TextField(
              controller: _noteController,
              minLines: 15,
              maxLines: null,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(top: 15, right: 13),
                filled: true,
                fillColor: white,
                hintText: "اكتب ملحوظاتك هنا ...",
                hintTextDirection: TextDirection.rtl,
                hintStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: grey500),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                ),
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 15),

            // زر الحفظ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.saveNote(
                          noteTitle: _titleController.text,
                          noteContent: _noteController.text,
                          childrenId: childrenId,
                        );

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("تم حفظ ملحوظتك بنجاح")),
                          );
                          Navigator.pop(context, true);
                        } else if (viewModel.errorMessage.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(viewModel.errorMessage)),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: viewModel.isLoading
                    ? CircularProgressIndicator(color: white)
                    : Text('حفظ',
                        style: TextStyle(fontSize: 18, color: white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
