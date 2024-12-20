import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/data/model/high_profile_clients/high_profile_clients.dart';
import 'package:coopengageplus/features/crm/data/repo/high_profile_client_repo.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'high_profile_clients.g.dart';

@riverpod
class HighProfileClients extends _$HighProfileClients {
  late final HighProfileClientRepository _highProfileClientsRepository =
      ref.read(highProfileClientRepoProvider);

  @override
  FutureOr<List<HighProfileClientsModel>> build() async {
    final String token = AppConstants.access_token;
    return _highProfileClientsRepository.getHighProfileClients(token: token);
  }
}
