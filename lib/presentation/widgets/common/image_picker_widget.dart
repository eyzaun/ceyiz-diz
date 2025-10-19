import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/themes/design_system.dart';

class ImagePickerWidget extends StatelessWidget {
  final List<XFile> selectedImages;
  final Function(List<XFile>) onImagesSelected;
  final int maxImages;

  const ImagePickerWidget({
    super.key,
    required this.selectedImages,
    required this.onImagesSelected,
    this.maxImages = 5,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    if (selectedImages.length >= maxImages) {
      final semantics = Theme.of(context).extension<AppSemanticColors>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('En fazla $maxImages fotoğraf ekleyebilirsiniz'),
          backgroundColor: semantics?.warning ?? Theme.of(context).colorScheme.secondary,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    // 🚀 OPTIMIZATION: Max boyut 1920x1920, %85 kalite
    // Firebase Extension 200x200 ve 400x400 thumbnail'leri otomatik oluşturacak
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final newImages = [...selectedImages, pickedFile];
      onImagesSelected(newImages);
    }
  }

  void _removeImage(int index) {
    final newImages = [...selectedImages]..removeAt(index);
    onImagesSelected(newImages);
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fotoğraf Ekle',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotoğraflar (${selectedImages.length}/$maxImages)',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final xfile = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: FutureBuilder<Uint8List>(
                          future: xfile.readAsBytes(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            }
                            return Image.memory(
                              snapshot.data!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: theme.colorScheme.onError,
                              size: 16,
                            ),
                          ),
                          onPressed: () => _removeImage(index),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (selectedImages.length < maxImages)
                InkWell(
                  onTap: () => _showImageSourceDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ekle',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}