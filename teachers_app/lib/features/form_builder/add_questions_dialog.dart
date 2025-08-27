import 'package:flutter/material.dart';
import 'package:teachers_app/features/form_builder/form_builder_event.dart';
import './question_model.dart';
import './form_builder_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// AddQuestionDialog and its state class
class AddQuestionDialog extends StatefulWidget {
  final Question? initialQuestion;
  const AddQuestionDialog({super.key, this.initialQuestion});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  QuestionType _type = QuestionType.shortAnswer;
  List<String> _options = [];
  String _optionInput = '';
  // For match the following
  List<MapEntry<String, String>> _pairs = [];
  String _pairKey = '';
  String _pairValue = '';
  int? _marks;
  String? _sectionTitle;

  List<String> _subQuestions = [];
  String _subQuestionInput = '';
  String? _editingId;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuestion;
    if (q != null) {
      _editingId = q.id;
      _type = q.type;
      _title = q.title;
      _options = q.options ?? [];
      _marks = q.marks;
      _sectionTitle = q.sectionTitle;
      if (q.type == QuestionType.matchTheFollowing && q.options != null) {
        _pairs = q.options!.map((e) {
          final parts = e.split('=');
          return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
        }).toList();
      }
      if (q.type == QuestionType.groupedQuestions && q.subQuestions != null) {
        _subQuestions = q.subQuestions!.map((sq) => sq.title).toList();
      }
    }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.limeAccent, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                color: Colors.limeAccent.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Text(
                  _type == QuestionType.sectionDivider
                      ? 'Add Section Divider'
                      : _type == QuestionType.matchTheFollowing
                      ? 'Add Match the Following'
                      : _type == QuestionType.groupedQuestions
                      ? 'Add Grouped Question'
                      : 'Add Question',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.lime,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<QuestionType>(
                          initialValue: _type,
                          decoration: const InputDecoration(
                            labelText: 'Question Type',
                          ),
                          items: QuestionType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(getTypeNameFromQuestion(type)),
                                ),
                              )
                              .toList(),
                          onChanged: (type) => setState(
                            () => _type = type ?? QuestionType.shortAnswer,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_type == QuestionType.groupedQuestions)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Main Question Title (optional)',
                            ),
                            onChanged: (val) => setState(() => _title = val),
                          ),
                        if (_type == QuestionType.groupedQuestions)
                          _buildSubQuestionsInput(),
                        if (_type != QuestionType.sectionDivider &&
                            _type != QuestionType.matchTheFollowing &&
                            _type != QuestionType.groupedQuestions)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Question Title',
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Required'
                                : null,
                            onChanged: (val) => setState(() => _title = val),
                          ),
                        if (_type == QuestionType.multipleChoice)
                          _buildOptionsInput(),
                        if (_type == QuestionType.matchTheFollowing)
                          _buildPairsInput(),
                        if (_type == QuestionType.sectionDivider)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Section Title',
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Required'
                                : null,
                            onChanged: (val) =>
                                setState(() => _sectionTitle = val),
                          ),
                        if (_type == QuestionType.sectionDivider)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Marks',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                ? 'Required'
                                : null,
                            onChanged: (val) =>
                                setState(() => _marks = int.tryParse(val)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lime,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      // Inside _AddQuestionDialogState.build, within the ElevatedButton onPressed callback
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final question = Question(
                            id:
                                _editingId ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            title: _type == QuestionType.sectionDivider
                                ? _sectionTitle ?? ''
                                : _title ?? '',
                            type: _type,
                            options: _type == QuestionType.multipleChoice
                                ? _options
                                : _type == QuestionType.matchTheFollowing
                                ? _pairs
                                      .map((e) => '${e.key}=${e.value}')
                                      .toList()
                                : null,
                            marks: _type == QuestionType.sectionDivider
                                ? _marks
                                : null,
                            sectionTitle: _type == QuestionType.sectionDivider
                                ? _sectionTitle
                                : null,
                            subQuestions: _type == QuestionType.groupedQuestions
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
                          );

                          // IMPORTANT:
                          // This is the correct way to get the context from the parent widget
                          // that created the dialog and has access to the bloc.
                          if (widget.initialQuestion != null) {
                            context.read<FormBuilderBloc>().add(
                              UpdateField(question),
                            );
                          } else {
                            context.read<FormBuilderBloc>().add(
                              AddField(question),
                            );
                          }

                          context.pop(); // Dismiss the dialog
                        }
                      },

                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
