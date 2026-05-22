import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/app_config.dart';

class AiReceiptScanner {
  final GenerativeModel _model;

  AiReceiptScanner()
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: AppConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

  Future<Map<String, dynamic>> scanReceipt(XFile photo) async {
    final imageBytes = await photo.readAsBytes();
    
    final prompt = TextPart('''
    Kamu adalah asisten akuntansi cerdas. Ekstrak data dari foto struk belanja ini.
    Aturan:
    - title: ambil nama tokonya.
    - amount: cari total akhir / grand total yang harus dibayar.
    - isIncome: selalu false karena ini struk belanja.
    - category: kelompokkan ke salah satu (Makanan, Transportasi, Belanja, Hiburan, Tagihan, Kesehatan, Pendidikan, Lainnya).
    - note: daftar item yang dibeli, pisahkan dengan koma.
    Balas hanya JSON valid tanpa markdown dengan format:
    {"title":"...","amount":0,"isIncome":false,"category":"...","note":"..."}
    ''');
    
    final imagePart = DataPart('image/jpeg', imageBytes);
    
    final response = await _model.generateContent([
      Content.multi([prompt, imagePart])
    ]);
    
    final text = response.text;
    if (text == null) {
      throw Exception('Gagal mengekstrak data dari struk.');
    }
    
    return jsonDecode(_cleanJsonResponse(text)) as Map<String, dynamic>;
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
