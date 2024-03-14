// ignore_for_file: must_be_immutable, depend_on_referenced_packages, file_names

import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final double? labelTextFontSize;
  final FontWeight? labelTextFontWeight;
  final TextEditingController controller;
  final FormFieldValidator<String?>? validatorText;
  final InputBorder? border;
  final Widget? suffixIcon;
  final bool? readonly;
  final bool? expands;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final TextInputType? textInputType;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final double? borderRadius;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextInputFormatter? textInputFormatter;
  bool obscureText;
  void Function(String)? onChanged;
  final bool? isNameScreen;
  final Color? fillColor;
  final bool? isOtpScreen;
  final TextAlign? textAlign;
  final Color? cursorColor;
  final VoidCallback? onEditingComplete;

  TextFieldWidget(
      {Key? key,
      required this.hintText,
      this.expands,
      this.labelTextFontWeight,
      this.fillColor,
      required this.controller,
      this.validatorText,
      this.labelText,
      this.border,
      this.minLines,
      this.suffixIcon,
      this.obscureText = false,
      this.textInputType,
      this.textInputAction,
      this.onTap,
      this.textInputFormatter,
      this.prefixIcon,
      this.contentPadding,
      this.readonly,
      this.borderRadius,
      this.focusNode,
      this.autofocus,
      this.hintStyle,
      this.maxLines,
      this.onChanged,
      this.style,
      this.isNameScreen,
      this.isOtpScreen,
      this.textAlign,
      this.cursorColor,
      this.onEditingComplete,
      this.labelTextFontSize})
      : super(key: key);

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          onChanged: widget.onChanged,
          maxLines: widget.maxLines ?? 1,
          expands: widget.expands ?? false,
          minLines: widget.minLines,
          readOnly: widget.readonly ?? false,
          style: widget.style,
          controller: widget.controller,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: const Color(0x0fffffff).withOpacity(0.60),
          textAlign: widget.textAlign ?? TextAlign.start,
          inputFormatters: [
            widget.textInputFormatter ?? FilteringTextInputFormatter.singleLineFormatter,
            widget.isNameScreen == true ? FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")) : FilteringTextInputFormatter.singleLineFormatter,
          ],
          obscureText: widget.obscureText,
          autofocus: widget.autofocus ?? false,
          focusNode: widget.focusNode,
          onEditingComplete: widget.onEditingComplete,
          validator: widget.validatorText,
          keyboardType: widget.textInputType ?? TextInputType.visiblePassword,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            errorMaxLines: 2,
            filled: true,
            contentPadding: widget.contentPadding,
            hintText: widget.hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.w), borderSide: BorderSide.none),
            prefixIcon: widget.prefixIcon ?? const SizedBox.shrink(),
            suffixIcon: widget.suffixIcon,
            hintStyle: widget.hintStyle,
            fillColor: widget.fillColor ?? Colors.white.withOpacity(0.90),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.w), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.w), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
