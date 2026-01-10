import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../../core/errors/exceptions.dart';

abstract class UserRemoteDataSource {
  Future<List<UserEntity>> searchPatients(String term);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  @override
  Future<List<UserEntity>> searchPatients(String term) async {
    // Search ONLY by Email using whereContains as requested.
    // This allows partial matching (e.g. 'joao.silva' -> 'joao.silva@gmail.com')

    final query = QueryBuilder<ParseUser>(ParseUser.forQuery());

    // Filter by type 'paciente'
    query.whereEqualTo('userType', 'paciente');

    // Filter by email containing the term
    query.whereContains('email', term);

    // Limit results
    query.setLimit(50);
    query.orderByAscending('email'); // Good UX to order by email

    final response = await query.query();

    if (response.success && response.results != null) {
      return (response.results as List<ParseObject>).map((e) {
        return UserEntity(
          id: e.objectId!,
          name:
              e.get<String>('username') ??
              'Sem Nome', // 'username' stores the name in this app based on previous context
          email: e.get<String>('email') ?? '',
          type: e.get<String>('userType') ?? 'paciente',
        );
      }).toList();
    } else if (response.success && response.results == null) {
      return [];
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Erro na busca de usuários',
      );
    }
  }
}
