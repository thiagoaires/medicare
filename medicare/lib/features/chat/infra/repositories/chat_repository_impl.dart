import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../../../features/core/errors/exceptions.dart';
import '../../../../features/core/errors/failures.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendMessage({
    required String content,
    required String receiverId,
    File? audioFile,
  }) async {
    try {
      await remoteDataSource.sendMessage(
        content: content,
        receiverId: receiverId,
        audioFile: audioFile,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String otherUserId,
  }) async {
    try {
      final results = await remoteDataSource.getMessages(
        otherUserId: otherUserId,
      );
      final currentUser = await ParseUser.currentUser() as ParseUser?;

      final messages = results.map((e) {
        final audioFile = e.get<ParseFile>('audioFile');
        return MessageEntity(
          id: e.objectId!,
          content: e.get<String>('content') ?? '',
          senderId: e.get<String>('senderId')!,
          receiverId: e.get<String>('receiverId')!,
          audioUrl: audioFile?.url,
          isAudio: e.get<bool>('isAudio') ?? false,
          createdAt: e.createdAt!,
          isMe: e.get<String>('senderId') == currentUser?.objectId,
        );
      }).toList();

      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
