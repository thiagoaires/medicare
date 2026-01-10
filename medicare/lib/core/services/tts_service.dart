import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts flutterTts = FlutterTts();

  // Notifier to let UI know which plan is currently being read
  final ValueNotifier<String?> currentPlayingPlanId = ValueNotifier(null);

  Future<void> init() async {
    // Basic config
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(0.5);

    // iOS Audio Category - Playback and DefaultToSpeaker
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
    );

    // Handlers to manage state
    flutterTts.setStartHandler(() {
      // State is already set in speak(), but this confirms start
      debugPrint("TTS Started");
    });

    flutterTts.setCompletionHandler(() {
      debugPrint("TTS Completed");
      currentPlayingPlanId.value = null;
    });

    flutterTts.setCancelHandler(() {
      debugPrint("TTS Cancelled");
      currentPlayingPlanId.value = null;
    });

    flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
      currentPlayingPlanId.value = null;
    });
  }

  Future<void> speak(String text, String planId) async {
    // Stop any previous speech
    await stop();

    // Set current plan ID before speaking
    currentPlayingPlanId.value = planId;

    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
    currentPlayingPlanId.value = null;
  }
}
