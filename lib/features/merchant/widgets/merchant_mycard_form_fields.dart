import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// MyCard-style labels and fields for merchant registration steps.
class MerchantFlowSubheading extends StatelessWidget {
  const MerchantFlowSubheading({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final Color accentColor;
  final Color mutedColor;
  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: accentColor, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.blueGrey.shade900,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 11.5, color: mutedColor, height: 1.3),
          ),
        ],
      ],
    );
  }
}

InputDecoration merchantFlowInputDecoration({
  required Color accentColor,
  required Color mutedColor,
  String? hintText,
  IconData? prefixIcon,
  String? helperText,
  String counterText = '',
  Color? fillColor,
}) {
  return InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    counterText: counterText,
    hintText: hintText,
    hintStyle: TextStyle(fontSize: 13, color: mutedColor.withOpacity(0.7)),
    helperText: helperText,
    helperStyle: TextStyle(fontSize: 11.5, color: mutedColor, height: 1.3),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: mutedColor, size: 20)
        : null,
    filled: true,
    fillColor: fillColor ?? const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: accentColor.withOpacity(0.35)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: accentColor.withOpacity(0.35)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: accentColor, width: 1.5),
    ),
  );
}

class MerchantFlowLabeledField extends StatefulWidget {
  const MerchantFlowLabeledField({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.keyboardType,
    this.prefixIcon,
    this.inputFormatters,
    this.maxLength,
    this.helperText,
  });

  final Color accentColor;
  final Color mutedColor;
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final String? helperText;

  @override
  State<MerchantFlowLabeledField> createState() => _MerchantFlowLabeledFieldState();
}

class _MerchantFlowLabeledFieldState extends State<MerchantFlowLabeledField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant MerchantFlowLabeledField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          style: const TextStyle(fontSize: 14),
          decoration: merchantFlowInputDecoration(
            accentColor: widget.accentColor,
            mutedColor: widget.mutedColor,
            hintText: widget.hintText ?? widget.label,
            prefixIcon: widget.prefixIcon,
            helperText: widget.helperText,
            counterText: widget.maxLength != null ? '' : '',
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

class MerchantFlowReadOnlyField extends StatelessWidget {
  const MerchantFlowReadOnlyField({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.label,
    required this.value,
  });

  final Color accentColor;
  final Color mutedColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withOpacity(0.35)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// One row in a [showMerchantFlowSelectSheet] list.
class MerchantFlowSelectOption<T> {
  const MerchantFlowSelectOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;
}

/// Styled bottom sheet for branch, language, PUID block, MCC, QR purpose, etc.
Future<T?> showMerchantFlowSelectSheet<T>({
  required BuildContext context,
  required Color accentColor,
  required Color mutedColor,
  required String title,
  String? subtitle,
  IconData? titleIcon,
  T? selectedValue,
  required List<MerchantFlowSelectOption<T>> options,
  bool searchable = false,
  String searchHint = 'Search…',
  bool Function(MerchantFlowSelectOption<T> option, String query)? filter,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _MerchantFlowSelectSheet<T>(
      accentColor: accentColor,
      mutedColor: mutedColor,
      title: title,
      subtitle: subtitle,
      titleIcon: titleIcon,
      selectedValue: selectedValue,
      options: options,
      searchable: searchable,
      searchHint: searchHint,
      filter: filter,
    ),
  );
}

class _MerchantFlowSelectSheet<T> extends StatefulWidget {
  const _MerchantFlowSelectSheet({
    required this.accentColor,
    required this.mutedColor,
    required this.title,
    this.subtitle,
    this.titleIcon,
    this.selectedValue,
    required this.options,
    this.searchable = false,
    this.searchHint = 'Search…',
    this.filter,
  });

  final Color accentColor;
  final Color mutedColor;
  final String title;
  final String? subtitle;
  final IconData? titleIcon;
  final T? selectedValue;
  final List<MerchantFlowSelectOption<T>> options;
  final bool searchable;
  final String searchHint;
  final bool Function(MerchantFlowSelectOption<T> option, String query)? filter;

  @override
  State<_MerchantFlowSelectSheet<T>> createState() =>
      _MerchantFlowSelectSheetState<T>();
}

class _MerchantFlowSelectSheetState<T> extends State<_MerchantFlowSelectSheet<T>> {
  final _searchController = TextEditingController();
  late List<MerchantFlowSelectOption<T>> _visible;

  @override
  void initState() {
    super.initState();
    _visible = widget.options;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _visible = widget.options;
        return;
      }
      final filter = widget.filter;
      _visible = widget.options.where((o) {
        if (filter != null) return filter(o, q);
        final hay = '${o.title} ${o.subtitle ?? ''}'.toLowerCase();
        return hay.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.82;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 24),
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    if (widget.titleIcon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.titleIcon,
                          color: widget.accentColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.mutedColor,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: widget.mutedColor),
                    ),
                  ],
                ),
              ),
              if (widget.searchable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14),
                    decoration: merchantFlowInputDecoration(
                      accentColor: widget.accentColor,
                      mutedColor: widget.mutedColor,
                      hintText: widget.searchHint,
                      prefixIcon: Icons.search_rounded,
                    ),
                  ),
                ),
              Flexible(
                child: _visible.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No matches',
                          style: TextStyle(color: widget.mutedColor),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottom),
                        itemCount: _visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _visible[index];
                          final selected = item.value == widget.selectedValue;
                          return Material(
                            color: selected
                                ? widget.accentColor
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => Navigator.pop(context, item.value),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    if (item.icon != null) ...[
                                      Icon(
                                        item.icon,
                                        size: 22,
                                        color: selected
                                            ? Colors.white
                                            : widget.mutedColor,
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: selected
                                                  ? Colors.white
                                                  : Colors.blueGrey.shade900,
                                            ),
                                          ),
                                          if (item.subtitle != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              item.subtitle!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: selected
                                                    ? Colors.white
                                                        .withOpacity(0.85)
                                                    : widget.mutedColor,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      selected
                                          ? Icons.check_circle_rounded
                                          : Icons
                                              .radio_button_unchecked_rounded,
                                      color: selected
                                          ? Colors.white
                                          : widget.mutedColor.withOpacity(0.5),
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MerchantFlowSelectField<T> extends StatelessWidget {
  const MerchantFlowSelectField({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.label,
    required this.displayText,
    required this.placeholder,
    required this.onTap,
    this.prefixIcon,
    this.helperText,
  });

  final Color accentColor;
  final Color mutedColor;
  final String label;
  final String displayText;
  final String placeholder;
  final VoidCallback onTap;
  final IconData? prefixIcon;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return MerchantFlowPickerField(
      accentColor: accentColor,
      mutedColor: mutedColor,
      label: label,
      displayText: displayText,
      placeholder: placeholder,
      onTap: onTap,
      prefixIcon: prefixIcon,
      helperText: helperText,
    );
  }
}

/// @deprecated Use [MerchantFlowSelectField] + [showMerchantFlowSelectSheet].
class MerchantFlowDropdown<T> extends StatelessWidget {
  const MerchantFlowDropdown({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helperText,
    this.prefixIcon,
    this.sheetTitle,
    this.sheetSubtitle,
  });

  final Color accentColor;
  final Color mutedColor;
  final String label;
  final T? value;
  final List<MerchantFlowSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final String? helperText;
  final IconData? prefixIcon;
  final String? sheetTitle;
  final String? sheetSubtitle;

  String _labelFor(T? v) {
    if (v == null) return '';
    for (final o in options) {
      if (o.value == v) return o.title;
    }
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final display = _labelFor(value);

    return MerchantFlowSelectField<T>(
      accentColor: accentColor,
      mutedColor: mutedColor,
      label: label,
      displayText: display,
      placeholder: 'Tap to choose',
      prefixIcon: prefixIcon,
      helperText: helperText,
      onTap: () async {
        final picked = await showMerchantFlowSelectSheet<T>(
          context: context,
          accentColor: accentColor,
          mutedColor: mutedColor,
          title: sheetTitle ?? label,
          subtitle: sheetSubtitle,
          titleIcon: prefixIcon,
          selectedValue: value,
          options: options,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// Two-option toggle with cyan selected state (e.g. Auto / Premium PUID).
class MerchantFlowSegmentedToggle<T> extends StatelessWidget {
  const MerchantFlowSegmentedToggle({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final Color accentColor;
  final Color mutedColor;
  final List<({T value, String label})> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _SegmentChip(
                label: segments[i].label,
                selected: segments[i].value == selected,
                accentColor: accentColor,
                onTap: () => onChanged(segments[i].value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? accentColor : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : Colors.blueGrey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

class MerchantFlowPickerField extends StatelessWidget {
  const MerchantFlowPickerField({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.label,
    required this.displayText,
    required this.placeholder,
    required this.onTap,
    this.prefixIcon,
    this.helperText,
  });

  final Color accentColor;
  final Color mutedColor;
  final String label;
  final String displayText;
  final String placeholder;
  final VoidCallback onTap;
  final IconData? prefixIcon;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final hasValue = displayText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, color: mutedColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      hasValue ? displayText : placeholder,
                      style: TextStyle(
                        fontSize: 14,
                        color: hasValue
                            ? Colors.blueGrey.shade900
                            : mutedColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: mutedColor, size: 22),
                ],
              ),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: TextStyle(fontSize: 11.5, color: mutedColor, height: 1.3),
          ),
        ],
      ],
    );
  }
}

class MerchantFlowToggleRow extends StatelessWidget {
  const MerchantFlowToggleRow({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final Color accentColor;
  final Color mutedColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: value ? accentColor.withOpacity(0.1) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  value ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  color: value ? accentColor : mutedColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Label/value row for success summary (MyCard-style muted cards).
class MerchantFlowSummaryTile extends StatelessWidget {
  const MerchantFlowSummaryTile({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final Color accentColor;
  final Color mutedColor;
  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 108,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade900,
                  fontFamily: monospace ? 'monospace' : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MerchantFlowDocumentRow extends StatelessWidget {
  const MerchantFlowDocumentRow({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.label,
    required this.onPick,
    this.fileName,
  });

  final Color accentColor;
  final Color mutedColor;
  final String label;
  final VoidCallback onPick;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null && fileName!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: hasFile ? accentColor.withOpacity(0.08) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  hasFile ? Icons.attach_file_rounded : Icons.upload_file_outlined,
                  color: accentColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                      if (hasFile)
                        Text(
                          fileName!,
                          style: TextStyle(fontSize: 11.5, color: mutedColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Text(
                  hasFile ? 'Change' : 'Upload',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
