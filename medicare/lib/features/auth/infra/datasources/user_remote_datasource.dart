import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../../core/errors/exceptions.dart';

abstract class UserRemoteDataSource {
  Future<List<UserEntity>> searchPatients(String term);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  @override
  Future<List<UserEntity>> searchPatients(String term) async {
    // 1. Query 'Burra' (Busca Ampla)
    // Não usamos whereContains para evitar problemas de case-sensitive da API.
    // Trazemos uma lista maior e filtramos no cliente.
    final query = QueryBuilder<ParseUser>(ParseUser.forQuery());

    // Filter by type 'paciente'
    query.whereEqualTo('userType', 'paciente');

    // Query configuration
    query.setLimit(50);
    query.orderByAscending('username');

    // 2. Filtragem Inteligente (Dart)
    final response = await query.query();

    // Debug: Verificar se usuários estão chegando
    print('Total usuários baixados: ${response.results?.length}');

    if (response.success && response.results != null) {
      final termLower = term.toLowerCase();
      final results = response.results as List<ParseObject>;

      // Filter in memory
      return results
          .where((e) {
            final email = (e.get<String>('email') ?? '').toLowerCase();
            final username = (e.get<String>('username') ?? '').toLowerCase();
            final fullName = (e.get<String>('fullName') ?? '').toLowerCase();

            // Busca flexível: encontra se digitar parte do nome, email ou username
            return email.contains(termLower) ||
                fullName.contains(termLower) ||
                username.contains(termLower);
          })
          .map((e) {
            final username = e.get<String>('username');
            final email = e.get<String>('email');

            // Fallback checks
            final displayEmail = (email != null && email.isNotEmpty)
                ? email
                : (username != null && username.contains('@') ? username : '');

            final displayName =
                e.get<String>('fullName') ?? username ?? 'Sem Nome';

            return UserEntity(
              id: e.objectId!,
              username: displayName,
              email: displayEmail,
              userType: e.get<String>('userType') ?? 'paciente',
            );
          })
          .toList();
    } else if (response.success && response.results == null) {
      return [];
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Erro na busca de usuários',
      );
    }
  }
}
