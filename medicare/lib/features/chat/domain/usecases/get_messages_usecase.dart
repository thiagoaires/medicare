import 'package:fpdart/fpdart.dart';
import '../../../../features/core/errors/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call({
    required String otherUserId,
  }) async {
    return await repository.getMessages(otherUserId: otherUserId);
  }
}
