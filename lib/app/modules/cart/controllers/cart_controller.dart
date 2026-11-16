import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/hive_cart_service.dart';
import '../../auth/controllers/auth_controller.dart';

class CartController extends GetxController {
  final HiveCartService _cartService = HiveCartService();
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxDouble totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  String get _currentUsername {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().username.value;
    }
    return '';
  }

  void loadCart() {
    final user = _currentUsername;
    if (user.isEmpty) {
      cartItems.clear();
      totalPrice.value = 0.0;
      return;
    }
    final items = _cartService.getCartByUser(user);
    cartItems.assignAll(items);
    _calculateTotal();
  }

  void _calculateTotal() {
    double total = 0.0;
    for (final item in cartItems) {
      final sub = item.subtotal;
      if (!sub.isNaN && !sub.isInfinite && sub > 0) {
        total += sub;
      }
    }
    totalPrice.value = total;
  }

  Future<void> addToCart(Product product, int quantity) async {
    final user = _currentUsername;
    if (user.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Silakan login terlebih dahulu untuk menambah ke keranjang',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (quantity <= 0) {
      Get.snackbar(
        'Perhatian',
        'Jumlah harus lebih besar dari 0',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (quantity > product.stock) {
      Get.snackbar(
        'Stok Tidak Cukup',
        'Jumlah melebihi stok yang tersedia (${product.stock})',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _cartService.addToCart(
      username: user,
      productId: product.id,
      productName: product.title,
      price: product.price,
      quantity: quantity,
      imageUrl: product.thumbnail,
      maxStock: product.stock,
    );

    loadCart();

    Get.snackbar(
      'Berhasil Ditambahkan',
      '${product.title} ($quantity pcs) masuk ke keranjang',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> deleteItem(CartItem item) async {
    final name = item.productName;
    await _cartService.deleteFromCart(item);
    loadCart();

    Get.snackbar(
      'Item Dihapus',
      '$name dihapus dari keranjang',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> updateQuantity(CartItem item, int delta, int maxStock) async {
    final newQty = item.quantity + delta;
    if (newQty <= 0) {
      await deleteItem(item);
    } else if (newQty > maxStock) {
      Get.snackbar(
        'Batas Stok',
        'Jumlah maksimal untuk produk ini adalah $maxStock',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      await _cartService.updateQuantity(item, newQty, maxStock);
      loadCart();
    }
  }

  Future<void> clearUserCart() async {
    final user = _currentUsername;
    if (user.isNotEmpty) {
      await _cartService.clearUserCart(user);
      loadCart();
    }
  }

  int get totalItemCount {
    int count = 0;
    for (final item in cartItems) {
      count += item.quantity;
    }
    return count;
  }
}
