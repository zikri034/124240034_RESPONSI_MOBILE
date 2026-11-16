import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data_sources/default_products_data.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('$baseUrl/products?limit=100');
    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'] as List<dynamic>? ?? [];
        return productsJson
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('API status error: ${response.statusCode}, falling back to local dataset');
        return getDefaultProducts();
      }
    } catch (e) {
      debugPrint('API connection error: $e. Using fallback dataset.');
      return getDefaultProducts();
    }
  }

  Future<Product> fetchProductDetail(int id) async {
    final uri = Uri.parse('$baseUrl/products/$id');
    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        return getDefaultProductById(id);
      }
    } catch (e) {
      debugPrint('API connection error: $e. Using fallback detail.');
      return getDefaultProductById(id);
    }
  }

  List<Product> getDefaultProducts() {
    final List<dynamic> productsJson =
        defaultProductsJson['products'] as List<dynamic>? ?? [];
    return productsJson
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Product getDefaultProductById(int id) {
    final products = getDefaultProducts();
    return products.firstWhere(
      (p) => p.id == id,
      orElse: () => products.first,
    );
  }
}
