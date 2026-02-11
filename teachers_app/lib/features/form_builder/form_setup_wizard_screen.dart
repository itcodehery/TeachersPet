import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minty/features/form_builder/form_builder_provider.dart';
import 'package:minty/features/form_builder/header_template_model.dart';
import 'package:minty/features/form_builder/header_template_service.dart';

class FormSetupWizardScreen extends ConsumerStatefulWidget {
  const FormSetupWizardScreen({super.key});

  @override
  ConsumerState<FormSetupWizardScreen> createState() =>
      _FormSetupWizardScreenState();
}

class _FormSetupWizardScreenState extends ConsumerState<FormSetupWizardScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Details
  final _nameController = TextEditingController();
  final _instituteController = TextEditingController();
  final _examTitleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _dateController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxMarksController = TextEditingController();
  final _subjectController = TextEditingController();
  final _classController = TextEditingController();

  // Step 2: Customization (Header & Font)
  HeaderTemplate? _selectedHeader;
  String _selectedFontFamily = 'NotoSans';
  List<HeaderTemplate> _prebuiltHeaders = [];
  List<HeaderTemplate> _customHeaders = [];
  bool _loadingHeaders = true;
  final Map<String, TextEditingController> _customFieldControllers = {};

  @override
  void initState() {
    super.initState();
    _loadHeaders();
  }

  Future<void> _loadHeaders() async {
    final prebuilt = HeaderTemplateService.getPrebuiltHeaders();
    final custom = await HeaderTemplateService.loadCustomHeaders();
    if (mounted) {
      setState(() {
        _prebuiltHeaders = prebuilt;
        _customHeaders = custom;
        // Default selection
        if (_selectedHeader == null && prebuilt.isNotEmpty) {
          _selectHeader(
            prebuilt.firstWhere(
              (h) => h.id == 'prebuilt_simple',
              orElse: () => prebuilt.first,
            ),
          );
        }
        _loadingHeaders = false;
      });
    }
  }

  void _selectHeader(HeaderTemplate header) {
    setState(() {
      _selectedHeader = header;
      // Initialize custom field controllers if needed
      for (final field in header.customFields) {
        if (!_customFieldControllers.containsKey(field)) {
          _customFieldControllers[field] = TextEditingController();
        }
      }
    });
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
    for (var c in _customFieldControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      // Validate Step 1
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else {
      // Finish Wizard
      _finishWizard();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      context.pop();
    }
  }

  void _finishWizard() {
    // Collect custom values
    final customValues = <String, String>{};
    for (final entry in _customFieldControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        customValues[entry.key] = entry.value.text;
      }
    }

    // Initialize Form Provider
    final notifier = ref.read(formBuilderProvider.notifier);
    notifier.reset(); // Clear old state
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

    if (_selectedHeader != null) {
      notifier.updateSelectedHeader(_selectedHeader!.id);
    }
    notifier.updateFontFamily(_selectedFontFamily);

    // Get the updated form from provider
    final currentForm = ref.read(formBuilderProvider);

    // Replace wizard with editor, passing the form to prevent reset
    context.pushReplacement('/form-builder', extra: currentForm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Stepper(
                  type: StepperType.horizontal,
                  elevation: 0,
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 32.0),
                      child: Row(
                        children: [
                          if (_currentStep > 0) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.5),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Back'),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _currentStep == 1 ? 'Create Form' : 'Next Step',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (_currentStep == 0) ...[
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Details'),
                      content: _buildDetailsStep(),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0
                          ? StepState.complete
                          : StepState.editing,
                    ),
                    Step(
                      title: const Text('Design'),
                      content: _buildDesignStep(),
                      isActive: _currentStep >= 1,
                      state: _currentStep == 1
                          ? StepState.editing
                          : StepState.indexed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.eco_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Question Paper',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Let\'s set up your form structure',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informative Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Only "Form Name" is required. All other fields are optional.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Basic Information'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Form Name *', 'e.g. Final Exam 2025'),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a name' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            _instituteController,
            'Institute Name (Optional)',
            'e.g. Springfield High',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _examTitleController,
                  'Exam Title (Optional)',
                  'e.g. Mid-Term',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  _subtitleController,
                  'Subtitle (Optional)',
                  'e.g. 2024-2025',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Class Details'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _subjectController,
                  'Subject (Optional)',
                  'e.g. Math',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  _classController,
                  'Class (Optional)',
                  'e.g. 10th',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Exam Properties'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _dateController,
                  'Date (Optional)',
                  'DD/MM/YYYY',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  _durationController,
                  'Duration (Optional)',
                  'e.g. 3 Hrs',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  _maxMarksController,
                  'Marks (Optional)',
                  'e.g. 100',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'These details can be modified later in the editor.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: _inputDecoration(label, hint),
    );
  }

  Widget _buildDesignStep() {
    if (_loadingHeaders) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Font Selection'),
        const SizedBox(height: 16),
        _buildFontSelectionCard(),
        const SizedBox(height: 32),
        _buildSectionTitle('Header Template'),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _prebuiltHeaders.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final header = _prebuiltHeaders[index];
              return _buildHeaderChoice(header);
            },
          ),
        ),
        if (_customHeaders.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Custom Headers',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _customHeaders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final header = _customHeaders[index];
                return _buildHeaderChoice(header);
              },
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (_selectedHeader != null &&
            _selectedHeader!.customFields.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionTitle('Header Variables'),
          const SizedBox(height: 16),
          _buildDynamicFieldsForHeader(),
        ],
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Font and Header can be changed later while editing.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFontSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildFontOption(
            title: 'Noto Sans',
            description:
                'Modern Sans-Serif. Supports multi-language (English, Hindi, Arabic, etc.)',
            value: 'NotoSans',
            sampleText: 'Aa (नमस्ते)',
          ),
          const Divider(height: 24),
          _buildFontOption(
            title: 'Times New Roman',
            description: 'Classic Serif. Supports English characters only.',
            value: 'TimesNewRoman',
            sampleText: 'Aa (Classic)',
          ),
        ],
      ),
    );
  }

  Widget _buildFontOption({
    required String title,
    required String description,
    required String value,
    required String sampleText,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFontFamily = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedFontFamily,
            onChanged: (v) {
              if (v != null) setState(() => _selectedFontFamily = v);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sampleText,
                        style: TextStyle(
                          fontFamily: value == 'TimesNewRoman'
                              ? null
                              : 'Outfit', // We don't have Times loaded in app UI easily, fallback is fine or we can try to find similar.
                          // Actually 'Outfit' is our app font. Times isn't loaded for UI.
                          // Just keep standard style.
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChoice(HeaderTemplate header) {
    final isSelected = _selectedHeader?.id == header.id;
    return GestureDetector(
      onTap: () => _selectHeader(header),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainer,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: header.showBorder
                        ? Border.all(color: Colors.black12)
                        : null,
                  ),
                  child: _buildHeaderPreview(header),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    header.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
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

  Widget _buildDynamicFieldsForHeader() {
    if (_selectedHeader!.customFields.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._selectedHeader!.customFields.map((field) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildTextField(
              _customFieldControllers[field]!,
              field,
              'Enter value for $field',
            ),
          );
        }).toList(),
      ],
    );
  }
}
