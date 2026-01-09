import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../view_model/chat_view_model.dart';
import '../../domain/entities/message_entity.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().startPolling(widget.otherUserId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleMicPress() async {
    final viewModel = context.read<ChatViewModel>();

    if (viewModel.isRecording) {
      await viewModel.stopRecording(widget.otherUserId);
    } else {
      final status = await Permission.microphone.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.microphone.request();
        if (result != PermissionStatus.granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Microphone permission required to record audio'),
              ),
            );
          }
          return;
        }
      }
      await viewModel.startRecording();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          // Auto scroll to bottom when messages update
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (viewModel.messages.isNotEmpty) {
              _scrollToBottom();
            }
          });

          return Column(
            children: [
              if (viewModel.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = viewModel.messages[index];
                      final isPlaying =
                          viewModel.playingMessageId == message.id;
                      return _MessageBubble(
                        message: message,
                        isPlaying: isPlaying,
                        onPlayAudio: () =>
                            viewModel.playAudio(message.audioUrl!, message.id),
                      );
                    },
                  ),
                ),
              _buildInputArea(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputArea(ChatViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: viewModel.isRecording
                      ? 'Gravando...'
                      : 'Digite sua mensagem...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onChanged: (val) {
                  setState(() {}); // Rebuild to toggle send icon
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _messageController.text.isNotEmpty
                  ? () {
                      viewModel.sendMessage(
                        widget.otherUserId,
                        content: _messageController.text,
                      );
                      _messageController.clear();
                      setState(() {});
                    }
                  : _handleMicPress,
              child: CircleAvatar(
                backgroundColor: viewModel.isRecording
                    ? Colors.red
                    : Theme.of(context).primaryColor,
                child: Icon(
                  _messageController.text.isNotEmpty
                      ? Icons.send
                      : (viewModel.isRecording ? Icons.stop : Icons.mic),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final VoidCallback onPlayAudio;
  final bool isPlaying;

  const _MessageBubble({
    required this.message,
    required this.onPlayAudio,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final align = message.isMe
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final color = message.isMe ? const Color(0xFFDCF8C6) : Colors.grey[200];
    final textColor = Colors.black87;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: message.isMe
                  ? const Radius.circular(12)
                  : const Radius.circular(0),
              bottomRight: message.isMe
                  ? const Radius.circular(0)
                  : const Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.isAudio)
                GestureDetector(
                  onTap: onPlayAudio,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      const SizedBox(width: 8),
                      const Text("Mensagem de Voz"),
                    ],
                  ),
                )
              else
                Text(
                  message.content,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.createdAt.toLocal()),
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
