import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeetcoach/core/theme/app_colors.dart';
import 'package:yeetcoach/core/theme/app_theme.dart';
import 'package:yeetcoach/core/theme/app_spacing.dart';
import '../controllers/client_detail_controller.dart';
import 'client_detail_section_shimmers.dart';
import 'client_section.dart';

TextTheme get _textTheme => AppTheme.light.textTheme;

/// Private coach note from coaches/{coachUid}/client_notes/{clientUid}, edited inline.
class CoachNotesCard extends GetView<ClientDetailController> {
  const CoachNotesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSectionLoading(ClientDetailSection.relationship) ||
          controller.isSectionLoading(ClientDetailSection.notes)) {
        return const CoachNotesShimmer();
      }
      if (controller.relationship.value == null) {
        return ClientCard(
          child: Text(
            'Notes are available once this client has an active training relationship with you.',
            style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
          ),
        );
      }
      return controller.isEditingNotes.value
          ? _buildEditor()
          : _buildNote(controller.coachNotes.value);
    });
  }

  Widget _buildNote(String note) {
    final hasNote = note.trim().isNotEmpty;
    return ClientCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                hasNote ? note : 'Add a private note about this client…',
                style: _textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 1.4,
                  color: hasNote ? AppColors.onSurface : AppColors.subtle,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: hasNote ? 'Edit note' : 'Add note',
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            onPressed: controller.startEditingNotes,
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    final isSaving = controller.isSavingNotes.value;
    return ClientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.notesController,
            autofocus: true,
            enabled: !isSaving,
            minLines: 3,
            maxLines: 8,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            style: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Add a private note about this client…',
              hintStyle: _textTheme.bodyMedium?.copyWith(fontSize: 14, color: AppColors.subtle),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.all(AppSpacing.smd),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isSaving ? null : controller.cancelEditingNotes,
                style: TextButton.styleFrom(foregroundColor: AppColors.subtle),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: isSaving ? null : controller.saveNotes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
