import 'package:flutter_test/flutter_test.dart';
import 'package:latihanresponsimobel/app/data/models/product_model.dart';
import 'package:latihanresponsimobel/app/data/models/cart_item_model.dart';
import 'package:latihanresponsimobel/app/modules/detail/controllers/detail_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latihanresponsimobel/app/data/services/session_service.dart';

void main() {
  group('Product Model Test', () {
    test('Product.fromJson parses valid JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Essence Mascara Lash Princess',
        'description': 'The Essence Mascara Lash Princess is a popular mascara.',
        'price': 9.99,
        'thumbnail': 'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png',
        'stock': 5,
        'category': 'beauty',
        'rating': 4.94,
        'brand': 'Essence',
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Essence Mascara Lash Princess');
      expect(product.price, 9.99);
      expect(product.stock, 5);
      expect(product.category, 'beauty');
      expect(product.rating, 4.94);
      expect(product.brand, 'Essence');
    });

    test('Product.fromJson parses extended JSON fields (reviews, dimensions, discounts)', () {
      final json = {
        'id': 1,
        'title': 'Essence Mascara Lash Princess',
        'description': 'Volumizing mascara',
        'price': 9.99,
        'discountPercentage': 10.48,
        'rating': 2.56,
        'stock': 99,
        'tags': ['beauty', 'mascara'],
        'brand': 'Essence',
        'sku': 'BEA-ESS-ESS-001',
        'weight': 4,
        'dimensions': {
          'width': 15.14,
          'height': 13.08,
          'depth': 22.99
        },
        'warrantyInformation': '1 week warranty',
        'shippingInformation': 'Ships in 3-5 business days',
        'availabilityStatus': 'In Stock',
        'reviews': [
          {
            'rating': 3,
            'comment': 'Would not recommend!',
            'date': '2025-04-30T09:41:02.053Z',
            'reviewerName': 'Eleanor Collins',
            'reviewerEmail': 'eleanor.collins@x.dummyjson.com'
          }
        ],
        'returnPolicy': 'No return policy',
        'minimumOrderQuantity': 48,
        'images': [
          'https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/1.webp'
        ],
        'thumbnail': 'https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp'
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.discountPercentage, 10.48);
      expect(product.tags, ['beauty', 'mascara']);
      expect(product.dimensions?.width, 15.14);
      expect(product.warrantyInformation, '1 week warranty');
      expect(product.availabilityStatus, 'In Stock');
      expect(product.reviews.length, 1);
      expect(product.reviews.first.reviewerName, 'Eleanor Collins');
      expect(product.images.length, 1);
      expect(product.originalPrice > product.price, true);
    });

    test('Product.fromJson handles null and missing fields gracefully', () {
      final json = <String, dynamic>{};
      final product = Product.fromJson(json);

      expect(product.id, 0);
      expect(product.title, '');
      expect(product.price, 0.0);
      expect(product.stock, 0);
      expect(product.rating, 0.0);
      expect(product.brand, null);
    });

    test('Product.fromJson parses FakeStoreAPI format correctly', () {
      final fakeStoreJson = {
        'id': 1,
        'title': 'Fjallraven Backpack',
        'price': 109.95,
        'description': 'Your perfect pack',
        'category': "men's clothing",
        'image': 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png',
        'rating': {
          'rate': 3.9,
          'count': 120,
        },
      };

      final product = Product.fromJson(fakeStoreJson);

      expect(product.id, 1);
      expect(product.title, 'Fjallraven Backpack');
      expect(product.price, 109.95);
      expect(product.thumbnail, 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png');
      expect(product.images, contains('https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png'));
      expect(product.rating, 3.9);
      expect(product.stock > 0, true);
    });
  });

  group('CartItem Model Test', () {
    test('CartItem calculates subtotal correctly', () {
      final item = CartItem(
        username: 'user123',
        productId: 10,
        productName: 'Sample Product',
        price: 25.5,
        quantity: 3,
        imageUrl: 'https://example.com/image.png',
      );

      expect(item.subtotal, 76.5);
    });
  });

  group('SessionService Test', () {
    test('SessionService saves, gets, and removes user session', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = SessionService(prefs);

      expect(service.isLoggedIn(), false);
      expect(service.getUser(), null);

      await service.saveUser('123210001');
      expect(service.isLoggedIn(), true);
      expect(service.getUser(), '123210001');

      await service.logout();
      expect(service.isLoggedIn(), false);
      expect(service.getUser(), null);
    });
  });

  group('DetailController Quantity Logic Test', () {
    test('Quantity respects stock limit (0 < qty <= stock)', () {
      final product = Product(
        id: 1,
        title: 'Limited Item',
        description: 'Test Description',
        price: 10.0,
        thumbnail: '',
        stock: 3,
      );

      final controller = DetailController(initialProduct: product);
      controller.onInit();

      expect(controller.quantity.value, 1);
      expect(controller.canDecrement, false);
      expect(controller.canIncrement, true);

      // Increment to 2
      controller.increment();
      expect(controller.quantity.value, 2);
      expect(controller.canDecrement, true);
      expect(controller.canIncrement, true);

      // Increment to 3 (Max stock)
      controller.increment();
      expect(controller.quantity.value, 3);
      expect(controller.canIncrement, false);

      // Try incrementing beyond stock
      controller.increment();
      expect(controller.quantity.value, 3); // Still 3

      // Decrement back to 1
      controller.decrement();
      expect(controller.quantity.value, 2);
      controller.decrement();
      expect(controller.quantity.value, 1);

      // Try decrementing below 1
      controller.decrement();
      expect(controller.quantity.value, 1); // Still 1
    });

    test('Zero stock sets quantity to 0', () {
      final outOfStockProduct = Product(
        id: 2,
        title: 'Sold Out Item',
        description: 'None left',
        price: 5.0,
        thumbnail: '',
        stock: 0,
      );

      final controller = DetailController(initialProduct: outOfStockProduct);
      controller.onInit();

      expect(controller.quantity.value, 0);
      expect(controller.canIncrement, false);
      expect(controller.canDecrement, false);
    });
  });
}

