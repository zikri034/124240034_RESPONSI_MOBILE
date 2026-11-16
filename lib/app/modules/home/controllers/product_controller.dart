import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';

class ProductController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _apiService.fetchProducts();
      products.assignAll(result);
      _applyFilter();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (searchQuery.value.trim().isEmpty) {
      filteredProducts.assignAll(products);
    } else {
      final q = searchQuery.value.toLowerCase().trim();
      final filtered = products.where((item) {
        return item.title.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q);
      }).toList();
      filteredProducts.assignAll(filtered);
    }
  }
}

