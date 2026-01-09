import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../features/core/errors/failures.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String content,
    required String receiverId,
    File? audioFile,
  }) async {
    return await repository.sendMessage(
      content: content,
      receiverId: receiverId,
      audioFile: audioFile,
    );
  }
}
