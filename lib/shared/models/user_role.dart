enum UserRole {
  unauthenticated,
  ambulanceCrew,
  hospitalStaff,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.unauthenticated:
        return 'Not Signed In';
      case UserRole.ambulanceCrew:
        return 'Ambulance Crew';
      case UserRole.hospitalStaff:
        return 'Hospital Staff';
      case UserRole.admin:
        return 'System Admin';
    }
  }

  bool get isAmbulance => this == UserRole.ambulanceCrew;
  bool get isHospital => this == UserRole.hospitalStaff;
  bool get isAuthenticated => this != UserRole.unauthenticated;
}
