import 'package:flutter/material.dart';

import '../file_manager.dart';
import '../scene.dart';

class JsonSyntaxEditorDialog extends StatefulWidget {
  final FileManager fileManager;
  final String? initialJson;

  const JsonSyntaxEditorDialog({
    required this.fileManager,
    this.initialJson,
    super.key,
  });

  @override
  State<JsonSyntaxEditorDialog> createState() => _JsonSyntaxEditorDialogState();
}

class _JsonSyntaxEditorDialogState extends State<JsonSyntaxEditorDialog> {
  late final TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialJson ?? widget.fileManager.rawBlob,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndLoad() {
    final text = _controller.text;
    try {
      SceneData.fromJsonString(text);
      widget.fileManager.loadFromRawJson(text);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Syntax Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit JSON Syntax',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Correct syntax or structure errors below and click Validate & Load.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade400),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter valid JSON drawing syntax...',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    key: const ValueKey('validate_and_load_button'),
                    onPressed: _validateAndLoad,
                    child: const Text('Validate & Load'),
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
