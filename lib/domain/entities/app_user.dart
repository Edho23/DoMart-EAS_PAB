class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String role; // 'customer' atau 'seller'

  AppUser({required this.uid, required this.email, this.name, this.role = 'customer'});
}