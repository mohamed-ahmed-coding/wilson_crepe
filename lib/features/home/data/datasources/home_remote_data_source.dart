import 'package:wilson_crepe/features/home/data/models/category_model.dart';
import 'package:wilson_crepe/features/home/data/models/crepe_type_price_model.dart';
import 'package:wilson_crepe/features/home/data/models/extra_model.dart';
import 'package:wilson_crepe/features/home/data/models/product_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<List<ProductModel>> getProducts();

  Future<List<ProductModel>> getProductsByCategory(
    String categoryId,
  );

  Future<List<CrepeTypePriceModel>> getCrepeTypePrices();

  Future<List<ExtraModel>> getExtras();
}