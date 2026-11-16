import 'package:hive/hive.dart';

class CartItem extends HiveObject {
  String username;
  int productId;
  String productName;
  double price;
  int quantity;
  String imageUrl;

  CartItem({
    required this.username,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get subtotal {
    if (price.isNaN || price.isInfinite || price < 0) return 0.0;
    if (quantity < 0) return 0.0;
    return price * quantity;
  }
}

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 0;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      username: fields[0]?.toString() ?? '',
      productId: (fields[1] as num?)?.toInt() ?? 0,
      productName: fields[2]?.toString() ?? '',
      price: (fields[3] as num?)?.toDouble() ?? 0.0,
      quantity: (fields[4] as num?)?.toInt() ?? 1,
      imageUrl: fields[5]?.toString() ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.imageUrl);
  }
}
