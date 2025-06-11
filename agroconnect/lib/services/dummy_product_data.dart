import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/models/product_categories_enum.dart';

class DummyProductData {
  
  late ProductModel product1;
  late ProductModel product2;
  late ProductModel product3;
  late ProductModel product4;
  late ProductModel product5;
  late ProductModel product6;
  late ProductModel product7;
  late ProductModel product8;
  late ProductModel product9;
  late ProductModel product10;

  late List<ProductModel> products;

  DummyProductData() {
    _generateDummyProducts();
    _initData();
  }

  void _generateDummyProducts() {

    // Vegetais
    product1 = ProductModel(
      null,
      'user1', // createdUserId - references client1
      'Tomate Coração de Boi',
      'Tomates frescos e suculentos, cultivados sem pesticidas. Ideais para saladas e molhos caseiros.',
      'Quinta do Vale Verde, Santarém',
      2.50, // unitPrice per kg
      50, // quantity available
      125.00, // totalPrice (50 * 2.50)
      2, // deliveryTime in days
      4.8, // rating
      ProductCategoriesEnum.vegetais,
    );

    product2 = ProductModel(
      null,
      'user2', // createdUserId - references client2
      'Alface Iceberg Bio',
      'Alface crocante e fresca, certificada biológica. Perfeita para saladas variadas.',
      'Herdade São João, Évora',
      1.80, // unitPrice per unit
      30, // quantity available
      54.00, // totalPrice (30 * 1.80)
      1, // deliveryTime in days
      4.6, // rating
      ProductCategoriesEnum.vegetais,
    );

    // Frutas
    product3 = ProductModel(
      null,
      'user3', // createdUserId - references client3
      'Maçã Bravo de Esmolfe',
      'Maçãs tradicionais portuguesas, doces e aromáticas. Colhidas na árvore no ponto ideal de maturação.',
      'Pomares da Beira, Viseu',
      3.20, // unitPrice per kg
      40, // quantity available
      128.00, // totalPrice (40 * 3.20)
      3, // deliveryTime in days
      4.9, // rating
      ProductCategoriesEnum.frutas,
    );

    product4 = ProductModel(
      null,
      'user4', // createdUserId - references client4
      'Laranja do Algarve',
      'Laranjas suculentas e doces, ricas em vitamina C. Excelentes para sumo natural ou consumo direto.',
      'Quinta Sol Dourado, Faro',
      2.80, // unitPrice per kg
      60, // quantity available
      168.00, // totalPrice (60 * 2.80)
      4, // deliveryTime in days
      4.7, // rating
      ProductCategoriesEnum.frutas,
    );

    // Cereais
    product5 = ProductModel(
      null,
      'user5', // createdUserId - references client5
      'Farinha de Trigo Integral',
      'Farinha de trigo 100% integral, moída em moinho de pedra. Ideal para pães e bolos caseiros.',
      'Moinho do Ribeiro, Minho',
      4.50, // unitPrice per kg
      25, // quantity available
      112.50, // totalPrice (25 * 4.50)
      5, // deliveryTime in days
      4.5, // rating
      ProductCategoriesEnum.cereais,
    );

    product6 = ProductModel(
      null,
      'user6', // createdUserId - references client6
      'Aveia Bio Portuguesa',
      'Aveia biológica cultivada em Portugal, rica em fibras e proteínas. Perfeita para pequenos-almoços saudáveis.',
      'Campos Verdes, Coimbra',
      5.20, // unitPrice per kg
      20, // quantity available
      104.00, // totalPrice (20 * 5.20)
      3, // deliveryTime in days
      4.4, // rating
      ProductCategoriesEnum.cereais,
    );

    // Cabazes
    product7 = ProductModel(
      null,
      'user7', // createdUserId - references client7
      'Cabaz Familiar Semanal',
      'Cabaz variado com produtos frescos da época: vegetais, frutas e ervas aromáticas para uma semana.',
      'Cooperativa Agrícola do Douro',
      35.00, // unitPrice per cabaz
      15, // quantity available
      525.00, // totalPrice (15 * 35.00)
      2, // deliveryTime in days
      4.8, // rating
      ProductCategoriesEnum.cabazes,
    );

    product8 = ProductModel(
      null,
      'user8', // createdUserId - references client8
      'Cabaz Gourmet Local',
      'Seleção premium de produtos regionais: queijos, enchidos, mel e compotas artesanais.',
      'Mercado Regional, Setúbal',
      55.00, // unitPrice per cabaz
      8, // quantity available
      440.00, // totalPrice (8 * 55.00)
      3, // deliveryTime in days
      4.9, // rating
      ProductCategoriesEnum.cabazes,
    );

    // Sazonais
    product9 = ProductModel(
      null,
      'user9', // createdUserId - references client9
      'Castanhas Assadas Tradicionais',
      'Castanhas portuguesas da época, torradas de forma tradicional. Sabor autêntico do outono português.',
      'Serra da Estrela, Guarda',
      6.80, // unitPrice per kg
      12, // quantity available
      81.60, // totalPrice (12 * 6.80)
      4, // deliveryTime in days
      4.6, // rating
      ProductCategoriesEnum.sazonais,
    );

    product10 = ProductModel(
      null,
      'user10', // createdUserId - references client10
      'Cogumelos Silvestres da Serra',
      'Mistura de cogumelos silvestres colhidos na serra: porcini, cantarelos e outros da época.',
      'Florestas do Norte, Viana do Castelo',
      12.50, // unitPrice per kg
      8, // quantity available
      100.00, // totalPrice (8 * 12.50)
      1, // deliveryTime in days
      4.7, // rating
      ProductCategoriesEnum.sazonais,
    );
  }

  Future<void> _initData() async {
    // Initialize the products list with all products
    products = [
      product1, product2, product3, product4, product5,
      product6, product7, product8, product9, product10
    ];
  }

  Future<void> saveProductsToFirebase() async {
    for (ProductModel product in products) {
      try {
        await product.createProductDoc(
          product.productId,
          product.createdUserId,
          product.productName,
          product.description,
          product.origin,
          product.unitPrice,
          product.quantity,
          product.quantity,
          product.totalPrice,
          product.deliveryTime,
          product.rating,
          product.productCategory,
        );
      } catch (e) {
        print('Error saving product ${product.productName}: $e');
      }
    }
  }

  List<ProductModel> getProducts() {
    return products;
  }

  List<ProductModel> getProductsByCategory(ProductCategoriesEnum category) {
    return products.where((product) => product.productCategory == category).toList();
  }

  List<ProductModel> getProductsByUserId(String userId) {
    return products.where((product) => product.createdUserId == userId).toList();
  }
}