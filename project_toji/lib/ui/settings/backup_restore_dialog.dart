import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../state/physique_state.dart';

class BackupRestoreDialog extends StatefulWidget {
  final PhysiqueState state;
  final bool isExport;

  const BackupRestoreDialog({
    super.key,
    required this.state,
    required this.isExport,
  });

  @override
  State<BackupRestoreDialog> createState() => _BackupRestoreDialogState();
}

class _BackupRestoreDialogState extends State<BackupRestoreDialog> {
  late TextEditingController _jsonController;
  bool _copied = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isExport) {
      final json = widget.state.exportBackup();
      _jsonController = TextEditingController(text: json);
    } else {
      _jsonController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _jsonController.text));
    setState(() {
      _copied = true;
      _statusMessage = 'Backup copied to clipboard!';
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _jsonController.text = data!.text!;
      });
    }
  }

  Future<void> _restore() async {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      setState(() => _statusMessage = 'Please enter or paste JSON backup data.');
      return;
    }

    final success = await widget.state.importBackup(text);
    if (success) {
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database restored successfully!')),
        );
      }
    } else {
      setState(() => _statusMessage = 'Failed to parse JSON backup. Invalid format.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isExport ? 'Export Backup (JSON)' : 'Restore Backup (JSON)'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isExport
                    ? 'Copy this JSON backup to keep your workout history, plans, and measurements safe.'
                    : 'Paste your previously exported JSON backup below to restore your data.',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _jsonController,
                maxLines: 8,
                readOnly: widget.isExport,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: InputDecoration(
                  hintText: widget.isExport ? '' : 'Paste JSON backup string here...',
                ),
              ),
              const SizedBox(height: 8),
              if (_statusMessage != null)
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _statusMessage!.contains('success') || _copied
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              const SizedBox(height: 10),
              if (widget.isExport) ...[
                OutlinedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: Icon(_copied ? Icons.check : Icons.copy, size: 16),
                  label: Text(_copied ? 'Copied!' : 'Copy to Clipboard'),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.paste, size: 16),
                  label: const Text('Paste from Clipboard'),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (!widget.isExport)
          ElevatedButton(
            onPressed: _restore,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.crimson),
            child: const Text('Restore Data'),
          ),
      ],
    );
  }
}

