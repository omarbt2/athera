// This file is kept for backward compatibility only.
// Use AuthUser from auth_provider.dart instead.
// The User class below is intentionally NOT used anywhere in this codebase.

class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}
