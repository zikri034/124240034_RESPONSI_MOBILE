import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/data_sources/default_products_data.dart';
import '../../../data/models/product_model.dart';
import '../../../theme/app_theme.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/views/cart_view.dart';

class DetailView extends StatefulWidget {
  final Product? product;

  const DetailView({super.key, this.product});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  late Product _product;
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _product = widget.product ?? _resolveProduct();
    if (_product.stock > 0) {
      _quantity = 1;
    } else {
      _quantity = 0;
    }
  }

  Product _resolveProduct() {
    if (widget.product != null) return widget.product!;

    final dynamic arg = Get.arguments;
    if (arg is Product) return arg;
    if (arg is Map<String, dynamic>) return Product.fromJson(arg);
    if (arg is int) {
      final List<dynamic> productsList =
          defaultProductsJson['products'] as List<dynamic>? ?? [];
      final match = productsList.firstWhere(
        (p) => (p as Map)['id'] == arg,
        orElse: () => productsList.isNotEmpty ? productsList.first : null,
      );
      if (match != null) return Product.fromJson(match as Map<String, dynamic>);
    }

    final List<dynamic> productsList =
        defaultProductsJson['products'] as List<dynamic>? ?? [];
    if (productsList.isNotEmpty) {
      return Product.fromJson(productsList.first as Map<String, dynamic>);
    }

    return Product(
      id: 1,
      title: 'Essence Mascara Lash Princess',
      description:
          'The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects.',
      price: 9.99,
      discountPercentage: 10.48,
      rating: 4.5,
      stock: 99,
      category: 'beauty',
      brand: 'Essence',
      thumbnail: '',
    );
  }

  void _increment() {
    if (_quantity < _product.stock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  List<String> get _displayImages {
    if (_product.images.isNotEmpty) return _product.images;
    if (_product.thumbnail.isNotEmpty) return [_product.thumbnail];
    return [];
  }

  String get _activeImageUrl {
    final images = _displayImages;
    if (images.isEmpty) return '';
    if (_selectedImageIndex < images.length) {
      return images[_selectedImageIndex];
    }
    return images.first;
  }

  Future<void> _addToCart() async {
    if (_product.stock <= 0 || _quantity <= 0) return;

    final cartController = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    await cartController.addToCart(_product, _quantity);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_product.title} ($_quantity pcs) berhasil ditambah ke keranjang',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildProductImage(String url, String title) {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty || !cleanUrl.startsWith('http')) {
      return Container(
        color: AppTheme.backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Image.network(
      cleanUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppTheme.backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_outlined,
                size: 54,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final images = _displayImages;
    final activeImg = _activeImageUrl;
    final subtotal = (product.price * _quantity).toStringAsFixed(2);
    final canIncrement = product.stock > 0 && _quantity < product.stock;
    final canDecrement = _quantity > 1;
    final isStockAvailable = product.stock > 0 && _quantity > 0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, size: 24),
            tooltip: 'Keranjang',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartView()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Bagian Konten Scrollable (Memakai sisa layar penuh)
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A. Gambar Utama Produk
                    Container(
                      height: 260,
                      color: AppTheme.surfaceColor,
                      child: _buildProductImage(
                        activeImg.isNotEmpty ? activeImg : product.thumbnail,
                        product.title,
                      ),
                    ),

                    // B. Galeri Foto Tambahan (Jika gambar lebih dari 1)
                    if (images.length > 1)
                      Container(
                        color: AppTheme.surfaceColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: SizedBox(
                          height: 52,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final isSelected = index == _selectedImageIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImageIndex = index;
                                  });
                                },
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : AppTheme.borderColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      images[index],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.image_outlined,
                                        size: 20,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    const Divider(height: 1, color: AppTheme.subtleBorderColor),

                    // C. Info Produk Lengkap
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kategori, Brand & Status Stok
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  product.category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (product.brand != null &&
                                  product.brand!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppTheme.subtleBorderColor,
                                    ),
                                  ),
                                  child: Text(
                                    product.brand!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: product.stock > 0
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  product.stock > 0
                                      ? (product.availabilityStatus ??
                                          'Tersedia')
                                      : 'Stok Habis',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: product.stock > 0
                                        ? Colors.green.shade700
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Judul Produk
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Baris Harga (Harga Sekarang + Diskon + Harga Asli Coret)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              if (product.discountPercentage > 0) ...[
                                const SizedBox(width: 10),
                                Text(
                                  '\$${product.originalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '-${product.discountPercentage.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.errorColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Rating & Info Stok
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.brown,
                                      ),
                                    ),
                                    if (product.reviews.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${product.reviews.length} ulasan)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.brown,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppTheme.subtleBorderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 15,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Stok: ${product.stock} pcs',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppTheme.subtleBorderColor),
                          const SizedBox(height: 14),

                          // Deskripsi Produk
                          const Text(
                            'Deskripsi Produk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppTheme.subtleBorderColor),
                          const SizedBox(height: 14),

                          // Spesifikasi Lengkap Produk
                          const Text(
                            'Spesifikasi Produk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: AppTheme.subtleBorderColor),
                            ),
                            child: Column(
                              children: [
                                _buildSpecItem(
                                  Icons.qr_code,
                                  'SKU',
                                  product.sku ??
                                      'PRD-${product.id.toString().padLeft(3, '0')}',
                                ),
                                _buildSpecItem(
                                  Icons.category_outlined,
                                  'Kategori',
                                  product.category,
                                ),
                                if (product.brand != null &&
                                    product.brand!.isNotEmpty)
                                  _buildSpecItem(
                                    Icons.branding_watermark_outlined,
                                    'Merek / Brand',
                                    product.brand!,
                                  ),
                                _buildSpecItem(
                                  Icons.inventory_2_outlined,
                                  'Stok Tersedia',
                                  '${product.stock} unit',
                                ),
                                if (product.minimumOrderQuantity != null)
                                  _buildSpecItem(
                                    Icons.shopping_bag_outlined,
                                    'Minimal Pembelian',
                                    '${product.minimumOrderQuantity} unit',
                                  ),
                                if (product.weight != null)
                                  _buildSpecItem(
                                    Icons.scale_outlined,
                                    'Berat',
                                    '${product.weight} kg',
                                  ),
                                if (product.dimensions != null)
                                  _buildSpecItem(
                                    Icons.aspect_ratio_outlined,
                                    'Dimensi (P x L x T)',
                                    '${product.dimensions!.width} x ${product.dimensions!.height} x ${product.dimensions!.depth} cm',
                                  ),
                                if (product.shippingInformation != null)
                                  _buildSpecItem(
                                    Icons.local_shipping_outlined,
                                    'Pengiriman',
                                    product.shippingInformation!,
                                  ),
                                if (product.warrantyInformation != null)
                                  _buildSpecItem(
                                    Icons.verified_user_outlined,
                                    'Garansi',
                                    product.warrantyInformation!,
                                  ),
                                if (product.returnPolicy != null)
                                  _buildSpecItem(
                                    Icons.assignment_return_outlined,
                                    'Kebijakan Retur',
                                    product.returnPolicy!,
                                    isLast: true,
                                  ),
                              ],
                            ),
                          ),

                          // Label / Tags (jika ada)
                          if (product.tags.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text(
                              'Label / Tags',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: product.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: AppTheme.borderColor),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          // Ulasan Pelanggan (jika ada)
                          if (product.reviews.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const Divider(color: AppTheme.subtleBorderColor),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ulasan Pelanggan (${product.reviews.length})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...product.reviews.map((review) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppTheme.subtleBorderColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 12,
                                              backgroundColor:
                                                  AppTheme.backgroundColor,
                                              child: Icon(
                                                Icons.person,
                                                size: 14,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              review.reviewerName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (i) => Icon(
                                              Icons.star_rounded,
                                              size: 14,
                                              color: i < review.rating
                                                  ? Colors.amber
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      review.comment,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Bottom Action Bar yang Terisolasi dengan Tinggi Pasti (72px)
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceColor,
                border: Border(
                  top:
                      BorderSide(color: AppTheme.subtleBorderColor, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  // Quantity Counter Box: [ - ] [ qty ] [ + ]
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: canDecrement ? _decrement : null,
                          color: AppTheme.textPrimary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 44,
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 32),
                          alignment: Alignment.center,
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: canIncrement ? _increment : null,
                          color: AppTheme.textPrimary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 44,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol Tambah ke Keranjang
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: isStockAvailable ? _addToCart : null,
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        label: Text(
                          product.stock > 0
                              ? 'Tambah (\$ $subtotal)'
                              : 'Stok Habis',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppTheme.subtleBorderColor),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
