import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final Function? onPressed;
  final String? label;
  const ElevatedButtonWidget({this.onPressed, this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TextButtonWidget extends StatelessWidget {
  const TextButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class IconButtonWidget extends StatelessWidget {
  const IconButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MenuButton extends StatelessWidget {
  final String? text;
  final String? addedText;
  final bool? hasIcon;

  final Function? onPressed;
  const MenuButton({
    this.onPressed,
    this.addedText,
    this.hasIcon,
    this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: const Color(0xFF673AB7).withValues(alpha: 0.20),
        //side: BorderSide(width: 0.5),
      ),
      onPressed: onPressed == null ? () {} : () => onPressed!(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text!,
                style: const TextStyle(
                  fontSize: 17,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              addedText != null
                  ? const SizedBox(
                      height: 8,
                    )
                  : const SizedBox.shrink(),
              addedText != null
                  ? Text(
                      addedText!,
                      maxLines: 5,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          // SizedBox(
          //   width: screenWidth * 0.30,
          //),
          hasIcon == true
              ? const Icon(
                  Symbols.arrow_forward_ios_rounded,
                  size: 20,
                  color: Colors.black,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
