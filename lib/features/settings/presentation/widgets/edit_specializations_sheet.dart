import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/utils/snackbar_helper.dart';
import '../controllers/settings_controller.dart';
import 'settings_sheet.dart';
import 'specialization_chips.dart';

class EditSpecializationsSheet extends StatefulWidget {
  final List<String> initial;

  const EditSpecializationsSheet({super.key, required this.initial});

  @override
  State<EditSpecializationsSheet> createState() => _EditSpecializationsSheetState();
}

class _EditSpecializationsSheetState extends State<EditSpecializationsSheet> {
  late final Set<String> _selected = {...widget.initial};
  final SettingsController _controller = Get.find<SettingsController>();

  void _toggle(String option) {
    setState(() => _selected.contains(option) ? _selected.remove(option) : _selected.add(option));
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      showErrorSnackbar('Select at least one specialization.');
      return;
    }
    if (await _controller.updateSpecializations(_selected.toList()) && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSheet(
      title: 'Specializations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SpecializationChips(selected: _selected, onToggle: _toggle),
          const SizedBox(height: 20),
          Obx(() => SheetSaveButton(
                isBusy: _controller.isSavingProfile.value,
                onPressed: _save,
              )),
        ],
      ),
    );
  }
}
