class GarmentGenerationRequestModel {
  final String prompt;
  final int numOutputs;
  final String aspectRatio;
  final String outputFormat;

  const GarmentGenerationRequestModel({
    required this.prompt,
    this.numOutputs = 1,
    this.aspectRatio = '1:1',
    this.outputFormat = 'png',
  });

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'num_outputs': numOutputs,
      'aspect_ratio': aspectRatio,
      'output_format': outputFormat,
    };
  }
}
