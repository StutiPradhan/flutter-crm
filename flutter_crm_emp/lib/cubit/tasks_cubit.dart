import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@immutable
sealed class TasksState {}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  TasksLoaded({required this.response});

  final List<dynamic> response;
}

class TasksError extends TasksState {
  TasksError({required this.error});

  final String error;
}

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TasksInitial());

  Future<void> getTasks() async {
    try {
      emit(TasksLoading());
      final k = jsonEncode({'query': "query { getClientProjects { payload } }"});
      final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

      final serverResponse = await http.post(Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"), body: k, headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"});

      final jsonMap = List<dynamic>.from(jsonDecode(serverResponse.body)['data']['getClientProjects']['payload']);

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String userDataJson = sharedPreferences.getString("who_am_i") ?? "{}";
      final employeeId = Map<String, dynamic>.from(jsonDecode(userDataJson))['_id'];

      final filteredJsonMap = jsonMap
          .where((project) {
            final assignees = List<dynamic>.from(project['assignees']).map((e) => e['_id']);
            return assignees.contains(employeeId) && (project['status'] == "active");
          })
          .toList()
          .reversed
          .toList();

      final List<dynamic> prettyProjects = filteredJsonMap.fold<List<dynamic>>(
          [],
          (List<dynamic> accProjects, project) =>
              accProjects +
              [
                {
                  'project_id': project['_id'],
                  'project_title': project['title'],
                  'status_update':project['status'],
                  'completed_tasks': project['stages'].fold<List<dynamic>>(
                    [],
                    (List<dynamic> accTasks, stage) =>
                        accTasks +
                        stage['tasks']
                            .where(
                              (task) => (task['is_complete'] as bool),
                            )
                            .toList(),
                  ),
                  'remaining_tasks': project['stages'].fold<List<dynamic>>(
                    [],
                    (List<dynamic> accTasks, stage) =>
                        accTasks +
                        stage['tasks']
                            .where(
                              (task) => !(task['is_complete'] as bool),
                            )
                            .toList(),
                  ),
                  'all_tasks': project['stages'].fold<List<dynamic>>([], (List<dynamic> accTasks, stage) => accTasks + stage['tasks'].map((dynamic task) => {...task, 'project_stage': stage['name'], 'is_complete': task['is_complete']}).toList())
                }
              ]);

      emit(TasksLoaded(response: prettyProjects));
    } catch (e) {
      emit(TasksError(error: e.toString()));
    }
  }
}
