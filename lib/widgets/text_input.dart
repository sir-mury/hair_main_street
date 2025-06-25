import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:get/get.dart';

class Searchtext extends StatelessWidget {
  const Searchtext({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TextInputWidget extends StatelessWidget {
  final FocusNode? focusNode;
  final Color? labelColor;
  final double? fontSize;
  final int? maxLines;
  final int? minLines;
  final bool? obscureText;
  final AutovalidateMode? autovalidateMode;
  final TextInputType? textInputType;
  final String? labelText, hintText, initialValue;
  final void Function(String?)? onSubmit, onChanged;
  final String? Function(String?)? validator; // Corrected declaration
  final TextEditingController? controller;
  final IconButton? visibilityIcon;
  final bool? asCurrency;
  final List<String>? autofillHints;
  const TextInputWidget({
    this.labelColor,
    this.autofillHints,
    this.asCurrency,
    this.focusNode,
    this.controller,
    this.autovalidateMode,
    this.fontSize,
    this.initialValue,
    this.minLines,
    this.maxLines,
    this.visibilityIcon,
    this.hintText,
    this.labelText,
    this.onChanged,
    this.onSubmit,
    this.obscureText,
    this.textInputType,
    this.validator,
    super.key, // Corrected super call
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText == null ? "" : labelText!,
          style: TextStyle(
            color: labelColor ?? const Color(0xFF673AB7),
            fontSize: fontSize ?? 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Raleway',
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        TextFormField(
          autofillHints: autofillHints ?? [],
          focusNode: focusNode,
          style: const TextStyle(
            fontFamily: "Lato",
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          inputFormatters: asCurrency == true
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(symbol: "NGN")
                ]
              : [],
          initialValue: initialValue ?? "",
          keyboardType: textInputType ?? TextInputType.text,
          obscureText: obscureText ?? false,
          maxLines: maxLines ?? 1,
          minLines: minLines,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          decoration: InputDecoration(
            errorMaxLines: 3,
            errorStyle: TextStyle(
              fontSize: 11,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w400,
              color: Colors.red[300],
            ),
            // labelStyle: TextStyle(
            //     fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            suffixIcon: visibilityIcon ?? const SizedBox.shrink(),
            hintText: hintText ?? "",
            // prefix: asCurrency == true ? Text("NGN") : SizedBox.shrink(),
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.34),
              fontSize: 15,
              fontFamily: "Raleway",
              fontWeight: FontWeight.w500,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFF5F5F5),
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFF5F5F5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF673AB7),
                width: 1.5,
              ),
            ),
          ),
          onFieldSubmitted: onSubmit == null ? (value) {} : onSubmit!,
          onChanged: onChanged == null ? (value) {} : onChanged!,
          validator: validator, // Removed unnecessary null check
        ),
      ],
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  final String symbol;

  CurrencyInputFormatter({
    this.symbol = '₦', // Default to Naira symbol
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Helper method to get numeric value
    try {
      if (newValue.text.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      // Only keep digits
      String onlyNumbers = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      // Handle empty case after removing non-digits
      if (onlyNumbers.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      // Convert to double
      double value = double.parse(onlyNumbers) / 100;

      // Format the number
      String formattedValue = value.toStringAsFixed(2);

      // Split into whole and decimal parts
      List<String> parts = formattedValue.split('.');
      String wholeNumber = parts[0];
      String decimal = parts[1];

      // Add thousand separators to whole number part
      final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      wholeNumber =
          wholeNumber.replaceAllMapped(reg, (Match match) => '${match[1]},');

      // Combine all parts
      String result = '$symbol$wholeNumber.$decimal';

      // Return formatted value
      return TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    } catch (e) {
      debugPrint('Formatter error: $e');
      // Return old value if there's an error
      return oldValue;
    }
  }

  static double getNumericValue(String formattedText) {
    try {
      // Remove currency symbol and commas
      String numericString = formattedText.replaceAll(RegExp(r'[^\d.]'), '');
      return double.parse(numericString);
    } catch (e) {
      return 0.0;
    }
  }
}

class CreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var inputText = newValue.text;
    var buffer = StringBuffer();

    for (int i = 0; i < inputText.length; i++) {
      buffer.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 4 == 0 && nonZeroIndexValue != inputText.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class CreditCardInputWidget extends StatelessWidget {
  final FocusNode? focusNode;
  final Color? labelColor;
  final double? fontSize;
  final int? maxLines;
  final int? minLines;
  final bool? obscureText;
  final String? assetImage;
  final AutovalidateMode? autovalidateMode;
  final TextInputType? textInputType;
  final String? labelText, hintText, initialValue;
  final void Function(String?)? onSubmit, onChanged;
  final String? Function(String?)? validator; // Corrected declaration
  final TextEditingController? controller;
  final IconButton? visibilityIcon;
  const CreditCardInputWidget({
    this.labelColor,
    this.focusNode,
    this.controller,
    this.autovalidateMode,
    this.fontSize,
    this.initialValue,
    this.assetImage,
    this.minLines,
    this.maxLines,
    this.visibilityIcon,
    this.hintText,
    this.labelText,
    this.onChanged,
    this.onSubmit,
    this.obscureText,
    this.textInputType,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText == null ? "" : labelText!,
          style: TextStyle(
            color: labelColor ?? const Color(0xFF673AB7),
            fontSize: fontSize ?? 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Raleway',
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        TextFormField(
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19),
            CreditCardFormatter(),
          ],
          focusNode: focusNode,
          style: const TextStyle(
            fontFamily: "Lato",
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          initialValue: initialValue ?? "",
          keyboardType: textInputType ?? TextInputType.text,
          obscureText: obscureText ?? false,
          maxLines: maxLines ?? 1,
          minLines: minLines,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          decoration: InputDecoration(
            errorMaxLines: 3,
            errorStyle: TextStyle(
              fontSize: 11,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w400,
              color: Colors.red[300],
            ),
            // labelStyle: TextStyle(
            //     fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            // suffix: Container(
            //   // height: 30,
            //   width: 30,
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       fit: BoxFit.cover,
            //       image: AssetImage(assetImage ?? ""),
            //     ),
            //   ),
            // ),
            // suffixIcon: visibilityIcon ?? const SizedBox.shrink(),
            hintText: hintText ?? "",
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.34),
              fontSize: 15,
              fontFamily: "Raleway",
              fontWeight: FontWeight.w500,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFF5F5F5),
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFF5F5F5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF673AB7),
                width: 1.5,
              ),
            ),
          ),
          onFieldSubmitted: onSubmit == null ? (value) {} : onSubmit!,
          onChanged: onChanged == null ? (value) {} : onChanged!,
          validator: validator, // Removed unnecessary null check
        ),
      ],
    );
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue previousValue, TextEditingValue nextValue) {
    var inputText = nextValue.text;
    var buffer = StringBuffer();

    for (int i = 0; i < inputText.length; i++) {
      buffer.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 2 == 0 && nonZeroIndexValue != inputText.length) {
        buffer.write('/');
      }
    }

    // Limit input length to 5 for MM/YY format
    if (buffer.length > 5) return previousValue;

    return nextValue.copyWith(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.length));
  }
}

class CardExpiryDateInputWidget extends StatelessWidget {
  final FocusNode? focusNode;
  final Color? labelColor;
  final double? fontSize;
  final int? maxLines;
  final int? minLines;
  final bool? obscureText;
  final String? assetImage;
  final AutovalidateMode? autovalidateMode;
  final TextInputType? textInputType;
  final String? labelText, hintText, initialValue;
  final void Function(String?)? onSubmit, onChanged;
  final String? Function(String?)? validator; // Corrected declaration
  final TextEditingController? controller;
  final IconButton? visibilityIcon;
  const CardExpiryDateInputWidget({
    this.labelColor,
    this.focusNode,
    this.controller,
    this.autovalidateMode,
    this.fontSize,
    this.initialValue,
    this.assetImage,
    this.minLines,
    this.maxLines,
    this.visibilityIcon,
    this.hintText,
    this.labelText,
    this.onChanged,
    this.onSubmit,
    this.obscureText,
    this.textInputType,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText == null ? "" : labelText!,
          style: TextStyle(
            color: labelColor ?? const Color(0xFF673AB7),
            fontSize: fontSize ?? 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Raleway',
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        TextFormField(
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
            CardExpiryFormatter(),
          ],
          focusNode: focusNode,
          style: const TextStyle(
            fontFamily: "Lato",
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          initialValue: initialValue ?? "",
          keyboardType: textInputType ?? TextInputType.text,
          obscureText: obscureText ?? false,
          maxLines: maxLines ?? 1,
          minLines: minLines,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          decoration: InputDecoration(
            errorMaxLines: 3,
            errorStyle: TextStyle(
              fontSize: 11,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w400,
              color: Colors.red[300],
            ),
            // labelStyle: TextStyle(
            //     fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            // suffix: Container(
            //   height: 30,
            //   width: 30,
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       fit: BoxFit.cover,
            //       image: AssetImage(assetImage ?? ""),
            //     ),
            //   ),
            // ),
            // suffixIcon: visibilityIcon ?? const SizedBox.shrink(),
            hintText: hintText ?? "",
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.34),
              fontSize: 15,
              fontFamily: "Raleway",
              fontWeight: FontWeight.w500,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFF5F5F5),
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFF5F5F5),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF673AB7),
                width: 1.5,
              ),
            ),
          ),
          onFieldSubmitted: onSubmit == null ? (value) {} : onSubmit!,
          onChanged: onChanged == null ? (value) {} : onChanged!,
          validator: validator, // Removed unnecessary null check
        ),
      ],
    );
  }
}

class TextInputWidgetWithoutLabel extends StatelessWidget {
  final int? maxLines;
  final int? minLines;
  final bool? obscureText;
  final InputBorder? enabledBorder, border;
  final TextInputType? textInputType;
  final AutovalidateMode? autovalidateMode;
  final String? initialValue;
  final String? hintText;
  final String? Function(String?)? onSubmit, onChanged, validator;
  final TextEditingController? controller;
  final IconButton? visibilityIcon;
  const TextInputWidgetWithoutLabel(
      {this.controller,
      this.minLines,
      this.initialValue,
      this.border,
      this.enabledBorder,
      this.maxLines,
      this.visibilityIcon,
      this.autovalidateMode,
      this.hintText,
      this.onChanged,
      this.onSubmit,
      this.obscureText,
      this.textInputType,
      this.validator,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: textInputType ?? TextInputType.text,
      obscureText: obscureText ?? false,
      maxLines: maxLines ?? 1,
      minLines: minLines ?? 1,
      initialValue: initialValue,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
      decoration: InputDecoration(
        errorMaxLines: 3,
        errorStyle: TextStyle(
          fontSize: 11,
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w400,
          color: Colors.red[300],
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        suffixIcon: visibilityIcon ?? const SizedBox.shrink(),
        hintText: hintText ?? "",
        hintStyle: TextStyle(
          color: Colors.black.withValues(alpha: 0.45),
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        enabledBorder: enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFF5F5F5),
                width: 1.5,
              ),
            ),
        border: border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFF5F5F5),
                width: 1.5,
              ),
            ),
        focusedBorder: OutlineInputBorder(
          gapPadding: 4,
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF673AB7),
            width: 1.5,
          ),
        ),
      ),
      onFieldSubmitted: onSubmit == null ? (value) {} : onSubmit!,
      onChanged: onChanged == null ? (value) {} : onChanged!,
      validator: validator == null
          ? (value) {
              return null;
            }
          : validator!,
    );
  }
}

class TextInputWidgetWithoutLabelForDialog extends StatelessWidget {
  final int? maxLines;
  final bool? obscureText;
  final TextInputType? textInputType;
  final AutovalidateMode? autovalidateMode;
  final String? hintText;
  final String? Function(String?)? onSubmit, onChanged, validator;
  final TextEditingController? controller;
  final dynamic initialValue;
  final IconButton? visibilityIcon;
  const TextInputWidgetWithoutLabelForDialog(
      {this.controller,
      this.maxLines,
      this.visibilityIcon,
      this.autovalidateMode,
      this.initialValue,
      this.hintText,
      this.onChanged,
      this.onSubmit,
      this.obscureText,
      this.textInputType,
      this.validator,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextFormField(
        keyboardType: textInputType ?? TextInputType.text,
        obscureText: obscureText ?? false,
        maxLines: maxLines ?? 1,
        initialValue: initialValue,
        autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
        minLines: 1,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
          filled: true,
          fillColor: Colors.grey[100],
          suffixIcon: visibilityIcon ?? const SizedBox.shrink(),
          hintText: hintText ?? "",
          hintStyle: const TextStyle(
            color: Colors.black45,
          ),
          border: OutlineInputBorder(
            gapPadding: 2,
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            gapPadding: 2,
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue.shade200,
              width: 2,
            ),
          ),
        ),
        onFieldSubmitted: onSubmit == null ? (value) {} : onSubmit!,
        onChanged: onChanged == null ? (value) {} : onChanged!,
        validator: validator == null
            ? (value) {
                return null;
              }
            : validator!,
      ),
    );
  }
}
