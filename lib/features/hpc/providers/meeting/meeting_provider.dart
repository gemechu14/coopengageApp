
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/data/model/meeting/meeting_model.dart';
import 'package:coopengageplus/features/crm/data/repo/meeting_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'meeting_provider.g.dart';

@riverpod
class Meeting extends _$Meeting {
  late final MeetingRepository _meetingRepository =
      ref.read(meetingRepositoryProvider);

  @override
  FutureOr<List<MeetingModel>> build() async {
    final String token = AppConstants.access_token;
    return _meetingRepository.getMeetings(token: token);
  }

  Future<MeetingModel> addMeeting({
    required int highProfileCustomerId,
    required String token,
    required String meetingDate,
    required String meetingTime,
    String? reason,
    required String address,
  }) async {
    return _meetingRepository.addMeeting(
      highProfileCustomerId: highProfileCustomerId,
      token: token,
      meetingDate: meetingDate,
      meetingTime: meetingTime,
      reason: reason,
      address: address,
    );
  }
}
