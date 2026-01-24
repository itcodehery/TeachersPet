import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minty/features/form_builder/fraction_input_dialog.dart';
import './question_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'form_builder_provider.dart';
import 'package:go_router/go_router.dart';

class AddQuestionSheet extends ConsumerStatefulWidget {
  final Question? initialQuestion;
  const AddQuestionSheet({super.key, this.initialQuestion});

  @override
  ConsumerState<AddQuestionSheet> createState() => _AddQuestionSheetState();
}

class _AddQuestionSheetState extends ConsumerState<AddQuestionSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late QuestionType _type;
  List<String> _options = [];
  final _optionController = TextEditingController();
  List<MapEntry<String, String>> _pairs = [];
  final _pairKeyController = TextEditingController();
  final _pairValueController = TextEditingController();
  String? _marks;
  String? _sectionTitle;
  List<String> _subQuestions = [];
  final _subQuestionController = TextEditingController();
  String? _editingId;
  List<QuestionImage> _images = [];
  int _rows = 2;
  int _cols = 2;
  List<List<TextEditingController>> _tableControllers = [];

  // New state for workflow
  bool _isSelectingType = true;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuestion;
    _titleController = TextEditingController(text: q?.title ?? '');

    if (q != null) {
      // Editing mode - skip selection
      _isSelectingType = false;
      _editingId = q.id;
      _type = q.type;
      _options = q.options ?? [];
      _marks = q.marks;
      _sectionTitle = q.sectionTitle;

      // Load images (handling legacy paths if any, via model logic, but here we expect model to have handled it)
      // Actually accessing the deprecated imagePaths might be needed if migration didn't happen yet,
      // but the model's fromJson handles migration. When passing object directly, we should check both.
      if (q.images != null) {
        _images = List.from(q.images!);
      } else if (q.imagePaths != null) {
        _images = q.imagePaths!.map((p) => QuestionImage(path: p)).toList();
      }

      if (q.type == QuestionType.matchTheFollowing && q.options != null) {
        _pairs = q.options!.map((e) {
          final parts = e.split('=');
          return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
        }).toList();
      }
      if ((q.type == QuestionType.groupedQuestions ||
              q.type == QuestionType.groupedQuestionWithImage) &&
          q.subQuestions != null) {
        _subQuestions = q.subQuestions!.map((sq) => sq.title).toList();
      }
      if (q.type == QuestionType.table && q.tableData != null) {
        _rows = q.tableData!.length;
        _cols = q.tableData![0].length;
        _initializeTableControllers();
        for (int i = 0; i < _rows; i++) {
          for (int j = 0; j < _cols; j++) {
            _tableControllers[i][j].text = q.tableData![i][j];
          }
        }
      }
    } else {
      // Adding new - start with selection
      _isSelectingType = true;
      _type =
          QuestionType.shortAnswer; // Default, but won't be used until selected
      _initializeTableControllers();
    }
  }

  void _initializeTableControllers() {
    _tableControllers = List.generate(
      _rows,
      (i) => List.generate(_cols, (j) => TextEditingController()),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _optionController.dispose();
    _pairKeyController.dispose();
    _pairValueController.dispose();
    _subQuestionController.dispose();
    for (var row in _tableControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(
          pickedFiles.map((file) => QuestionImage(path: file.path)),
        );
      });
    }
  }

  Future<void> _editImage(int index) async {
    final image = _images[index];
    final result = await showDialog<QuestionImage?>(
      context: context,
      builder: (context) => _ImageEditorDialog(image: image),
    );

    if (result != null) {
      setState(() {
        _images[index] = result;
      });
    }
  }

  Widget _buildImagePreviews() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _images.asMap().entries.map((entry) {
        final index = entry.key;
        final image = entry.value;
        return Stack(
          children: [
            GestureDetector(
              onTap: () => _editImage(index),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(image.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _images.removeAt(index);
                  });
                },
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.black54,
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 12),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images'),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.image),
          label: const Text('Select Images'),
        ),
        const SizedBox(height: 8),
        if (_images.isNotEmpty) ...[
          const Text(
            'Tap on an image to edit position and size',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
        ],
        _buildImagePreviews(),
      ],
    );
  }

  Widget _buildSubQuestionsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subquestions'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _subQuestionController,
                decoration: const InputDecoration(
                  hintText: 'Enter subquestion',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_subQuestionController.text.trim().isNotEmpty) {
                  setState(() {
                    _subQuestions.add(_subQuestionController.text.trim());
                    _subQuestionController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _subQuestions
              .asMap()
              .entries
              .map(
                (entry) => Chip(
                  label: Text(
                    '${String.fromCharCode(97 + entry.key)}) ${entry.value}',
                  ),
                  onDeleted: () {
                    setState(() {
                      _subQuestions.removeAt(entry.key);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildOptionsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Options'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _optionController,
                decoration: const InputDecoration(hintText: 'Enter option'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_optionController.text.trim().isNotEmpty) {
                  setState(() {
                    _options.add(_optionController.text.trim());
                    _optionController.clear();
                  });
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _options
              .map(
                (opt) => Chip(
                  label: Text(opt),
                  onDeleted: () {
                    setState(() {
                      _options.remove(opt);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPairsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Key-Value Pairs'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _pairKeyController,
                decoration: const InputDecoration(hintText: 'Key'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _pairValueController,
                decoration: const InputDecoration(hintText: 'Value'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_pairKeyController.text.trim().isNotEmpty &&
                    _pairValueController.text.trim().isNotEmpty) {
                  setState(() {
                    _pairs.add(
                      MapEntry(
                        _pairKeyController.text.trim(),
                        _pairValueController.text.trim(),
                      ),
                    );
                    _pairKeyController.clear();
                    _pairValueController.clear();
                  });
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _pairs
              .map(
                (pair) => Chip(
                  label: Text('${pair.key} → ${pair.value}'),
                  onDeleted: () {
                    setState(() {
                      _pairs.remove(pair);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTableInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Table Dimensions'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _rows.toString(),
                decoration: const InputDecoration(labelText: 'Rows'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _rows = int.tryParse(value) ?? 2;
                    _initializeTableControllers();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: _cols.toString(),
                decoration: const InputDecoration(labelText: 'Columns'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _cols = int.tryParse(value) ?? 2;
                    _initializeTableControllers();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Table Data'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_rows, (row) {
              return Row(
                children: List.generate(_cols, (col) {
                  return Container(
                    width: 100,
                    padding: const EdgeInsets.all(4),
                    child: TextFormField(
                      controller: _tableControllers[row][col],
                      decoration: InputDecoration(
                        hintText: 'R${row + 1}, C${col + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }

  String getTypeNameFromQuestion(QuestionType q) {
    switch (q) {
      case QuestionType.shortAnswer:
        return 'Short Answer';
      case QuestionType.longAnswer:
        return 'Long Answer';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.matchTheFollowing:
        return 'Match the Following';
      case QuestionType.sectionDivider:
        return 'Section Divider';
      case QuestionType.groupedQuestions:
        return 'Grouped Question';
      case QuestionType.fillInTheBlanks:
        return 'Fill in the Blanks';
      case QuestionType.questionWithImage:
        return 'Question with Image';
      case QuestionType.groupedQuestionWithImage:
        return 'Grouped + Image';
      case QuestionType.mainDivider:
        return 'Main Divider';
      case QuestionType.table:
        return 'Table';
    }
  }

  IconData getTypeIcon(QuestionType q) {
    switch (q) {
      case QuestionType.shortAnswer:
        return Icons.short_text;
      case QuestionType.longAnswer:
        return Icons.notes;
      case QuestionType.multipleChoice:
        return Icons.list;
      case QuestionType.matchTheFollowing:
        return Icons.compare_arrows;
      case QuestionType.sectionDivider:
        return Icons.horizontal_rule;
      case QuestionType.groupedQuestions:
        return Icons.format_list_numbered;
      case QuestionType.fillInTheBlanks:
        return Icons.more_horiz;
      case QuestionType.questionWithImage:
        return Icons.image;
      case QuestionType.groupedQuestionWithImage:
        return Icons.photo_library;
      case QuestionType.mainDivider:
        return Icons.horizontal_split;
      case QuestionType.table:
        return Icons.table_chart;
    }
  }

  Widget _buildTypeSelectionScreen() {
    final categories = {
      'Text & Input': [
        QuestionType.shortAnswer,
        QuestionType.longAnswer,
        QuestionType.fillInTheBlanks,
      ],
      'Choice & Matching': [
        QuestionType.multipleChoice,
        QuestionType.matchTheFollowing,
      ],
      'Structure': [
        QuestionType.sectionDivider,
        QuestionType.mainDivider,
        QuestionType.table,
      ],
      'Media & Groups': [
        QuestionType.questionWithImage,
        QuestionType.groupedQuestions,
        QuestionType.groupedQuestionWithImage,
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Select Question Type',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: categories.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      final type = entry.value[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _type = type;
                            _isSelectingType = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(getTypeIcon(type), size: 20),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  getTypeNameFromQuestion(type),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFormScreen() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (widget.initialQuestion == null)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _isSelectingType = true),
                ),
              Expanded(
                child: Text(
                  widget.initialQuestion == null
                      ? 'New ${getTypeNameFromQuestion(_type)}'
                      : 'Edit Node',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Question Inputs based on _type
          if (_type == QuestionType.mainDivider)
            TextFormField(
              initialValue: _sectionTitle,
              decoration: const InputDecoration(labelText: 'Main Title'),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
              onChanged: (val) => setState(() => _sectionTitle = val),
            ),
          if (_type == QuestionType.mainDivider)
            TextFormField(
              initialValue: _marks,
              decoration: const InputDecoration(labelText: 'Marks'),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
              onChanged: (val) => setState(() => _marks = val),
            ),
          if (_type != QuestionType.sectionDivider &&
              _type != QuestionType.mainDivider)
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText:
                    (_type == QuestionType.groupedQuestions ||
                        _type == QuestionType.groupedQuestionWithImage)
                    ? 'Main Question Title (optional)'
                    : 'Question Title',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.functions),
                  onPressed: () async {
                    final fraction = await showDialog<String>(
                      context: context,
                      builder: (context) => const FractionInputDialog(),
                    );
                    if (fraction != null) {
                      final currentText = _titleController.text;
                      final selection = _titleController.selection;
                      final newText = currentText.replaceRange(
                        selection.start,
                        selection.end,
                        fraction,
                      );
                      _titleController.text = newText;
                      _titleController.selection = TextSelection.fromPosition(
                        TextPosition(offset: selection.start + fraction.length),
                      );
                    }
                  },
                ),
              ),
              validator:
                  (_type != QuestionType.groupedQuestions &&
                      _type != QuestionType.groupedQuestionWithImage)
                  ? (val) =>
                        val == null || val.trim().isEmpty ? 'Required' : null
                  : null,
            ),
          if (_type == QuestionType.multipleChoice) _buildOptionsInput(),
          if (_type == QuestionType.matchTheFollowing) _buildPairsInput(),
          if (_type == QuestionType.table) _buildTableInput(),
          if (_type == QuestionType.groupedQuestions ||
              _type == QuestionType.groupedQuestionWithImage)
            _buildSubQuestionsInput(),
          if (_type == QuestionType.questionWithImage ||
              _type == QuestionType.groupedQuestionWithImage)
            _buildImagePicker(),
          if (_type == QuestionType.sectionDivider)
            TextFormField(
              initialValue: _sectionTitle,
              decoration: InputDecoration(
                labelText: _type == QuestionType.mainDivider
                    ? 'Main Title'
                    : 'Section Title',
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
              onChanged: (val) => setState(() => _sectionTitle = val),
            ),
          if (_type == QuestionType.sectionDivider)
            TextFormField(
              initialValue: _marks,
              decoration: const InputDecoration(labelText: 'Marks'),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
              onChanged: (val) => setState(() => _marks = val),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    final question = Question(
                      id:
                          _editingId ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      title:
                          (_type == QuestionType.sectionDivider ||
                              _type == QuestionType.mainDivider)
                          ? _sectionTitle ?? ''
                          : _titleController.text,
                      type: _type,
                      options: _type == QuestionType.multipleChoice
                          ? _options
                          : _type == QuestionType.matchTheFollowing
                          ? _pairs.map((e) => '${e.key}=${e.value}').toList()
                          : null,
                      marks:
                          (_type == QuestionType.sectionDivider ||
                              _type == QuestionType.mainDivider)
                          ? _marks
                          : null,
                      sectionTitle:
                          (_type == QuestionType.sectionDivider ||
                              _type == QuestionType.mainDivider)
                          ? _sectionTitle
                          : null,
                      subQuestions:
                          (_type == QuestionType.groupedQuestions ||
                              _type == QuestionType.groupedQuestionWithImage)
                          ? _subQuestions
                                .map(
                                  (subQ) => Question(
                                    id: DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                    title: subQ,
                                    type: QuestionType.shortAnswer,
                                  ),
                                )
                                .toList()
                          : null,
                      images:
                          (_type == QuestionType.questionWithImage ||
                              _type == QuestionType.groupedQuestionWithImage)
                          ? _images
                          : null,
                      tableData: _type == QuestionType.table
                          ? _tableControllers
                                .map(
                                  (row) => row
                                      .map((controller) => controller.text)
                                      .toList(),
                                )
                                .toList()
                          : null,
                    );

                    if (widget.initialQuestion != null) {
                      ref
                          .read(formBuilderProvider.notifier)
                          .updateQuestion(question);
                    } else {
                      ref
                          .read(formBuilderProvider.notifier)
                          .addQuestion(question);
                    }

                    context.pop();
                  }
                },
                child: Text(widget.initialQuestion != null ? 'Save' : 'Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSelectingType
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: _buildTypeSelectionScreen(),
              )
            : SingleChildScrollView(child: _buildFormScreen()),
      ),
    );
  }
}

class _ImageEditorDialog extends StatefulWidget {
  final QuestionImage image;
  const _ImageEditorDialog({required this.image});

  @override
  State<_ImageEditorDialog> createState() => _ImageEditorDialogState();
}

class _ImageEditorDialogState extends State<_ImageEditorDialog> {
  late String _alignment;
  late double _width;

  @override
  void initState() {
    super.initState();
    _alignment = widget.image.alignment;
    _width = widget.image.width;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Image'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alignment'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildAlignButton('Left', 'left', Icons.align_horizontal_left),
                _buildAlignButton(
                  'Center',
                  'center',
                  Icons.align_horizontal_center,
                ),
                _buildAlignButton(
                  'Right',
                  'right',
                  Icons.align_horizontal_right,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Size: ${(_width * 100).toInt()}%'),
            Slider(
              value: _width,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: '${(_width * 100).toInt()}%',
              onChanged: (val) => setState(() => _width = val),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Align(
                  alignment: _alignment == 'left'
                      ? Alignment.centerLeft
                      : _alignment == 'right'
                      ? Alignment.centerRight
                      : Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: _width,
                    child: Image.file(
                      File(widget.image.path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            context.pop(
              widget.image.copyWith(alignment: _alignment, width: _width),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildAlignButton(String label, String value, IconData icon) {
    final isSelected = _alignment == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _alignment = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
