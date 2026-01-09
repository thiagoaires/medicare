import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../features/core/errors/failures.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> sendMessage({
    required String content,
    required String receiverId,
    File? audioFile,
  });

  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String otherUserId,
  });
}
