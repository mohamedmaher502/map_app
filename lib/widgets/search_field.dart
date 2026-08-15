import 'package:flutter/material.dart';

/// (بند 02) TextFormField للبحث عن اسم مكان
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.formKey,
    required this.isLoading,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (_) => onSubmit(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'من فضلك اكتب اسم المكان';
            }
            if (value.trim().length < 2) return 'الاسم قصير جدًا';
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter a place name...',
            border: InputBorder.none,
            errorStyle: const TextStyle(height: 0.9),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            prefixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: onSubmit,
                  ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClear,
            ),
          ),
        ),
      ),
    );
  }
}
