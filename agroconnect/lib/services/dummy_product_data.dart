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
      null, // productId
      'user1', // createdUserId - references client1
      'Tomate Coração de Boi', // productName
      'assets/product-images/tomate1.jpg', // productImage
      'Tomates frescos e suculentos, cultivados sem pesticidas. Ideais para saladas e molhos caseiros.', // description
      'Quinta do Vale Verde, Santarém', // origin
      2.50, // unitPrice per kg
      50, // quantity available
      125.00, // totalPrice (50 * 2.50)
      2, // deliveryTime in days
      4.8, // rating
      8.5, // productRadius
      12, // reviewCount
      57.6, // totalRatingValue (12 * 4.8)
      ProductCategoriesEnum.vegetais, // productCategory
      null, // productExpirationDate
    );

    product2 = ProductModel(
      null, // productId
      'user2', // createdUserId - references client2
      'Alface Iceberg Bio', // productName
      'assets/product-images/alface1.jpg', // productImage
      'Alface crocante e fresca, certificada biológica. Perfeita para saladas variadas.', // description
      'Herdade São João, Évora', // origin
      1.80, // unitPrice per unit
      30, // quantity available
      54.00, // totalPrice (30 * 1.80)
      1, // deliveryTime in days
      4.6, // rating
      6.0, // productRadius
      8, // reviewCount
      36.8, // totalRatingValue (8 * 4.6)
      ProductCategoriesEnum.vegetais, // productCategory
      null, // productExpirationDate
    );

    // Frutas
    product3 = ProductModel(
      null, // productId
      'user3', // createdUserId - references client3
      'Maçã Bravo de Esmolfe', // productName
      'assets/product-images/maça1.jpg', // productImage
      'Maçãs tradicionais portuguesas, doces e aromáticas. Colhidas na árvore no ponto ideal de maturação.', // description
      'Pomares da Beira, Viseu', // origin
      3.20, // unitPrice per kg
      40, // quantity available
      128.00, // totalPrice (40 * 3.20)
      3, // deliveryTime in days
      4.9, // rating
      4.2, // productRadius
      15, // reviewCount
      73.5, // totalRatingValue (15 * 4.9)
      ProductCategoriesEnum.frutas, // productCategory
      null, // productExpirationDate
    );

    product4 = ProductModel(
      null, // productId
      'user4', // createdUserId - references client4
      'Laranja do Algarve', // productName
      'assets/product-images/laranja1.jpg', // productImage
      'Laranjas suculentas e doces, ricas em vitamina C. Excelentes para sumo natural ou consumo direto.', // description
      'Quinta Sol Dourado, Faro', // origin
      2.80, // unitPrice per kg
      60, // quantity available
      168.00, // totalPrice (60 * 2.80)
      4, // deliveryTime in days
      4.7, // rating
      8.2, // productRadius
      20, // reviewCount
      94.0, // totalRatingValue (20 * 4.7)
      ProductCategoriesEnum.frutas, // productCategory
      null, // productExpirationDate
    );

    // Cereais
    product5 = ProductModel(
      null, // productId
      'user5', // createdUserId - references client5
      'Farinha de Trigo Integral', // productName
      'assets/product-images/farinha1.jpg', // productImage
      'Farinha de trigo 100% integral, moída em moinho de pedra. Ideal para pães e bolos caseiros.', // description
      'Moinho do Ribeiro, Minho', // origin
      4.50, // unitPrice per kg
      25, // quantity available
      112.50, // totalPrice (25 * 4.50)
      5, // deliveryTime in days
      4.5, // rating
      6.7, // productRadius
      9, // reviewCount
      40.5, // totalRatingValue (9 * 4.5)
      ProductCategoriesEnum.cereais, // productCategory
      null, // productExpirationDate
    );

    product6 = ProductModel(
      null, // productId
      'user6', // createdUserId - references client6
      'Aveia Bio Portuguesa', // productName
      'assets/product-images/aveia1.jpg', // productImage
      'Aveia biológica cultivada em Portugal, rica em fibras e proteínas. Perfeita para pequenos-almoços saudáveis.', // description
      'Campos Verdes, Coimbra', // origin
      5.20, // unitPrice per kg
      20, // quantity available
      104.00, // totalPrice (20 * 5.20)
      3, // deliveryTime in days
      4.4, // rating
      2.5, // productRadius
      6, // reviewCount
      26.4, // totalRatingValue (6 * 4.4)
      ProductCategoriesEnum.cereais, // productCategory
      null, // productExpirationDate
    );

    // Cabazes
    product7 = ProductModel(
      null, // productId
      'user7', // createdUserId - references client7
      'Cabaz Familiar Semanal', // productName
      'assets/product-images/cabaz1.jpg', // productImage
      'Cabaz variado com produtos frescos da época: vegetais, frutas e ervas aromáticas para uma semana.', // description
      'Cooperativa Agrícola do Douro', // origin
      35.00, // unitPrice per cabaz
      15, // quantity available
      525.00, // totalPrice (15 * 35.00)
      2, // deliveryTime in days
      4.8, // rating
      3.0, // productRadius
      25, // reviewCount
      120.0, // totalRatingValue (25 * 4.8)
      ProductCategoriesEnum.cabazes, // productCategory
      null, // productExpirationDate
    );

    product8 = ProductModel(
      null, // productId
      'user8', // createdUserId - references client8
      'Cabaz Gourmet Local', // productName
      'assets/product-images/cabaz2.jpg', // productImage
      'Seleção premium de produtos regionais: queijos, enchidos, mel e compotas artesanais.', // description
      'Mercado Regional, Setúbal', // origin
      55.00, // unitPrice per cabaz
      8, // quantity available
      440.00, // totalPrice (8 * 55.00)
      3, // deliveryTime in days
      4.9, // rating
      5.0, // productRadius
      18, // reviewCount
      88.2, // totalRatingValue (18 * 4.9)
      ProductCategoriesEnum.cabazes, // productCategory
      null, // productExpirationDate
    );

    // Sazonais
    product9 = ProductModel(
      null, // productId
      'user9', // createdUserId - references client9
      'Castanhas Assadas Tradicionais', // productName
      'assets/product-images/castanhas1.jpg', // productImage
      'Castanhas portuguesas da época, torradas de forma tradicional. Sabor autêntico do outono português.', // description
      'Serra da Estrela, Guarda', // origin
      6.80, // unitPrice per kg
      12, // quantity available
      81.60, // totalPrice (12 * 6.80)
      4, // deliveryTime in days
      4.6, // rating
      10.0, // productRadius
      14, // reviewCount
      64.4, // totalRatingValue (14 * 4.6)
      ProductCategoriesEnum.sazonais, // productCategory
      null, // productExpirationDate
    );

    product10 = ProductModel(
      null, // productId
      'user10', // createdUserId - references client10
      'Cogumelos Silvestres da Serra', // productName
      'assets/product-images/cogumelos1.jpg', // productImage
      'Mistura de cogumelos silvestres colhidos na serra: porcini, cantarelos e outros da época.', // description
      'Florestas do Norte, Viana do Castelo', // origin
      12.50, // unitPrice per kg
      8, // quantity available
      100.00, // totalPrice (8 * 12.50)
      1, // deliveryTime in days
      4.7, // rating
      11.0, // productRadius
      11, // reviewCount
      51.7, // totalRatingValue (11 * 4.7)
      ProductCategoriesEnum.sazonais, // productCategory
      null, // productExpirationDate
    );
  }

  void _initData() {
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
          product.productImage,
          product.description,
          product.origin,
          product.unitPrice,
          product.quantity,
          product.totalPrice,
          product.deliveryTime,
          product.rating,
          product.productRadius,
          product.productCategory,
          product.getExpirationDate(),
        );
        print('Product ${product.productName} saved successfully!');
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