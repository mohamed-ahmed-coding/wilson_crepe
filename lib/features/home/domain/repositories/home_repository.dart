import 'package:wilson_crepe/features/home/data/models/extra_model.dart';
import 'package:wilson_crepe/features/home/domain/entities/crepe_type_price_entity.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

abstract class HomeRepository {
  Future<List<CategoryEntity>> getCategories();

  Future<List<ProductEntity>> getProducts();

  Future<List<ProductEntity>> getProductsByCategory(
    String categoryId,
  );

  Future<List<CrepeTypePriceEntity>> getCrepeTypePrices();

  Future<List<ExtraModel>> getExtras();
}