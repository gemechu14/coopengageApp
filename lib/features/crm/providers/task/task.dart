import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/data/model/task/task.dart';
import 'package:coopengageplus/features/crm/data/repo/task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'task.g.dart';

@riverpod
class Tasks extends _$Tasks {
  late final TaskRepository _taskRepository = ref.read(taskRepositoryProvider);

  @override
  FutureOr<List<TaskModel>> build() async {
    final String token = AppConstants.access_token;
    return _taskRepository.getTasks(token: token);
  }

  FutureOr<TaskModel> addTask({
    required int highProfileCustomerId,
    required String token,
    required String taskDate,
    required String taskTime,
    required String title,
    required String address,
    String? description,
  }) async {
    final response = await _taskRepository.addTask(
      highProfileCustomerId: highProfileCustomerId,
      token: token,
      taskDate: taskDate,
      taskTime: taskTime,
      title: title,
      address: address,
      description: description,
    );

    final updatedTasks = await _taskRepository.getTasks(token: token);
    state = AsyncData(updatedTasks);
    return response;
  }
}
