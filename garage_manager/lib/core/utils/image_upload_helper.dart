import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the specified source (camera or gallery)
  static Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return pickedFile;
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  /// Uploads an XFile (works on both Web and Mobile) to Supabase Storage
  /// and returns its public direct URL.
  static Future<String?> uploadVehicleImage(XFile xFile) async {
    try {
      final supabase = Supabase.instance.client;
      final fileExtension = xFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${refUniqueString()}.$fileExtension';
      
      final Uint8List bytes = await xFile.readAsBytes();
      
      // Determine content type based on extension
      String contentType = 'image/jpeg';
      if (fileExtension.toLowerCase() == 'png') {
        contentType = 'image/png';
      } else if (fileExtension.toLowerCase() == 'webp') {
        contentType = 'image/webp';
      } else if (fileExtension.toLowerCase() == 'gif') {
        contentType = 'image/gif';
      }

      final String path = await supabase.storage
          .from('vehicle_images')
          .uploadBinary(
            'uploads/$fileName', 
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );

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
