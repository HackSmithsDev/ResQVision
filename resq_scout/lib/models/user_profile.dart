/// A rescuer's profile shown on the Profile page. Kept as plain Dart (no
/// Flutter imports) to match the style of [Mission] and [AIInsight].
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.team,
    required this.sector,
    required this.phone,
    required this.email,
    required this.activeSince,
    required this.missionsCompleted,
    required this.hoursInField,
    this.certifications = const [],
  });

  final String id;
  final String name;
  final String initials;
  final String role;
  final String team;
  final String sector;
  final String phone;
  final String email;

  /// Human readable label, e.g. "Since Mar 2024".
  final String activeSince;
  final int missionsCompleted;
  final int hoursInField;
  final List<String> certifications;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    initials: json['initials'] as String,
    role: json['role'] as String,
    team: json['team'] as String,
    sector: json['sector'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String,
    activeSince: json['activeSince'] as String,
    missionsCompleted: json['missionsCompleted'] as int,
    hoursInField: json['hoursInField'] as int,
    certifications: List<String>.from(
      json['certifications'] as List? ?? const [],
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initials': initials,
    'role': role,
    'team': team,
    'sector': sector,
    'phone': phone,
    'email': email,
    'activeSince': activeSince,
    'missionsCompleted': missionsCompleted,
    'hoursInField': hoursInField,
    'certifications': certifications,
  };
}