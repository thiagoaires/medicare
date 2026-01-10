import 'dart:io';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../../../features/core/errors/exceptions.dart';

abstract class ChatRemoteDataSource {
  Future<void> sendMessage({
    required String content,
    required String receiverId,
    File? audioFile,
  });

  Future<List<ParseObject>> getMessages({required String otherUserId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  @override
  @override
  Future<void> sendMessage({
    required String content,
    required String receiverId,
    File? audioFile,
  }) async {
    try {
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user == null || user.objectId == null) {
        throw const ServerException(message: 'User not authenticated');
      }

      final message = ParseObject('Message')
        ..set<String>('content', content)
        ..set<String>('senderId', user.objectId!)
        ..set<String>('receiverId', receiverId); // Ensuring String type

      if (audioFile != null) {
        final parseFile = ParseFile(audioFile);
        final responseFile = await parseFile.save();

        if (!responseFile.success) {
          throw const ServerException(message: 'Failed to upload audio file');
        }

        message.set('audioFile', parseFile);
        message.set<bool>('isAudio', true);
      } else {
        message.set<bool>('isAudio', false);
      }

      final response = await message.save();

      if (!response.success) {
        throw const ServerException(message: 'Failed to save message');
      }
    } catch (e) {
      throw const ServerException(message: 'Failed to send message');
    }
  }

  @override
  Future<List<ParseObject>> getMessages({required String otherUserId}) async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) {
      throw const ServerException(message: 'User not authenticated');
    }

    final queryBuilder1 = QueryBuilder<ParseObject>(ParseObject('Message'))
      ..whereEqualTo('senderId', user.objectId!)
      ..whereEqualTo('receiverId', otherUserId);

    final queryBuilder2 = QueryBuilder<ParseObject>(ParseObject('Message'))
      ..whereEqualTo('senderId', otherUserId)
      ..whereEqualTo('receiverId', user.objectId!);

    final queryBuilder = QueryBuilder.or(ParseObject('Message'), [
      queryBuilder1,
      queryBuilder2,
    ]);

    queryBuilder.orderByAscending('createdAt');

    final response = await queryBuilder.query();

    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    } else if (response.success && response.results == null) {
      return [];
    } else {
      throw const ServerException(message: 'Failed to fetch messages');
    }
  }
}
