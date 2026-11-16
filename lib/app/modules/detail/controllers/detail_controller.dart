import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/data_sources/default_products_data.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';
import '../../cart/controllers/cart_controller.dart';

class DetailController extends GetxController {
  final ApiService _apiService = ApiService();

  final Rx<Product?> product = Rx<Product?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt quantity = 1.obs;
  final RxInt selectedImageIndex = 0.obs;

  DetailController({Product? initialProduct}) {
    if (initialProduct != null) {
      setProduct(initialProduct);
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (product.value == null) {
      final dynamic arg = Get.arguments;
      loadProduct(arg);
    }
  }

  void loadProduct(dynamic arg) {
    if (arg is Product) {
      setProduct(arg);
    } else if (arg is Map<String, dynamic>) {
      setProduct(Product.fromJson(arg));
    } else if (arg is int) {
      // Segera isi data dari dataset lokal terlebih dahulu agar UI tidak kosong/menunggu
      final immediateFallback = _apiService.getDefaultProductById(arg);
      setProduct(immediateFallback);
      fetchProductById(arg);
    } else if (arg is String) {
      final parsedId = int.tryParse(arg);
      if (parsedId != null) {
        final immediateFallback = _apiService.getDefaultProductById(parsedId);
        setProduct(immediateFallback);
        fetchProductById(parsedId);
      }
    } else {
      if (product.value == null) {
        // Fallback dari dataset lokal jika dibuka langsung atau saat hot reload
        try {
          final List<dynamic> productsList =
              defaultProductsJson['products'] as List<dynamic>? ?? [];
          if (productsList.isNotEmpty) {
            setProduct(Product.fromJson(productsList.first as Map<String, dynamic>));
          }
        } catch (e) {
          debugPrint('Error loading default fallback product: $e');
        }
      }
    }
  }

  void setProduct(Product prod) {
    product.value = prod;
    selectedImageIndex.value = 0;
    if (prod.stock > 0) {
      quantity.value = 1;
    } else {
      quantity.value = 0;
    }
  }

  Future<void> fetchProductById(int id) async {
    try {
      if (product.value == null) {
        isLoading.value = true;
      }
      errorMessage.value = '';
      final prod = await _apiService.fetchProductDetail(id);
      setProduct(prod);
    } catch (e) {
      errorMessage.value = e.toString();
      if (product.value == null) {
        final fallback = _apiService.getDefaultProductById(id);
        setProduct(fallback);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectImage(int index) {
    selectedImageIndex.value = index;
  }

  void increment() {
    final prod = product.value;
    if (prod != null && prod.stock > 0 && quantity.value < prod.stock) {
      quantity.value++;
    }
  }

  void decrement() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  bool get canIncrement {
    final prod = product.value;
    return prod != null && prod.stock > 0 && quantity.value < prod.stock;
  }

  bool get canDecrement => quantity.value > 1;

  double get subtotal {
    final prod = product.value;
    if (prod == null) return 0.0;
    return prod.price * quantity.value;
  }

  List<String> get displayImages {
    final prod = product.value;
    if (prod == null) return [];
    if (prod.images.isNotEmpty) return prod.images;
    if (prod.thumbnail.isNotEmpty) return [prod.thumbnail];
    return [];
  }

  String get activeImageUrl {
    final images = displayImages;
    if (images.isEmpty) return '';
    if (selectedImageIndex.value < images.length) {
      return images[selectedImageIndex.value];
    }
    return images.first;
  }

  Future<void> addToCart() async {
    final prod = product.value;
    if (prod == null || prod.stock <= 0 || quantity.value <= 0) return;

    final cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    await cartController.addToCart(prod, quantity.value);
  }

  // Getters for all product details and specifications
  int get id => product.value?.id ?? 0;
  String get title => product.value?.title ?? '';
  String get description => product.value?.description ?? '';
  String get category => product.value?.category ?? '';
  double get price => product.value?.price ?? 0.0;
  double get originalPrice => product.value?.originalPrice ?? 0.0;
  double get discountPercentage => product.value?.discountPercentage ?? 0.0;
  double get rating => product.value?.rating ?? 0.0;
  int get stock => product.value?.stock ?? 0;
  String? get brand => product.value?.brand;
  String? get sku => product.value?.sku;
  int? get weight => product.value?.weight;
  ProductDimensions? get dimensions => product.value?.dimensions;
  String? get warrantyInformation => product.value?.warrantyInformation;
  String? get shippingInformation => product.value?.shippingInformation;
  String? get availabilityStatus => product.value?.availabilityStatus;
  List<ProductReview> get reviews => product.value?.reviews ?? [];
  String? get returnPolicy => product.value?.returnPolicy;
  int? get minimumOrderQuantity => product.value?.minimumOrderQuantity;
  List<String> get tags => product.value?.tags ?? [];
}
