import 'package:wilson_crepe/features/home/data/datasources/home_remote_data_source.dart';
import 'package:wilson_crepe/features/home/data/models/crepe_type_price_model.dart';
import 'package:wilson_crepe/features/home/data/models/extra_model.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/home_repository.dart';


class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await remoteDataSource.getProducts();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(
    String categoryId,
  ) async {
    return await remoteDataSource.getProductsByCategory(
      categoryId,
    );
  }

  @override
  Future<List<CrepeTypePriceModel>> getCrepeTypePrices() async {
    return await remoteDataSource.getCrepeTypePrices();
  }

  @override
  Future<List<ExtraModel>> getExtras() async {
    return await remoteDataSource.getExtras();
  }
}