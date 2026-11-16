import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_model.dart';

class HiveCartService {
  static const String boxName = 'cart_box';

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CartItemAdapter());
      }
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<CartItem>(boxName);
      }
    } catch (e) {
      debugPrint('HiveCartService.init error: $e');
    }
  }

  Box<CartItem>? get _box {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<CartItem>(boxName);
    }
    return null;
  }

  List<CartItem> getCartByUser(String username) {
    final box = _box;
    if (box == null) return [];

    final cleanUsername = username.trim().toLowerCase();
    final List<CartItem> result = [];

    try {
      for (final dynamic rawItem in box.values) {
        if (rawItem is CartItem) {
          final itemUser = rawItem.username.trim().toLowerCase();
          if (itemUser == cleanUsername) {
            result.add(rawItem);
          }
        }
      }
    } catch (e) {
      debugPrint('Error retrieving cart items: $e');
    }

    return result;
  }

  Future<void> addToCart({
    required String username,
    required int productId,
    required String productName,
    required double price,
    required int quantity,
    required String imageUrl,
    required int maxStock,
  }) async {
    final box = _box ?? await Hive.openBox<CartItem>(boxName);
    final cleanUsername = username.trim().toLowerCase();

    CartItem? existingItem;
    for (final dynamic rawItem in box.values) {
      if (rawItem is CartItem &&
          rawItem.username.trim().toLowerCase() == cleanUsername &&
          rawItem.productId == productId) {
        existingItem = rawItem;
        break;
      }
    }

    if (existingItem != null && existingItem.isInBox) {
      int newQty = existingItem.quantity + quantity;
      if (newQty > maxStock) {
        newQty = maxStock;
      }
      existingItem.quantity = newQty;
      await existingItem.save();
    } else {
      final newItem = CartItem(
        username: username,
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity > maxStock ? maxStock : quantity,
        imageUrl: imageUrl,
      );
      await box.add(newItem);
    }
  }

  Future<void> updateQuantity(CartItem item, int newQuantity, int maxStock) async {
    if (newQuantity <= 0) {
      await deleteFromCart(item);
    } else if (item.isInBox) {
      item.quantity = newQuantity > maxStock ? maxStock : newQuantity;
      await item.save();
    }
  }

  Future<void> deleteFromCart(CartItem item) async {
    try {
      if (item.isInBox) {
        await item.delete();
      } else {
        final box = _box;
        final key = item.key;
        if (box != null && key != null && box.containsKey(key)) {
          await box.delete(key);
        }
      }
    } catch (e) {
      debugPrint('Error deleting from cart: $e');
    }
  }

  Future<void> clearUserCart(String username) async {
    final items = getCartByUser(username);
    for (final item in items) {
      await deleteFromCart(item);
    }
  }
}
