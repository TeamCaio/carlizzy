import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/ai_providers/ai_provider.dart';
import '../../../../core/ai_providers/ai_provider_manager.dart';
import '../../../../core/services/recent_photos_service.dart';
import '../../domain/entities/garment.dart';
import '../../domain/entities/tryon_result.dart';
import '../../domain/entities/user_image.dart';
import '../../domain/usecases/select_user_image.dart';
import 'tryon_event.dart';
import 'tryon_state.dart';

class TryonBloc extends Bloc<TryonEvent, TryonState> {
  final SelectUserImage selectUserImage;
  final AIProviderManager providerManager;
  final ImagePicker _imagePicker;

  // Current session state
  UserImage? _personImage;
  bool _isPersonUrl = false;
  String? _clothingImage;
  bool _isClothingUrl = false;
  String _category = 'upper_body';

  TryonBloc({
    required this.selectUserImage,
    required this.providerManager,
    required ImagePicker imagePicker,
  })  : _imagePicker = imagePicker,
        super(TryonInitial(
          selectedProvider: providerManager.currentType,
          availableProviders: providerManager.availableProviders,
        )) {
    on<SelectPersonPhotoEvent>(_onSelectPersonPhoto);
    on<SetPersonImageUrlEvent>(_onSetPersonImageUrl);
    on<SetPersonImagePathEvent>(_onSetPersonImagePath);
    on<SelectClothingImageEvent>(_onSelectClothingImage);
    on<SetClothingUrlEvent>(_onSetClothingUrl);
    on<SetCategoryEvent>(_onSetCategory);
    on<ChangeProviderEvent>(_onChangeProvider);
    on<StartTryOnEvent>(_onStartTryOn);
    on<RetryTryOnEvent>(_onRetryTryOn);
    on<ResetTryonEvent>(_onResetTryon);
    on<ClearClothingEvent>(_onClearClothing);
  }

  Future<void> _onSelectPersonPhoto(
    SelectPersonPhotoEvent event,
    Emitter<TryonState> emit,
  ) async {
    final result = await selectUserImage(event.source);

    result.fold(
      (failure) => emit(TryonErrorState(
        message: failure.message,
        canRetry: true,
      )),
      (userImage) {
        _personImage = userImage;
        _isPersonUrl = false;
        // Save to recent photos
        RecentPhotosService.addPhoto(userImage.path);
        _emitCurrentState(emit);
      },
    );
  }

  void _onSetPersonImageUrl(
    SetPersonImageUrlEvent event,
    Emitter<TryonState> emit,
  ) {
    // Create a UserImage with the URL as path for demo purposes
    _personImage = UserImage(
      path: event.url,
      fileName: 'sample_person.jpg',
      size: 0,
      aspectRatio: 1.0,
    );
    _isPersonUrl = true;
    _emitCurrentState(emit);
  }

  void _onSetPersonImagePath(
    SetPersonImagePathEvent event,
    Emitter<TryonState> emit,
  ) {
    // Create a UserImage from file path (for recent photos)
    _personImage = UserImage(
      path: event.path,
      fileName: event.path.split('/').last,
      size: 0,
      aspectRatio: 1.0,
    );
    _isPersonUrl = false;
    // Save to recent photos
    RecentPhotosService.addPhoto(event.path);
    _emitCurrentState(emit);
  }

  Future<void> _onSelectClothingImage(
    SelectClothingImageEvent event,
    Emitter<TryonState> emit,
  ) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: event.source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _clothingImage = pickedFile.path;
        _isClothingUrl = false;
        _emitCurrentState(emit);
      }
    } catch (e) {
      emit(TryonErrorState(
        message: 'Failed to select clothing image: $e',
        canRetry: true,
      ));
    }
  }

  void _onSetClothingUrl(
    SetClothingUrlEvent event,
    Emitter<TryonState> emit,
  ) {
    _clothingImage = event.url;
    _isClothingUrl = true;
    _emitCurrentState(emit);
  }

  void _onSetCategory(
    SetCategoryEvent event,
    Emitter<TryonState> emit,
  ) {
    _category = event.category;
    _emitCurrentState(emit);
  }

  Future<void> _onChangeProvider(
    ChangeProviderEvent event,
    Emitter<TryonState> emit,
  ) async {
    // Only FitRoom is available, no provider switching needed
    _emitCurrentState(emit);
  }

  Future<void> _onStartTryOn(
    StartTryOnEvent event,
    Emitter<TryonState> emit,
  ) async {
    if (_personImage == null || _clothingImage == null) {
      emit(const TryonErrorState(
        message: 'Please select both a photo and clothing item',
        canRetry: false,
      ));
      return;
    }

    final provider = providerManager.currentProvider;

    emit(ProcessingTryOnState(
      personImage: _personImage!,
      clothingImage: _clothingImage!,
      progress: 0.0,
      statusMessage: 'Starting ${provider.type.displayName}...',
      provider: provider.type,
    ));

    try {
      // If person image is a URL, download it first
      File personFile;
      if (_isPersonUrl) {
        emit(ProcessingTryOnState(
          personImage: _personImage!,
          clothingImage: _clothingImage!,
          progress: 0.05,
          statusMessage: 'Downloading person image...',
          provider: provider.type,
        ));
        personFile = await _downloadImage(_personImage!.path);
      } else {
        personFile = File(_personImage!.path);
      }

      final result = await provider.tryOn(
        personImage: personFile,
        garmentImage: _clothingImage!,
        category: _category,
        onProgress: (progress, status) {
          emit(ProcessingTryOnState(
            personImage: _personImage!,
            clothingImage: _clothingImage!,
            progress: progress,
            statusMessage: status,
            provider: provider.type,
          ));
        },
      );

      emit(TryonSuccessState(
        result: TryonResult(
          resultImageUrl: result.resultImageUrl,
          originalImage: _personImage!,
          garment: Garment(
            imageUrl: _clothingImage!,
            description: 'Try-on result',
            category: _category,
            timestamp: DateTime.now(),
          ),
          createdAt: DateTime.now(),
        ),
        personImage: _personImage!,
        clothingImage: _clothingImage!,
        usedProvider: provider.type,
      ));
    } catch (e) {
      emit(TryonErrorState(
        message: e.toString(),
        canRetry: true,
        lastProvider: provider.type,
      ));
    }
  }

  Future<void> _onRetryTryOn(
    RetryTryOnEvent event,
    Emitter<TryonState> emit,
  ) async {
    add(const StartTryOnEvent());
  }

  void _onResetTryon(
    ResetTryonEvent event,
    Emitter<TryonState> emit,
  ) {
    _personImage = null;
    _isPersonUrl = false;
    _clothingImage = null;
    _isClothingUrl = false;
    _category = 'upper_body';
    emit(TryonInitial(
      selectedProvider: providerManager.currentType,
      availableProviders: providerManager.availableProviders,
    ));
  }

  void _onClearClothing(
    ClearClothingEvent event,
    Emitter<TryonState> emit,
  ) {
    _clothingImage = null;
    _isClothingUrl = false;
    _emitCurrentState(emit);
  }

  void _emitCurrentState(Emitter<TryonState> emit) {
    if (_personImage == null) {
      emit(TryonInitial(
        selectedProvider: providerManager.currentType,
        availableProviders: providerManager.availableProviders,
      ));
    } else if (_clothingImage == null) {
      emit(PersonSelectedState(
        personImage: _personImage!,
        isPersonUrl: _isPersonUrl,
        selectedProvider: providerManager.currentType,
        availableProviders: providerManager.availableProviders,
      ));
    } else {
      emit(TryonReadyState(
        personImage: _personImage!,
        isPersonUrl: _isPersonUrl,
        clothingImage: _clothingImage!,
        isClothingUrl: _isClothingUrl,
        category: _category,
        selectedProvider: providerManager.currentType,
        availableProviders: providerManager.availableProviders,
      ));
    }
  }

  Future<File> _downloadImage(String url) async {
    final dio = Dio();
    final tempDir = await getTemporaryDirectory();
    final fileName = 'person_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '${tempDir.path}/$fileName';

    await dio.download(url, filePath);
    return File(filePath);
  }
}
