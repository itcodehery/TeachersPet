import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'form_builder_provider.dart';
import 'header_template_model.dart';
import 'header_template_service.dart';

/// Dialog for editing form details including name and header content values
class FormDetailsDialog extends ConsumerStatefulWidget {
  const FormDetailsDialog({super.key});

  @override
  ConsumerState<FormDetailsDialog> createState() => _FormDetailsDialogState();
}

class _FormDetailsDialogState extends ConsumerState<FormDetailsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _instituteController;
  late TextEditingController _examTitleController;
  late TextEditingController _subtitleController;
  late TextEditingController _dateController;
  late TextEditingController _durationController;
  late TextEditingController _maxMarksController;
  late TextEditingController _subjectController;
  late TextEditingController _classController;

  HeaderTemplate? _selectedHeader;
  Map<String, TextEditingController> _customFieldControllers = {};

  @override
  void initState() {
    super.initState();
    final form = ref.read(formBuilderProvider);

    _nameController = TextEditingController(text: form.name);
    _instituteController = TextEditingController(
      text: form.instituteName ?? '',
    );
    _examTitleController = TextEditingController(text: form.examTitle ?? '');
    _subtitleController = TextEditingController(text: form.subtitle ?? '');
    _dateController = TextEditingController(text: form.date ?? '');
    _durationController = TextEditingController(text: form.duration ?? '');
    _maxMarksController = TextEditingController(text: form.maxMarks ?? '');
    _subjectController = TextEditingController(text: form.subject ?? '');
    _classController = TextEditingController(text: form.className ?? '');

    _loadHeader();
  }

  Future<void> _loadHeader() async {
    final form = ref.read(formBuilderProvider);
    final headerId = form.selectedHeaderId ?? 'prebuilt_simple';
    final header = await HeaderTemplateService.getHeaderById(headerId);
    if (mounted) {
      setState(() {
        _selectedHeader = header;
        // Initialize custom field controllers
        if (header != null) {
          for (final field in header.customFields) {
            _customFieldControllers[field] = TextEditingController(
              text: form.customFieldValues[field] ?? '',
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instituteController.dispose();
    _examTitleController.dispose();
    _subtitleController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    _maxMarksController.dispose();
    _subjectController.dispose();
    _classController.dispose();
    for (final controller in _customFieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    final customValues = <String, String>{};
    for (final entry in _customFieldControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        customValues[entry.key] = entry.value.text;
      }
    }

    final notifier = ref.read(formBuilderProvider.notifier);
    notifier.updateFormDetails(
      name: _nameController.text,
      instituteName: _instituteController.text.isEmpty
          ? null
          : _instituteController.text,
      examTitle: _examTitleController.text.isEmpty
          ? null
          : _examTitleController.text,
      subtitle: _subtitleController.text.isEmpty
          ? null
          : _subtitleController.text,
      date: _dateController.text.isEmpty ? null : _dateController.text,
      duration: _durationController.text.isEmpty
          ? null
          : _durationController.text,
      maxMarks: _maxMarksController.text.isEmpty
          ? null
          : _maxMarksController.text,
      subject: _subjectController.text.isEmpty ? null : _subjectController.text,
      className: _classController.text.isEmpty ? null : _classController.text,
      customFieldValues: customValues,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_document,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Form Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Flexible(
              child: _selectedHeader == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Form name (always visible)
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Form Name *',
                              hintText: 'e.g., Math Mid-Term 2025',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Header Content',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Fill in the values for your selected header template',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(150),
                                ),
                          ),
                          const SizedBox(height: 16),
                          // Show fields based on header template
                          if (_selectedHeader!.instituteName != null)
                            _buildField(
                              _instituteController,
                              'Institution Name',
                              'e.g., ABC High School',
                            ),
                          if (_selectedHeader!.subtitle != null)
                            _buildField(
                              _subtitleController,
                              'Subtitle',
                              'e.g., Internal Assessment',
                            ),
                          if (_selectedHeader!.examTitle != null)
                            _buildField(
                              _examTitleController,
                              'Exam Title',
                              'e.g., Mid-Term Examination',
                            ),
                          if (_selectedHeader!.showDate)
                            _buildField(
                              _dateController,
                              'Date',
                              'e.g., 24/01/2026',
                            ),
                          if (_selectedHeader!.showDuration)
                            _buildField(
                              _durationController,
                              'Duration',
                              'e.g., 3 Hours',
                            ),
                          if (_selectedHeader!.showMaxMarks)
                            _buildField(
                              _maxMarksController,
                              'Max Marks',
                              'e.g., 100',
                            ),
                          if (_selectedHeader!.showSubjectField)
                            _buildField(
                              _subjectController,
                              'Subject',
                              'e.g., Mathematics',
                            ),
                          if (_selectedHeader!.showClassField)
                            _buildField(
                              _classController,
                              'Class',
                              'e.g., 10th Grade',
                            ),
                          // Custom fields
                          ..._selectedHeader!.customFields.map((field) {
                            return _buildField(
                              _customFieldControllers[field]!,
                              field,
                              'Enter $field',
                            );
                          }),
                          if (_selectedHeader!.id == 'prebuilt_blank')
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'The "Blank" header template has no content fields.',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(150),
                                ),
                              ),
                            ),
                          // Show helpful message when no fields visible
                          if (_selectedHeader!.instituteName == null &&
                              _selectedHeader!.subtitle == null &&
                              _selectedHeader!.examTitle == null &&
                              !_selectedHeader!.showDate &&
                              !_selectedHeader!.showDuration &&
                              !_selectedHeader!.showMaxMarks &&
                              !_selectedHeader!.showSubjectField &&
                              !_selectedHeader!.showClassField &&
                              _selectedHeader!.customFields.isEmpty &&
                              _selectedHeader!.id != 'prebuilt_blank')
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'This header template has no content fields. Choose a different template or create a custom one.',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(150),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            const Divider(height: 1),
            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
