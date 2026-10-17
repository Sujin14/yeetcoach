import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import 'settings_sheet.dart';

class EditNameSheet extends StatefulWidget {
  final String initialName;

  const EditNameSheet({super.key, required this.initialName});

  @override
  State<EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<EditNameSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  final SettingsController _controller = Get.find<SettingsController>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (await _controller.updateName(_nameController.text) && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSheet(
      title: 'Edit name',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsTextField(
              controller: _nameController,
              label: 'Full name',
              autofocus: true,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              validator: validateCoachName,
            ),
            Obx(() => SheetSaveButton(
                  isBusy: _controller.isSavingProfile.value,
                  onPressed: _save,
                )),
          ],
        ),
      ),
    );
  }
}

String? validateCoachName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Enter your name';
  if (name.length < 2) return 'Name is too short';
  return null;
}
