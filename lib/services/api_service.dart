import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/donation.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000";

  Future<List<Donation>> getAllDonations() async {
    final response = await http.get(Uri.parse('$baseUrl/api/donations'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Donation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load donations');
    }
  }

  Future<Donation> createDonation(Donation donation, File imageFile) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/api/donations'));

    request.fields['nama'] = donation.nama;
    request.fields['deskripsi'] = donation.deskripsi;
    request.fields['target_terkumpul'] = donation.targetTerkumpul.toString();

    final image = await http.MultipartFile.fromPath('gambar', imageFile.path);
    request.files.add(image);

    final response = await request.send();
    final responseData = json.decode(await response.stream.bytesToString());

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Donation.fromJson(responseData);
    } else {
      throw Exception('Failed to create donation');
    }
  }

  Future<Donation> updateDonation(Donation donation, {File? imageFile}) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/api/donations/${donation.id}'));

    request.fields['nama'] = donation.nama;
    request.fields['deskripsi'] = donation.deskripsi;
    request.fields['target_terkumpul'] = donation.targetTerkumpul.toString();
    request.fields['_method'] = 'PUT';

    if (imageFile != null) {
      final image = await http.MultipartFile.fromPath('gambar', imageFile.path);
      request.files.add(image);
    }

    final response = await request.send();
    final responseData = json.decode(await response.stream.bytesToString());

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Donation.fromJson(responseData);
    } else {
      throw Exception('Failed to update donation');
    }
  }

  Future<void> deleteDonation(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/donations/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete donation');
    }
  }
}
