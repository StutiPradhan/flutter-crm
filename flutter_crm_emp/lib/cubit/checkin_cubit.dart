import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@immutable
sealed class CheckinState {}

class CheckinInitial extends CheckinState {}

class CheckinLoading extends CheckinState {}

class CheckinLoaded extends CheckinState {
  CheckinLoaded({required this.response});

  final dynamic response;
}

class CheckinError extends CheckinState {
  CheckinError({required this.error});

  final String error;
}

class CheckinCubit extends Cubit<CheckinState> {
  CheckinCubit() : super(CheckinInitial());

  Future<void> uploadCheckin(List<String> geoJson) async {
    try {
      emit(CheckinLoading());

      final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();

      final serverResponse = await http.post(
          Uri.parse("https://lipsum.smalltowntalks.com/v1/crm/graphql"),
          body: geoJson,
          headers: {HttpHeaders.contentTypeHeader: "application/json", HttpHeaders.authorizationHeader: "Bearer ${sharedPrefs.getString("jwt")}"});

      emit(CheckinLoaded(response: serverResponse));
    } catch (e) {
      emit(CheckinError(error: e.toString()));
    }
  }
}
