import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus_model.dart';
import '../models/train_model.dart';
import '../models/hotel_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Helper untuk mengambil token yang tersimpan di HP
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // OPSI AMBIL LIST (Akses Publik - Tanpa Token)

  Future<List<BusModel>> getBuses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/buses'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> list = responseData['data'];
        return list.map((e) => BusModel.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat data bus');
    } catch (e) {
      throw Exception('Error Bus: $e');
    }
  }

  Future<List<TrainModel>> getTrains() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trains'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> list = responseData['data'];
        return list.map((e) => TrainModel.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat data kereta');
    } catch (e) {
      throw Exception('Error Kereta: $e');
    }
  }

  Future<List<HotelModel>> getHotels() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/hotels'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> list = responseData['data'];
        return list.map((e) => HotelModel.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat data hotel');
    } catch (e) {
      throw Exception('Error Hotel: $e');
    }
  }

  // OPSI DETAIL (Sesuai Alur Baru: Wajib Bawa Token)

  Future<BusModel> getDetailBus(int id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/buses/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return BusModel.fromJson(responseData['data']);
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal memuat detail',
      );
    }
  }

  // AUTHENTICATION & PROFIL

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String token = responseData['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> getProfile() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return UserModel.fromJson(responseData['data']);
    }
    return null;
  }

  // TRANSAKSI BOOKING (Kirim Data ke Laravel)

  Future<bool> createBooking(String type, int itemId, int totalPrice) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {
        'type': type,
        'item_id': itemId.toString(),
        'total_price': totalPrice.toString(),
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
