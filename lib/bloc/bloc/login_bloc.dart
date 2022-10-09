import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    final FlutterAppAuth appAuth = const FlutterAppAuth();
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

    const AUTH0_DOMAIN = 'dev-c6ifmg1x.us.auth0.com';
    const AUTH0_CLIENT_ID = '8wiPGLR8LKvj3bffhd3uzIvjngLmVd3k';
    const AUTH0_REDIRECT_URI = 'com.paablowski.authdemo://login-callback';
    const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';
    on<LoginPressed>((event, emit) async {
      emit(LoginInProgress());

      AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AUTH0_CLIENT_ID,
          AUTH0_REDIRECT_URI,
          issuer: 'https://$AUTH0_DOMAIN',
          scopes: ['openid', 'profile', 'offline_access'],
          // promptValues: ['login']
        ),
      );

      final idToken = parseIdToken(result.idToken);
      final profile = await getUserDetails(result.accessToken);

      print("id Token : $idToken['name']");
      print("picture : $profile['picture']");

      // await secureStorage.write(
      //     key: 'refresh_token', value: result!.refreshToken);

      emit(LoggedInSuccessful());
    });
  }

  Map<String, dynamic> parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }

  Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
    final url = Uri.parse("https://dev-c6ifmg1x.us.auth0.com/userinfo");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }
}
