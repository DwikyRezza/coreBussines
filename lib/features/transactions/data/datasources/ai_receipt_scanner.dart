import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/app_config.dart';

class AiReceiptScanner {
  GenerativeModel? _model;

  AiReceiptScanner();

  GenerativeModel _getModel() {
    final apiKey = AppConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY belum dikonfigurasi di file .env');
    }
    return _model ??= GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<Map<String, dynamic>> scanReceipt(XFile photo) async {
    try {
      final imageBytes = await photo.readAsBytes();

      // Detect MIME type from file extension
      final mimeType = _detectMimeType(photo.path);

      final prompt = TextPart('''
Kamu adalah asisten akuntansi cerdas. Ekstrak data dari foto struk belanja ini.
Aturan:
- title: ambil nama tokonya.
- amount: cari total akhir / grand total yang harus dibayar (angka saja, tanpa simbol mata uang).
- isIncome: selalu false karena ini struk belanja.
- category: kelompokkan ke salah satu (Makanan, Transportasi, Belanja, Hiburan, Tagihan, Kesehatan, Pendidikan, Lainnya).
- note: daftar item yang dibeli, pisahkan dengan koma.
Balas hanya JSON valid tanpa markdown dengan format:
{"title":"...","amount":0,"isIncome":false,"category":"...","note":"..."}
''');

      final imagePart = DataPart(mimeType, imageBytes);

      final model = _getModel();
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw Exception('AI tidak dapat membaca struk. Pastikan foto struk jelas dan tidak buram.');
      }

      debugPrint('[AiReceiptScanner] Raw response: $text');

      final cleaned = _cleanJsonResponse(text);
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;

      // Validate required fields
      if (!parsed.containsKey('title') || !parsed.containsKey('amount')) {
        throw Exception('AI gagal mengekstrak data utama dari struk. Coba foto ulang dengan pencahayaan yang lebih baik.');
      }

      return parsed;
    } on InvalidApiKey catch (e) {
      debugPrint('[AiReceiptScanner] InvalidApiKey: $e');
      throw Exception('API Key Gemini tidak valid. Periksa konfigurasi GEMINI_API_KEY di file .env.');
    } on ServerException catch (e) {
      debugPrint('[AiReceiptScanner] ServerException: $e');
      throw Exception('Server AI sedang bermasalah. Silakan coba beberapa saat lagi.');
    } on UnsupportedUserLocation catch (e) {
      debugPrint('[AiReceiptScanner] UnsupportedUserLocation: $e');
      throw Exception('Layanan AI tidak tersedia di lokasi Anda. Coba gunakan VPN.');
    } on GenerativeAIException catch (e) {
      debugPrint('[AiReceiptScanner] GenerativeAIException: $e');
      throw Exception('Gagal memproses struk dengan AI: ${e.message}');
    } on SocketException catch (_) {
      throw Exception('Tidak ada koneksi internet. Pastikan perangkat terhubung ke jaringan.');
    } on FormatException catch (e) {
      debugPrint('[AiReceiptScanner] FormatException: $e');
      throw Exception('AI memberikan respons yang tidak valid. Silakan coba foto ulang struk Anda.');
    } catch (e) {
      debugPrint('[AiReceiptScanner] Unexpected error: $e');
      rethrow;
    }
  }

  String _detectMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg'; // default
  }

  String _cleanJsonResponse(String text) {
    final trimmed = text.trim();
    if (!trimmed.startsWith('```')) return trimmed;

    return trimmed
        .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();
  }
}
