/// Sample images for demo/testing purposes
class SampleImages {
  /// Sample person images (diverse poses and styles)
  static const List<SampleImage> people = [
    SampleImage(
      url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600',
      label: 'Woman Portrait 1',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
      label: 'Man Portrait 1',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600',
      label: 'Woman Portrait 2',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600',
      label: 'Man Portrait 2',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=600',
      label: 'Woman Portrait 3',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=600',
      label: 'Man Portrait 3',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600',
      label: 'Woman Portrait 4',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600',
      label: 'Man Portrait 4',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600',
      label: 'Woman Portrait 5',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=600',
      label: 'Man Portrait 5',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=600',
      label: 'Woman Portrait 6',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=600',
      label: 'Man Portrait 6',
    ),
  ];

  /// Sample clothing images (various categories)
  static const List<SampleImage> clothing = [
    // Tops
    SampleImage(
      url: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600',
      label: 'White T-Shirt',
      category: 'upper_body',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600',
      label: 'Blue Shirt',
      category: 'upper_body',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600',
      label: 'Leather Jacket',
      category: 'upper_body',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=600',
      label: 'Black Hoodie',
      category: 'upper_body',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=600',
      label: 'Striped Sweater',
      category: 'upper_body',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=600',
      label: 'Denim Jacket',
      category: 'upper_body',
    ),
    // Bottoms
    SampleImage(
      url: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600',
      label: 'Blue Jeans',
      category: 'lower_body',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=600',
      label: 'Black Pants',
      category: 'lower_body',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600',
      label: 'Khaki Chinos',
      category: 'lower_body',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=600',
      label: 'Shorts',
      category: 'lower_body',
    ),
    // Dresses
    SampleImage(
      url: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600',
      label: 'Red Dress',
      category: 'dresses',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=600',
      label: 'Floral Dress',
      category: 'dresses',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?w=600',
      label: 'Black Dress',
      category: 'dresses',
    ),
    SampleImage(
      url: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=600',
      label: 'Summer Dress',
      category: 'dresses',
    ),
  ];
}

class SampleImage {
  final String url;
  final String label;
  final String? category;

  const SampleImage({
    required this.url,
    required this.label,
    this.category,
  });
}
