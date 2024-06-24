import 'package:diary/models/user_model.dart';

class UserIdMap {
  static final UserIdMap _singleton = UserIdMap._internal();

  factory UserIdMap() {
    return _singleton;
  }

  UserIdMap._internal();

  Map<String, String> _nameToDocumentIdMap = {};

  void updateMap(String email, documentId) {
    _nameToDocumentIdMap[email] = documentId;
  }

  String? getDocumentIdByName(String email) {
    return _nameToDocumentIdMap[email];
  }
}
