import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';

class ChatViewModel extends ChangeNotifier {
  final SendMessageUseCase sendMessageUseCase;
  final GetMessagesUseCase getMessagesUseCase;

  ChatViewModel({
    required this.sendMessageUseCase,
    required this.getMessagesUseCase,
  });

  List<MessageEntity> _messages = [];
  List<MessageEntity> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Timer? _timer;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void startPolling(String otherUserId) async {
    _isLoading = true;
    notifyListeners();

    await _fetchMessages(otherUserId); // Fetch immediately

    _isLoading = false;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchMessages(otherUserId);
    });
  }

  Future<void> _fetchMessages(String otherUserId) async {
    final result = await getMessagesUseCase(otherUserId: otherUserId);
    result.fold((failure) => debugPrint('Error fetching messages: $failure'), (
      messages,
    ) {
      _messages = messages;
      notifyListeners();
    });
  }

  bool _isSending = false;
  bool get isSending => _isSending;

  Future<void> sendMessage(String receiverId, {String? content}) async {
    if (content == null || content.isEmpty) return;

    _isSending = true;
    notifyListeners();

    final result = await sendMessageUseCase(
      content: content,
      receiverId: receiverId,
    );

    result.fold(
      (failure) => debugPrint('Error sending message: $failure'),
      (_) => _fetchMessages(receiverId),
    );

    _isSending = false;
    notifyListeners();
  }

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        _isRecording = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> stopRecording(String receiverId) async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      notifyListeners();

      if (path != null) {
        _isSending = true;
        notifyListeners();

        final result = await sendMessageUseCase(
          content: '',
          receiverId: receiverId,
          audioFile: File(path),
        );

        result.fold(
          (failure) => debugPrint('Error sending audio: $failure'),
          (_) => _fetchMessages(receiverId),
        );

        _isSending = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isSending = false;
      notifyListeners();
    }
  }

  String? _playingMessageId;
  String? get playingMessageId => _playingMessageId;

  Future<void> playAudio(String url, String messageId) async {
    try {
      debugPrint('Attempting to play audio: $url');
      if (_playingMessageId == messageId) {
        await _audioPlayer.stop();
        _playingMessageId = null;
        notifyListeners();
        return;
      }

      await _audioPlayer.stop(); // Stop previous if any
      _playingMessageId = messageId;
      notifyListeners();

      await _audioPlayer.play(UrlSource(url));

      _audioPlayer.onPlayerComplete.listen((event) {
        _playingMessageId = null;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _playingMessageId = null;
      notifyListeners();
    }
  }
}
