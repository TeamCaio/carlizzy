class TryonRequestModel {
  final String humanImageUrl;
  final String garmentImageUrl;
  final String garmentDescription;
  final String category;
  final bool crop;
  final int steps;
  final int seed;

  const TryonRequestModel({
    required this.humanImageUrl,
    required this.garmentImageUrl,
    required this.garmentDescription,
    required this.category,
    this.crop = true,
    this.steps = 30,
    this.seed = 42,
  });

  Map<String, dynamic> toJson() {
    return {
      'human_img': humanImageUrl,
      'garm_img': garmentImageUrl,
      'garment_des': garmentDescription,
      'category': category,
      'crop': crop,
      'steps': steps,
      'seed': seed,
    };
  }
}
