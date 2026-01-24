import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'header_template_model.dart';
import 'header_template_service.dart';
import 'header_editor_dialog.dart';
import 'form_builder_provider.dart';

/// Bottom sheet for selecting or creating header templates
class HeaderSelectorSheet extends ConsumerStatefulWidget {
  const HeaderSelectorSheet({super.key});

  @override
  ConsumerState<HeaderSelectorSheet> createState() =>
      _HeaderSelectorSheetState();
}

class _HeaderSelectorSheetState extends ConsumerState<HeaderSelectorSheet> {
  List<HeaderTemplate> _prebuiltHeaders = [];
  List<HeaderTemplate> _customHeaders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHeaders();
  }

  Future<void> _loadHeaders() async {
    setState(() => _isLoading = true);
    _prebuiltHeaders = HeaderTemplateService.getPrebuiltHeaders();
    _customHeaders = await HeaderTemplateService.loadCustomHeaders();
    setState(() => _isLoading = false);
  }

  void _selectHeader(HeaderTemplate header) {
    ref.read(formBuilderProvider.notifier).updateSelectedHeader(header.id);
    context.pop();
  }

  Future<void> _createCustomHeader() async {
    final result = await showDialog<HeaderTemplate>(
      context: context,
      builder: (context) => const HeaderEditorDialog(),
    );
    if (result != null) {
      await HeaderTemplateService.saveCustomHeader(result);
      await _loadHeaders();
      if (mounted) {
        ref.read(formBuilderProvider.notifier).updateSelectedHeader(result.id);
      }
    }
  }

  Future<void> _editCustomHeader(HeaderTemplate header) async {
    final result = await showDialog<HeaderTemplate>(
      context: context,
      builder: (context) => HeaderEditorDialog(existingTemplate: header),
    );
    if (result != null) {
      await HeaderTemplateService.saveCustomHeader(result);
      await _loadHeaders();
      if (mounted) {
        ref.read(formBuilderProvider.notifier).updateSelectedHeader(result.id);
      }
    }
  }

  Future<void> _deleteCustomHeader(HeaderTemplate header) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Header'),
        content: Text('Are you sure you want to delete "${header.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await HeaderTemplateService.deleteCustomHeader(header.id);
      await _loadHeaders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(formBuilderProvider);
    final selectedHeaderId = form.selectedHeaderId ?? 'prebuilt_simple';

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Header Template',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prebuilt templates section
                        Text(
                          'Prebuilt Templates',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _prebuiltHeaders.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final header = _prebuiltHeaders[index];
                              final isSelected = header.id == selectedHeaderId;
                              return _buildHeaderCard(
                                header,
                                isSelected: isSelected,
                                onTap: () => _selectHeader(header),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Custom templates section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Custom Headers',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: _createCustomHeader,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Create New'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_customHeaders.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withAlpha(50),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No custom headers yet',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create your own header template',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface.withAlpha(150),
                                      ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            height: 160,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _customHeaders.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final header = _customHeaders[index];
                                final isSelected =
                                    header.id == selectedHeaderId;
                                return _buildHeaderCard(
                                  header,
                                  isSelected: isSelected,
                                  onTap: () => _selectHeader(header),
                                  onEdit: () => _editCustomHeader(header),
                                  onDelete: () => _deleteCustomHeader(header),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    HeaderTemplate header, {
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withAlpha(50),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(30),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                  border: header.showBorder
                      ? Border.all(color: Colors.black, width: 1)
                      : null,
                ),
                child: _buildHeaderPreview(header),
              ),
            ),
            // Footer with name and actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withAlpha(20)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(11),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      header.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.edit,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.delete,
                          size: 14,
                          color: Theme.of(context).colorScheme.error,
                        ),
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

  Widget _buildHeaderPreview(HeaderTemplate header) {
    // Build a mini preview of the header
    if (header.id == 'prebuilt_blank') {
      return Center(
        child: Text(
          'No Header',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[400],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: header.titleAlignment == HeaderAlignment.left
          ? CrossAxisAlignment.start
          : header.titleAlignment == HeaderAlignment.right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.center,
      children: [
        if (header.instituteName != null && header.instituteName!.isNotEmpty)
          Text(
            header.instituteName!,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (header.subtitle != null && header.subtitle!.isNotEmpty)
          Text(
            header.subtitle!,
            style: TextStyle(fontSize: 6, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        if (header.examTitle != null && header.examTitle!.isNotEmpty)
          Text(
            header.examTitle!,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        const SizedBox(height: 4),
        if (header.showDate || header.showDuration || header.showMaxMarks)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (header.showDate)
                Text(
                  'Date: ___',
                  style: TextStyle(fontSize: 5, color: Colors.grey[600]),
                ),
              if (header.showDuration)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Time: ___',
                    style: TextStyle(fontSize: 5, color: Colors.grey[600]),
                  ),
                ),
            ],
          ),
        if (header.showSubjectField || header.showClassField)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (header.showSubjectField)
                  Text(
                    'Subject: ___',
                    style: TextStyle(fontSize: 5, color: Colors.grey[600]),
                  ),
                if (header.showClassField)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Class: ___',
                      style: TextStyle(fontSize: 5, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        // Custom fields
        if (header.customFields.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Wrap(
              spacing: 8,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              children: header.customFields.take(3).map((field) {
                return Text(
                  '$field: ___',
                  style: TextStyle(fontSize: 5, color: Colors.grey[600]),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
