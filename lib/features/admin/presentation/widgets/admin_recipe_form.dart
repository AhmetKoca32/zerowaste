import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/recipe.dart';

class AdminRecipeForm extends StatefulWidget {
  const AdminRecipeForm({
    super.key,
    this.formKey,
    this.initialRecipe,
    required this.onSave,
    this.isLoading = false,
  });

  final GlobalKey<FormState>? formKey;
  final Recipe? initialRecipe;
  final Future<void> Function(Recipe recipe) onSave;
  final bool isLoading;

  @override
  State<AdminRecipeForm> createState() => _AdminRecipeFormState();
}

class _AdminRecipeFormState extends State<AdminRecipeForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipe != null) {
      final recipe = widget.initialRecipe!;
      _titleController.text = recipe.title;
      _descriptionController.text = recipe.description ?? '';
      _imageUrlController.text = recipe.imageUrl ?? '';
      _ingredientsController.text = recipe.ingredients.join('\n');
      _instructionsController.text = recipe.instructions.join('\n');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Recipe _buildRecipe() {
    final ingredients = _ingredientsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final instructions = _instructionsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Recipe(
      id: widget.initialRecipe?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      ingredients: ingredients,
      instructions: instructions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tarif Başlığı *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Başlık gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Fotoğraf URL (Opsiyonel)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                  labelText: 'Malzemeler *',
                  hintText: 'Her satıra bir malzeme yazın',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'En az bir malzeme gerekli';
                  }
                  final items = value
                      .split('\n')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  if (items.isEmpty) return 'En az bir malzeme gerekli';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: InputDecoration(
                  labelText: 'Yapılış Adımları *',
                  hintText: 'Her satıra bir adım yazın',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'En az bir adım gerekli';
                  }
                  final items = value
                      .split('\n')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  if (items.isEmpty) return 'En az bir adım gerekli';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                        if (Form.of(context).validate()) {
                          widget.onSave(_buildRecipe());
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.fern,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.initialRecipe == null ? 'Kaydet' : 'Güncelle',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
