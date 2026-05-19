import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/app_config.dart';

class AiReceiptScanner {
  final GenerativeModel _model;

  AiReceiptScanner()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: AppConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            responseSchema: Schema.object(
              properties: {
                'title': Schema.string(description: 'Nama merchant atau toko'),
                'amount': Schema.number(description: 'Total harga akhir yang dibayar'),
                'isIncome': Schema.boolean(description: 'Pemasukan (true) atau pengeluaran (false). Selalu false untuk struk belanja.'),
                'category': Schema.string(description: 'Kategori belanja (misal: Makanan, Transportasi, Belanja, Hiburan, dll)'),
                'note': Schema.string(description: 'Rincian barang, digabung dengan koma. Contoh: "Beras, Susu, Gula"'),
              },
              requiredProperties: ['title', 'amount', 'isIncome', 'category', 'note'],
            ),
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
    ''');
    
    final imagePart = DataPart('image/jpeg', imageBytes);
    
    final response = await _model.generateContent([
      Content.multi([prompt, imagePart])
    ]);
    
    final text = response.text;
    if (text == null) {
      throw Exception('Gagal mengekstrak data dari struk.');
    }
    
    return jsonDecode(text) as Map<String, dynamic>;
  }
}
