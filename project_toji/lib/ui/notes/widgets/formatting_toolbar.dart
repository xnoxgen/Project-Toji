import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../core/theme/app_colors.dart';

class FormattingToolbar extends StatefulWidget {
  final QuillController controller;

  const FormattingToolbar({super.key, required this.controller});

  @override
  State<FormattingToolbar> createState() => _FormattingToolbarState();
}

class _FormattingToolbarState extends State<FormattingToolbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  bool _isAttributeActive(Attribute attribute) {
    final style = widget.controller.getSelectionStyle();
    return style.attributes.containsKey(attribute.key) &&
        style.attributes[attribute.key]?.value == attribute.value;
  }

  bool _isAttributeKeyActive(String key) {
    final style = widget.controller.getSelectionStyle();
    return style.attributes.containsKey(key);
  }

  void _toggleAttribute(Attribute attribute) {
    final style = widget.controller.getSelectionStyle();
    final isActive =
        style.attributes.containsKey(attribute.key) &&
        style.attributes[attribute.key]?.value == attribute.value;

    if (isActive) {
      widget.controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      widget.controller.formatSelection(attribute);
    }
  }

  void _applyColor(String hexColor) {
    widget.controller.formatSelection(ColorAttribute(hexColor));
  }

  void _applyHighlight(String hexColor) {
    widget.controller.formatSelection(BackgroundAttribute(hexColor));
  }

  void _clearFormatting() {
    final style = widget.controller.getSelectionStyle();
    for (final attr in style.attributes.values) {
      widget.controller.formatSelection(Attribute.clone(attr, null));
    }
  }

  void _insertDivider() {
    final index = widget.controller.selection.baseOffset;
    final length = widget.controller.selection.extentOffset - index;
    final pos = index < 0 ? 0 : index;
    final len = length < 0 ? 0 : length;
    widget.controller.replaceText(
      pos,
      len,
      '\n─────────────────────────────\n',
      null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textMuted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Undo & Redo
            _buildIconButton(
              icon: Icons.undo_rounded,
              tooltip: 'Undo',
              onPressed: widget.controller.hasUndo
                  ? widget.controller.undo
                  : null,
              textMuted: textMuted,
            ),
            _buildIconButton(
              icon: Icons.redo_rounded,
              tooltip: 'Redo',
              onPressed: widget.controller.hasRedo
                  ? widget.controller.redo
                  : null,
              textMuted: textMuted,
            ),
            _buildDivider(borderColor),

            // Headings / Size Selector Menu
            _buildHeadingMenu(textMuted),
            _buildDivider(borderColor),

            // Basic Text Styles
            _buildToggleButton(
              icon: Icons.format_bold_rounded,
              tooltip: 'Bold',
              isActive: _isAttributeActive(Attribute.bold),
              onPressed: () => _toggleAttribute(Attribute.bold),
              textMuted: textMuted,
            ),
            _buildToggleButton(
              icon: Icons.format_italic_rounded,
              tooltip: 'Italic',
              isActive: _isAttributeActive(Attribute.italic),
              onPressed: () => _toggleAttribute(Attribute.italic),
              textMuted: textMuted,
            ),
            _buildToggleButton(
              icon: Icons.format_underlined_rounded,
              tooltip: 'Underline',
              isActive: _isAttributeActive(Attribute.underline),
              onPressed: () => _toggleAttribute(Attribute.underline),
              textMuted: textMuted,
            ),
            _buildToggleButton(
              icon: Icons.format_strikethrough_rounded,
              tooltip: 'Strikethrough',
              isActive: _isAttributeActive(Attribute.strikeThrough),
              onPressed: () => _toggleAttribute(Attribute.strikeThrough),
              textMuted: textMuted,
            ),
            _buildDivider(borderColor),

            // Color Pickers
            _buildColorMenu(
              icon: Icons.format_color_text_rounded,
              tooltip: 'Text Color',
              isBackground: false,
              textMuted: textMuted,
            ),
            _buildColorMenu(
              icon: Icons.border_color_rounded,
              tooltip: 'Highlight Color',
              isBackground: true,
              textMuted: textMuted,
            ),
            _buildDivider(borderColor),

            // Lists
            _buildToggleButton(
              icon: Icons.format_list_bulleted_rounded,
              tooltip: 'Bullet List',
              isActive: _isAttributeActive(Attribute.ul),
              onPressed: () => _toggleAttribute(Attribute.ul),
              textMuted: textMuted,
            ),
            _buildToggleButton(
              icon: Icons.format_list_numbered_rounded,
              tooltip: 'Numbered List',
              isActive: _isAttributeActive(Attribute.ol),
              onPressed: () => _toggleAttribute(Attribute.ol),
              textMuted: textMuted,
            ),
            _buildToggleButton(
              icon: Icons.check_box_outlined,
              tooltip: 'Checklist',
              isActive: _isAttributeActive(Attribute.checked),
              onPressed: () => _toggleAttribute(Attribute.checked),
              textMuted: textMuted,
            ),
            _buildDivider(borderColor),

            // Alignment
            _buildToggleButton(
              icon: Icons.format_align_left_rounded,
              tooltip: 'Align Left',
              isActive:
                  _isAttributeActive(Attribute.leftAlignment) ||
                  !_isAttributeKeyActive(Attribute.align.key),
              onPressed: () => _toggleAttribute(Attribute.leftAlignment),
              textMuted: textMuted,
            ),
            _buildToggleButton(
              icon: Icons.format_align_center_rounded,
              tooltip: 'Align Center',
              isActive: _isAttributeActive(Attribute.centerAlignment),
              onPressed: () => _toggleAttribute(Attribute.centerAlignment),
              textMuted: textMuted,
            ),
            _buildToggleButton(
              icon: Icons.format_align_right_rounded,
              tooltip: 'Align Right',
              isActive: _isAttributeActive(Attribute.rightAlignment),
              onPressed: () => _toggleAttribute(Attribute.rightAlignment),
              textMuted: textMuted,
            ),
            _buildDivider(borderColor),

            // Indentation
            _buildIconButton(
              icon: Icons.format_indent_decrease_rounded,
              tooltip: 'Decrease Indent',
              onPressed: () => widget.controller.indentSelection(false),
              textMuted: textMuted,
            ),
            _buildIconButton(
              icon: Icons.format_indent_increase_rounded,
              tooltip: 'Increase Indent',
              onPressed: () => widget.controller.indentSelection(true),
              textMuted: textMuted,
            ),
            _buildDivider(borderColor),

            // Blockquote & Code
            _buildToggleButton(
              icon: Icons.format_quote_rounded,
              tooltip: 'Quote',
              isActive: _isAttributeActive(Attribute.blockQuote),
              onPressed: () => _toggleAttribute(Attribute.blockQuote),
              textMuted: textMuted,
            ),
            _buildToggleButton(
              icon: Icons.code_rounded,
              tooltip: 'Code Block',
              isActive: _isAttributeActive(Attribute.codeBlock),
              onPressed: () => _toggleAttribute(Attribute.codeBlock),
              textMuted: textMuted,
            ),

            // Horizontal Divider & Clear
            _buildIconButton(
              icon: Icons.horizontal_rule_rounded,
              tooltip: 'Insert Divider',
              onPressed: _insertDivider,
              textMuted: textMuted,
            ),
            _buildIconButton(
              icon: Icons.format_clear_rounded,
              tooltip: 'Clear Formatting',
              onPressed: _clearFormatting,
              textMuted: textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required Color textMuted,
  }) {
    return IconButton(
      icon: Icon(icon, size: 19),
      tooltip: tooltip,
      onPressed: onPressed,
      color: onPressed != null ? textMuted : textMuted.withAlpha(70),
      splashRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onPressed,
    required Color textMuted,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.crimson.withAlpha(35) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? AppColors.crimson : Colors.transparent,
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 19,
          color: isActive ? AppColors.crimson : textMuted,
        ),
        tooltip: tooltip,
        onPressed: onPressed,
        splashRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: borderColor,
    );
  }

  Widget _buildHeadingMenu(Color textMuted) {
    final style = widget.controller.getSelectionStyle();
    String currentLabel = 'Normal';
    if (style.attributes.containsKey(Attribute.h1.key)) {
      final val = style.attributes[Attribute.h1.key]?.value;
      if (val == 1) currentLabel = 'H1';
      if (val == 2) currentLabel = 'H2';
      if (val == 3) currentLabel = 'H3';
    }

    return PopupMenuButton<int>(
      tooltip: 'Heading Level',
      initialValue: currentLabel == 'H1'
          ? 1
          : currentLabel == 'H2'
          ? 2
          : currentLabel == 'H3'
          ? 3
          : 0,
      onSelected: (val) {
        if (val == 1) widget.controller.formatSelection(Attribute.h1);
        if (val == 2) widget.controller.formatSelection(Attribute.h2);
        if (val == 3) widget.controller.formatSelection(Attribute.h3);
        if (val == 0) widget.controller.formatSelection(Attribute.header);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 0, child: Text('Normal Text')),
        const PopupMenuItem(
          value: 1,
          child: Text(
            'Heading 1',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const PopupMenuItem(
          value: 2,
          child: Text(
            'Heading 2',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const PopupMenuItem(
          value: 3,
          child: Text(
            'Heading 3',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLabel,
              style: TextStyle(
                color: currentLabel != 'Normal' ? AppColors.crimson : textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 16, color: textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildColorMenu({
    required IconData icon,
    required String tooltip,
    required bool isBackground,
    required Color textMuted,
  }) {
    const colors = [
      {'name': 'Default', 'hex': '#F5F5F5'},
      {'name': 'Crimson', 'hex': '#DC143C'},
      {'name': 'Orange', 'hex': '#F97316'},
      {'name': 'Amber', 'hex': '#F59E0B'},
      {'name': 'Green', 'hex': '#10B981'},
      {'name': 'Blue', 'hex': '#3B82F6'},
      {'name': 'Purple', 'hex': '#8B5CF6'},
      {'name': 'Muted', 'hex': '#999999'},
    ];

    return PopupMenuButton<String>(
      tooltip: tooltip,
      onSelected: (hex) {
        if (isBackground) {
          _applyHighlight(hex);
        } else {
          _applyColor(hex);
        }
      },
      itemBuilder: (context) => colors.map((c) {
        final hexStr = c['hex'] as String;
        final color = Color(int.parse(hexStr.replaceFirst('#', '0xFF')));
        return PopupMenuItem<String>(
          value: hexStr,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
              ),
              const SizedBox(width: 10),
              Text(c['name'] as String),
            ],
          ),
        );
      }).toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Icon(icon, size: 19, color: textMuted),
      ),
    );
  }
}
