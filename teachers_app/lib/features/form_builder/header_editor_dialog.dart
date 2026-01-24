import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'header_template_model.dart';

/// Dialog for creating or editing custom header templates
class HeaderEditorDialog extends StatefulWidget {
  final HeaderTemplate? existingTemplate;

  const HeaderEditorDialog({super.key, this.existingTemplate});

  @override
  State<HeaderEditorDialog> createState() => _HeaderEditorDialogState();
}

class _HeaderEditorDialogState extends State<HeaderEditorDialog> {
  late TextEditingController _nameController;
  final TextEditingController _customFieldController = TextEditingController();

  late bool _showInstituteName;
  late bool _showSubtitle;
  late bool _showExamTitle;
  late bool _showDate;
  late bool _showDuration;
  late bool _showMaxMarks;
  late bool _showSubjectField;
  late bool _showClassField;
  late HeaderAlignment _alignment;
  late bool _showBorder;
  late List<String> _customFields;

  @override
  void initState() {
    super.initState();
    final template = widget.existingTemplate;

    _nameController = TextEditingController(text: template?.name ?? '');

    _showInstituteName = template?.instituteName != null;
    _showSubtitle = template?.subtitle != null;
    _showExamTitle = template?.examTitle != null;
    _showDate = template?.showDate ?? false;
    _showDuration = template?.showDuration ?? false;
    _showMaxMarks = template?.showMaxMarks ?? false;
    _showSubjectField = template?.showSubjectField ?? false;
    _showClassField = template?.showClassField ?? false;
    _alignment = template?.titleAlignment ?? HeaderAlignment.center;
    _showBorder = template?.showBorder ?? false;
    _customFields = List<String>.from(template?.customFields ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customFieldController.dispose();
    super.dispose();
  }

  HeaderTemplate _buildTemplate() {
    return HeaderTemplate(
      id: widget.existingTemplate?.id ?? const Uuid().v4(),
      name: _nameController.text.isEmpty
          ? 'Custom Header'
          : _nameController.text,
      isCustom: true,
      instituteName: _showInstituteName ? 'Institution Name' : null,
      subtitle: _showSubtitle ? 'Subtitle' : null,
      examTitle: _showExamTitle ? 'Exam Title' : null,
      showDate: _showDate,
      showDuration: _showDuration,
      showMaxMarks: _showMaxMarks,
      showSubjectField: _showSubjectField,
      showClassField: _showClassField,
      titleAlignment: _alignment,
      showBorder: _showBorder,
      customFields: _customFields,
    );
  }

  void _addCustomField() {
    final fieldName = _customFieldController.text.trim();
    if (fieldName.isNotEmpty && !_customFields.contains(fieldName)) {
      setState(() {
        _customFields.add(fieldName);
        _customFieldController.clear();
      });
    }
  }

  void _removeCustomField(String field) {
    setState(() => _customFields.remove(field));
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
                    widget.existingTemplate != null ? Icons.edit : Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.existingTemplate != null
                        ? 'Edit Header'
                        : 'Create Custom Header',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Template name
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Template Name *',
                        hintText: 'e.g., My School Header',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Info about content
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This template defines which fields to show. The actual content (institution name, exam title, etc.) is set per-form via "Edit Form Details".',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Toggle options
                    Text(
                      'Display Fields',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildToggleChip(
                          'Institution Name',
                          _showInstituteName,
                          (v) => setState(() => _showInstituteName = v),
                        ),
                        _buildToggleChip(
                          'Subtitle',
                          _showSubtitle,
                          (v) => setState(() => _showSubtitle = v),
                        ),
                        _buildToggleChip(
                          'Exam Title',
                          _showExamTitle,
                          (v) => setState(() => _showExamTitle = v),
                        ),
                        _buildToggleChip(
                          'Date',
                          _showDate,
                          (v) => setState(() => _showDate = v),
                        ),
                        _buildToggleChip(
                          'Duration',
                          _showDuration,
                          (v) => setState(() => _showDuration = v),
                        ),
                        _buildToggleChip(
                          'Max Marks',
                          _showMaxMarks,
                          (v) => setState(() => _showMaxMarks = v),
                        ),
                        _buildToggleChip(
                          'Subject',
                          _showSubjectField,
                          (v) => setState(() => _showSubjectField = v),
                        ),
                        _buildToggleChip(
                          'Class',
                          _showClassField,
                          (v) => setState(() => _showClassField = v),
                        ),
                        _buildToggleChip(
                          'Border',
                          _showBorder,
                          (v) => setState(() => _showBorder = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Alignment
                    Text(
                      'Alignment',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<HeaderAlignment>(
                      segments: const [
                        ButtonSegment(
                          value: HeaderAlignment.left,
                          label: Text('Left'),
                          icon: Icon(Icons.format_align_left, size: 18),
                        ),
                        ButtonSegment(
                          value: HeaderAlignment.center,
                          label: Text('Center'),
                          icon: Icon(Icons.format_align_center, size: 18),
                        ),
                        ButtonSegment(
                          value: HeaderAlignment.right,
                          label: Text('Right'),
                          icon: Icon(Icons.format_align_right, size: 18),
                        ),
                      ],
                      selected: {_alignment},
                      onSelectionChanged: (selection) {
                        setState(() => _alignment = selection.first);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Custom fields section
                    Text(
                      'Custom Display Fields',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add fields like Reg No, QP Code, Set Number, etc.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customFieldController,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Reg No',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _addCustomField(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addCustomField,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    if (_customFields.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _customFields.map((field) {
                          return Chip(
                            label: Text(field),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeCustomField(field),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Preview
                    Text(
                      'Preview',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: _showBorder
                            ? Border.all(color: Colors.black, width: 1)
                            : Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: _buildPreview(),
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
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a template name'),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context, _buildTemplate());
                    },
                    child: Text(
                      widget.existingTemplate != null ? 'Save' : 'Create',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
    );
  }

  Widget _buildPreview() {
    final template = _buildTemplate();
    final CrossAxisAlignment crossAlign =
        template.titleAlignment == HeaderAlignment.left
        ? CrossAxisAlignment.start
        : template.titleAlignment == HeaderAlignment.right
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        if (template.instituteName != null &&
            template.instituteName!.isNotEmpty)
          Text(
            template.instituteName!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        if (template.subtitle != null && template.subtitle!.isNotEmpty)
          Text(
            template.subtitle!,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        if (template.examTitle != null && template.examTitle!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              template.examTitle!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        if (template.showDate || template.showDuration || template.showMaxMarks)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: crossAlign == CrossAxisAlignment.center
                  ? MainAxisAlignment.center
                  : crossAlign == CrossAxisAlignment.end
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (template.showDate)
                  const Text(
                    'Date: ________',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                if (template.showDuration)
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Duration: ________',
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
                if (template.showMaxMarks)
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Max Marks: ________',
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        if (template.showSubjectField || template.showClassField)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: crossAlign == CrossAxisAlignment.center
                  ? MainAxisAlignment.center
                  : crossAlign == CrossAxisAlignment.end
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (template.showSubjectField)
                  const Text(
                    'Subject: ________',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                if (template.showClassField)
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Class: ________',
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        // Custom fields
        if (template.customFields.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 16,
              runSpacing: 4,
              alignment: crossAlign == CrossAxisAlignment.center
                  ? WrapAlignment.center
                  : crossAlign == CrossAxisAlignment.end
                  ? WrapAlignment.end
                  : WrapAlignment.start,
              children: template.customFields.map((field) {
                return Text(
                  '$field: ________',
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                );
              }).toList(),
            ),
          ),
        if (template.instituteName == null &&
            template.subtitle == null &&
            template.examTitle == null &&
            !template.showDate &&
            !template.showDuration &&
            !template.showMaxMarks &&
            !template.showSubjectField &&
            !template.showClassField &&
            template.customFields.isEmpty)
          Text(
            'Empty header (no content)',
            style: TextStyle(
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
          ),
      ],
    );
  }
}
