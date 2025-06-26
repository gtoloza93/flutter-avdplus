import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final String? suffixIconPath;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.suffixIconPath,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
      child: SizedBox(
        
        width: 360, // Ancho deseado
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Fredoka',
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontFamily: 'Fredoka',
              
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.5),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 179, 172, 172),
                width: 1.5,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.amber[700]!, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            isDense: true,
            suffixIcon:
                suffixIconPath != null
                    ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(suffixIconPath!, width: 20, height: 20),
                    )
                    : null,
            errorStyle: TextStyle(color: Colors.amber, fontFamily: 'Fredoka'),
          ),
        ),
      ),
    );
  }
}
