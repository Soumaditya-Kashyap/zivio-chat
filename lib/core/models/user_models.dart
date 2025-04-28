// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModels {
  final String? uid;
  final String? name;
  final String? email;
  final String? imageUrl;
  final Map<String, dynamic>? lastMessage;
  final int? unreadCounter;
  final List<String>? nameSearch;

  UserModels({
    this.uid,
    this.name,
    this.email,
    this.imageUrl,
    this.lastMessage,
    this.unreadCounter,
    this.nameSearch,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'lastMessage': lastMessage,
      'unreadCounter': unreadCounter,
      'nameSearch': nameSearch ?? generateSearchKeywords(name ?? ''),
    };
  }

  factory UserModels.fromMap(Map<String, dynamic> map) {
    return UserModels(
      uid: map['uid'] != null ? map['uid'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      lastMessage: map['lastMessage'] != null
          ? Map<String, dynamic>.from(
              (map['lastMessage'] as Map<String, dynamic>))
          : null,
      unreadCounter:
          map['unreadCounter'] != null ? map['unreadCounter'] as int : null,
      nameSearch: map['nameSearch'] != null
          ? List<String>.from(map['nameSearch'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModels.fromJson(String source) =>
      UserModels.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModels(uid: $uid, name: $name, email: $email, imageUrl: $imageUrl, lastMessage: $lastMessage, unreadCounter: $unreadCounter, nameSearch: $nameSearch)';
  }

  // Generate searchable keywords from name
  static List<String> generateSearchKeywords(String name) {
    List<String> keywords = [];
    String nameLower = name.toLowerCase();

    // Generate keywords for each letter prefix
    for (int i = 1; i <= nameLower.length; i++) {
      keywords.add(nameLower.substring(0, i));
    }

    // Add individual words as keywords
    List<String> words = nameLower.split(' ');
    for (String word in words) {
      if (word.isNotEmpty) {
        for (int i = 1; i <= word.length; i++) {
          String subWord = word.substring(0, i);
          if (!keywords.contains(subWord)) {
            keywords.add(subWord);
          }
        }
      }
    }

    return keywords;
  }
}
