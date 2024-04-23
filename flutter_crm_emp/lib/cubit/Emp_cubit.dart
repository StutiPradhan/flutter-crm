import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@immutable
sealed class EmployeeState {}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  EmployeeLoaded({required this.response});

  final List<dynamic> response;
}

class EmployeeError extends EmployeeState {
  EmployeeError({required this.error});

  final String error;
}

class EmployeeCubit extends Cubit<EmployeeState> {
  EmployeeCubit() : super(EmployeeInitial());

  Future<void> getEmployee() async {
    try {
      emit(EmployeeLoading());
      final k =
          jsonEncode({'query': "query { getEmployee { payload } }"});
      final SharedPreferences sharedPrefs =
          await SharedPreferences.getInstance();

      final serverResponse = await http.post(
          Uri.parse("https://lipsum.smalltowntalks.com/v1/emp/graphql"),
          body: k,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader:
                "Bearer ${sharedPrefs.getString("jwt")}"
          });

      final jsonMap = List<dynamic>.from(jsonDecode(serverResponse.body)['data']
          ['getEmployee']['payload']);

      debugPrint(jsonMap.toString());

      emit(EmployeeLoaded(response: jsonMap));
    } catch (e) {
      emit(EmployeeError(error: e.toString()));
    }
  }
}
