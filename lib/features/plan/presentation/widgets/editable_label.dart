import 'package:flutter/material.dart';

/// Text that turns into a TextField on double-tap and commits on submit or focus loss.
class EditableLabel extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final TextStyle? style;

  const EditableLabel({super.key, required this.value, required this.onChanged, this.style});

  @override
  State<EditableLabel> createState() => _EditableLabelState();
}

class _EditableLabelState extends State<EditableLabel> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);
  final FocusNode _focusNode = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(EditableLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.value != widget.value) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _startEditing() {
    _controller
      ..text = widget.value
      ..selection = TextSelection(baseOffset: 0, extentOffset: widget.value.length);
    setState(() => _editing = true);
  }

  void _commit() {
    if (!_editing) return;
    final value = _controller.text.trim();
    setState(() => _editing = false);
    // A blank label reverts rather than saving an empty name.
    if (value.isNotEmpty && value != widget.value) widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        style: widget.style,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration.collapsed(hintText: 'Name'),
        onSubmitted: (_) => _commit(),
      );
    }
    return GestureDetector(
      onDoubleTap: _startEditing,
      child: Text(widget.value, style: widget.style, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
