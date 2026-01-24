import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'header_template_model.dart';
import 'prebuilt_headers.dart';

/// Service for managing header templates (loading/saving custom headers)
class HeaderTemplateService {
  static const String _fileName = 'custom_headers.json';

  /// Get the file for storing custom headers
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Load all custom headers from storage
  static Future<List<HeaderTemplate>> loadCustomHeaders() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final data = jsonDecode(content) as List;
      return data.map((h) => HeaderTemplate.fromJson(h)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save a custom header (add or update)
  static Future<void> saveCustomHeader(HeaderTemplate header) async {
    final headers = await loadCustomHeaders();
    // Remove existing if updating
    headers.removeWhere((h) => h.id == header.id);
    // Add the new/updated header
    headers.add(header.copyWith(isCustom: true));
    await _saveHeaders(headers);
  }

  /// Delete a custom header by ID
  static Future<void> deleteCustomHeader(String id) async {
    final headers = await loadCustomHeaders();
    headers.removeWhere((h) => h.id == id);
    await _saveHeaders(headers);
  }

  /// Save all custom headers to file
  static Future<void> _saveHeaders(List<HeaderTemplate> headers) async {
    final file = await _getFile();
    final content = jsonEncode(headers.map((h) => h.toJson()).toList());
    await file.writeAsString(content);
  }

  /// Get all prebuilt templates
  static List<HeaderTemplate> getPrebuiltHeaders() {
    return PrebuiltHeaders.templates;
  }

  /// Get all headers (prebuilt + custom)
  static Future<List<HeaderTemplate>> getAllHeaders() async {
    final customHeaders = await loadCustomHeaders();
    return [...PrebuiltHeaders.templates, ...customHeaders];
  }

  /// Get a header by ID (checks both prebuilt and custom)
  static Future<HeaderTemplate?> getHeaderById(String id) async {
    // First check prebuilt
    final prebuilt = PrebuiltHeaders.getById(id);
    if (prebuilt != null) return prebuilt;

    // Then check custom
    final customHeaders = await loadCustomHeaders();
    try {
      return customHeaders.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }
}
