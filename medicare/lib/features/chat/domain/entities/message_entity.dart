import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String content;
  final String senderId;
  final String receiverId;
  final String? audioUrl;
  final bool isAudio;
  final DateTime createdAt;
  final bool isMe;

  const MessageEntity({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    this.audioUrl,
    required this.isAudio,
    required this.createdAt,
    required this.isMe,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    senderId,
    receiverId,
    audioUrl,
    isAudio,
    createdAt,
    isMe,
  ];
}
