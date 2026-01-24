import 'header_template_model.dart';

/// Collection of prebuilt header templates
class PrebuiltHeaders {
  static const List<HeaderTemplate> templates = [
    // 1. Simple - Just "Question Paper" centered
    HeaderTemplate(
      id: 'prebuilt_simple',
      name: 'Simple',
      isCustom: false,
      examTitle: 'Question Paper',
      titleAlignment: HeaderAlignment.center,
      showBorder: false,
    ),

    // 2. Standard - School name, exam title, date, duration
    HeaderTemplate(
      id: 'prebuilt_standard',
      name: 'Standard',
      isCustom: false,
      instituteName: 'School Name',
      examTitle: 'Examination',
      showDate: true,
      showDuration: true,
      showSubjectField: true,
      showClassField: true,
      titleAlignment: HeaderAlignment.center,
      showBorder: false,
    ),

    // 3. Formal - With border, class/section fields
    HeaderTemplate(
      id: 'prebuilt_formal',
      name: 'Formal',
      isCustom: false,
      instituteName: 'Institution Name',
      subtitle: 'Internal Assessment',
      examTitle: 'Mid-Term Examination',
      showDate: true,
      showDuration: true,
      showMaxMarks: true,
      showSubjectField: true,
      showClassField: true,
      titleAlignment: HeaderAlignment.center,
      showBorder: true,
    ),

    // 4. Minimal - Subject and date only
    HeaderTemplate(
      id: 'prebuilt_minimal',
      name: 'Minimal',
      isCustom: false,
      showDate: true,
      showSubjectField: true,
      titleAlignment: HeaderAlignment.left,
      showBorder: false,
    ),

    // 5. Blank - No header at all
    HeaderTemplate(
      id: 'prebuilt_blank',
      name: 'Blank',
      isCustom: false,
      titleAlignment: HeaderAlignment.center,
      showBorder: false,
    ),

    // 6. Compact - Everything in tight rows
    HeaderTemplate(
      id: 'prebuilt_compact',
      name: 'Compact',
      isCustom: false,
      instituteName: 'School Name',
      examTitle: 'Examination',
      showDate: true,
      showDuration: true,
      showMaxMarks: true,
      showSubjectField: true,
      showClassField: true,
      titleAlignment: HeaderAlignment.center,
      showBorder: false,
    ),

    // 7. Left Aligned - Professional look
    HeaderTemplate(
      id: 'prebuilt_left_aligned',
      name: 'Left Aligned',
      isCustom: false,
      instituteName: 'Institution Name',
      subtitle: 'Academic Year 2025-26',
      examTitle: 'Examination',
      showDate: true,
      showDuration: true,
      showSubjectField: true,
      showClassField: true,
      titleAlignment: HeaderAlignment.left,
      showBorder: false,
    ),

    // 8. Right Aligned - Alternative layout
    HeaderTemplate(
      id: 'prebuilt_right_aligned',
      name: 'Right Aligned',
      isCustom: false,
      instituteName: 'Institution Name',
      examTitle: 'Examination',
      showDate: true,
      showSubjectField: true,
      showClassField: true,
      titleAlignment: HeaderAlignment.right,
      showBorder: false,
    ),

    // 9. Boxed Compact - Bordered with minimal fields
    HeaderTemplate(
      id: 'prebuilt_boxed_compact',
      name: 'Boxed Compact',
      isCustom: false,
      examTitle: 'Question Paper',
      showDate: true,
      showMaxMarks: true,
      showSubjectField: true,
      titleAlignment: HeaderAlignment.center,
      showBorder: true,
    ),

    // 10. Full Details - All fields visible
    HeaderTemplate(
      id: 'prebuilt_full_details',
      name: 'Full Details',
      isCustom: false,
      instituteName: 'Institution Name',
      subtitle: 'Department / Section',
      examTitle: 'Final Examination',
      showDate: true,
      showDuration: true,
      showMaxMarks: true,
      showSubjectField: true,
      showClassField: true,
      titleAlignment: HeaderAlignment.center,
      showBorder: true,
    ),
  ];

  /// Get a prebuilt template by ID
  static HeaderTemplate? getById(String id) {
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Default template to use when none is selected
  static HeaderTemplate get defaultTemplate => templates.first;
}
