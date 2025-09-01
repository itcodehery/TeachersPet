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
  String? _title;
  QuestionType _type = QuestionType.shortAnswer;
  List<String> _options = [];
  String _optionInput = '';
  List<MapEntry<String, String>> _pairs = [];
  String _pairKey = '';
  String _pairValue = '';
  String? _marks;
  String? _sectionTitle;
  List<String> _subQuestions = [];
  String _subQuestionInput = '';
  String? _editingId;
  List<String> _imagePaths = [];
  int _rows = 2;
  int _cols = 2;
  List<List<TextEditingController>> _tableControllers = [];

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuestion;
    _titleController = TextEditingController(text: q?.title ?? '');
    if (q != null) {
      _editingId = q.id;
      _type = q.type;
      _title = q.title;
      _options = q.options ?? [];
      _marks = q.marks;
      _sectionTitle = q.sectionTitle;
      _imagePaths = q.imagePaths ?? [];
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
    }
    if (widget.initialQuestion == null) {
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
        _imagePaths.addAll(pickedFiles.map((file) => file.path));
      });
    }
  }

  Widget _buildImagePreviews() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _imagePaths.map((path) {
        return Stack(
          children: [
            Image.file(File(path), width: 100, height: 100, fit: BoxFit.cover),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _imagePaths.remove(path);
                  });
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  child: Icon(Icons.close, color: Theme.of(context).colorScheme.surface, size: 16),
                ),
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
                decoration: const InputDecoration(
                  hintText: 'Enter subquestion',
                ),
                onChanged: (val) => _subQuestionInput = val,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_subQuestionInput.trim().isNotEmpty) {
                  setState(() {
                    _subQuestions.add(_subQuestionInput.trim());
                    _subQuestionInput = '';
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
                decoration: const InputDecoration(hintText: 'Enter option'),
                onChanged: (val) => _optionInput = val,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_optionInput.trim().isNotEmpty) {
                  setState(() {
                    _options.add(_optionInput.trim());
                    _optionInput = '';
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
                decoration: const InputDecoration(hintText: 'Key'),
                onChanged: (val) => _pairKey = val,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(hintText: 'Value'),
                onChanged: (val) => _pairValue = val,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_pairKey.trim().isNotEmpty &&
                    _pairValue.trim().isNotEmpty) {
                  setState(() {
                    _pairs.add(MapEntry(_pairKey.trim(), _pairValue.trim()));
                    _pairKey = '';
                    _pairValue = '';
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
        return 'Grouped Question with Image';
      case QuestionType.mainDivider:
        return 'Main Divider';
      case QuestionType.table:
        return 'Table';
    }
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.initialQuestion == null ? 'Add Node' : 'Edit Node',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<QuestionType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Question Type'),
                items: QuestionType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(getTypeNameFromQuestion(type)),
                      ),
                    )
                    .toList(),
                onChanged: (type) =>
                    setState(() => _type = type ?? QuestionType.shortAnswer),
              ),
              const SizedBox(height: 16),
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
                          _titleController.selection =
                              TextSelection.fromPosition(
                                TextPosition(
                                  offset: selection.start + fraction.length,
                                ),
                              );
                        }
                      },
                    ),
                  ),
                  validator:
                      (_type != QuestionType.groupedQuestions &&
                          _type != QuestionType.groupedQuestionWithImage)
                      ? (val) => val == null || val.trim().isEmpty
                            ? 'Required'
                            : null
                      : null,
                  onChanged: (val) => setState(() => _title = val),
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
                              : _titleController.text, // Use controller text
                          type: _type,
                          options: _type == QuestionType.multipleChoice
                              ? _options
                              : _type == QuestionType.matchTheFollowing
                              ? _pairs
                                    .map((e) => '${e.key}=${e.value}')
                                    .toList()
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
                                  _type ==
                                      QuestionType.groupedQuestionWithImage)
                              ? _subQuestions
                                    .map(
                                      (subQ) => Question(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        title: subQ,
                                        type: QuestionType.shortAnswer,
                                      ),
                                    )
                                    .toList()
                              : null,
                          imagePaths:
                              (_type == QuestionType.questionWithImage ||
                                  _type ==
                                      QuestionType.groupedQuestionWithImage)
                              ? _imagePaths
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
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
