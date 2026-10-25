import 'package:wilson_crepe/features/home/domain/entities/category_entity.dart';
import 'package:wilson_crepe/features/home/domain/entities/product_entity.dart';
import 'package:wilson_crepe/features/home/domain/repositories/home_repository.dart';

class HomeMenu {
  final Future<List<CategoryEntity>> categories;
  final Future<List<ProductEntity>> products;

  const HomeMenu({required this.categories, required this.products});
}

class GetHomeMenu {
  final HomeRepository repository;

  GetHomeMenu(this.repository);

  HomeMenu call() {
    return HomeMenu(
      categories: repository.getCategories(),
      products: repository.getProducts(),
    );
  }
}
