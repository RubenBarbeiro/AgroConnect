import 'package:flutter/material.dart';

enum ProductCategoriesEnum {
  vegetais,
  frutas,
  cereais,
  cabazes,
  sazonais,
}

extension ProductCategoriesExtension on ProductCategoriesEnum {
  String get displayName {
    switch (this) {
      case ProductCategoriesEnum.vegetais:
        return 'Vegetais';
      case ProductCategoriesEnum.frutas:
        return 'Frutas';
      case ProductCategoriesEnum.cereais:
        return 'Cereais';
      case ProductCategoriesEnum.cabazes:
        return 'Cabazes';
      case ProductCategoriesEnum.sazonais:
        return 'Produtos Sazonais';
    }
  }

  String get description {
    switch (this) {
      case ProductCategoriesEnum.vegetais:
        return 'Vegetais frescos da horta';
      case ProductCategoriesEnum.frutas:
        return 'Frutas frescas da época';
      case ProductCategoriesEnum.cereais:
        return 'Cereais integrais e farinhas';
      case ProductCategoriesEnum.cabazes:
        return 'Cabazes variados';
      case ProductCategoriesEnum.sazonais:
        return 'Produtos da estação';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategoriesEnum.vegetais:
        return Icons.eco;
      case ProductCategoriesEnum.frutas:
        return Icons.apple;
      case ProductCategoriesEnum.cereais:
        return Icons.grain;
      case ProductCategoriesEnum.cabazes:
        return Icons.shopping_basket;
      case ProductCategoriesEnum.sazonais:
        return Icons.schedule;
    }
  }

  Color get color {
    switch (this) {
      case ProductCategoriesEnum.vegetais:
        return const Color(0xFF4CAF50);
      case ProductCategoriesEnum.frutas:
        return const Color(0xFFFF9800);
      case ProductCategoriesEnum.cereais:
        return const Color(0xFFFFC107);
      case ProductCategoriesEnum.cabazes:
        return const Color(0xFF8D6E63);
      case ProductCategoriesEnum.sazonais:
        return const Color(0xFFFF9800);
    }
  }
}