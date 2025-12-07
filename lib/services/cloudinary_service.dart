import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // TODO: Replace with your actual Cloudinary credentials
  static const String cloudName = 'dxfg7om7j';
  static const String apiKey = '466934647797747';
  static const String apiSecret = 'FmV2dYhtcTBdNYXZuV51T2AEZ48';
  static const String uploadPreset = 'dish_flow_recipes'; // Optional, for unsigned uploads

  // Upload image file
  Future<String> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Add upload preset (for unsigned uploads) or signature
      if (uploadPreset.isNotEmpty) {
        request.fields['upload_preset'] = uploadPreset;
      } else {
        // For signed uploads, you would generate a signature on your backend
        // For now, using unsigned uploads with preset is recommended
        throw Exception('Upload preset is required for unsigned uploads');
      }

      // Optional: Add transformation parameters
      request.fields['folder'] = 'dish_flow/recipes';
      request.fields['transformation'] = 'w_800,h_600,c_fill,q_auto';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['secure_url'] as String;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload image from bytes (useful for camera captures)
  Future<String> uploadImageFromBytes(List<int> imageBytes, String fileName) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      
      // Add file from bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

      // Add upload preset
      if (uploadPreset.isNotEmpty) {
        request.fields['upload_preset'] = uploadPreset;
      } else {
        throw Exception('Upload preset is required');
      }

      request.fields['folder'] = 'dish_flow/recipes';
      request.fields['transformation'] = 'w_800,h_600,c_fill,q_auto';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['secure_url'] as String;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image from Cloudinary
  Future<void> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      // Generate signature (simplified - in production, do this on backend)
      final signature = _generateSignature(publicId, timestamp);

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
      );

      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'timestamp': timestamp,
          'api_key': apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Generate signature for signed uploads (simplified - use backend in production)
  String _generateSignature(String publicId, String timestamp) {
    // In production, this should be done on your backend for security
    // This is a simplified version
    // final String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
    // You would use a proper HMAC-SHA1 implementation here
    return ''; // Placeholder
  }

  // Get optimized image URL
  String getOptimizedImageUrl(String publicId, {
    int? width,
    int? height,
    String? quality,
  }) {
    final transformations = <String>[];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add(quality ?? 'q_auto');
    transformations.add('c_fill');

    final transformation = transformations.join(',');
    return 'https://res.cloudinary.com/$cloudName/image/upload/$transformation/$publicId';
  }
}

