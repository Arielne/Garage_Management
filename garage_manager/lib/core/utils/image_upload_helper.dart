import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the specified source (camera or gallery)
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  /// Uploads a local image file to Supabase storage bucket `vehicle_images`
  /// and returns its public direct URL.
  static Future<String?> uploadVehicleImage(File file) async {
    try {
      final supabase = Supabase.instance.client;
      final fileExtension = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${refUniqueString()}.$fileExtension';
      
      final String path = await supabase.storage
          .from('vehicle_images')
          .upload('uploads/$fileName', file);

      if (path.isNotEmpty) {
        final String publicUrl = supabase.storage
            .from('vehicle_images')
            .getPublicUrl('uploads/$fileName');
        return publicUrl;
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
    return null;
  }

  /// Helper to generate a short random string for unique filename
  static String refUniqueString() {
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    return random.substring(random.length - 4);
  }
}
