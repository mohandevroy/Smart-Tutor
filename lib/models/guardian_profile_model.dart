class GuardianProfileModel {
  final String uid;
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final String area;
  final String city;
  final String childName;
  final String childClass;
  final List<String> preferredSubjects;
  final String preferredTutorGender;
  final String preferredTutorType;
  final String budgetRange;
  final String preferredSchedule;
  final String notes;
  final String adminStatus;
  final DateTime updatedAt;

  GuardianProfileModel({
    required this.uid,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.address,
    required this.area,
    required this.city,
    required this.childName,
    required this.childClass,
    required this.preferredSubjects,
    required this.preferredTutorGender,
    required this.preferredTutorType,
    required this.budgetRange,
    required this.preferredSchedule,
    required this.notes,
    required this.adminStatus,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'address': address,
      'area': area,
      'city': city,
      'childName': childName,
      'childClass': childClass,
      'preferredSubjects': preferredSubjects,
      'preferredTutorGender': preferredTutorGender,
      'preferredTutorType': preferredTutorType,
      'budgetRange': budgetRange,
      'preferredSchedule': preferredSchedule,
      'notes': notes,
      'adminStatus': adminStatus,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GuardianProfileModel.fromMap(Map<String, dynamic> map) {
    return GuardianProfileModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      area: map['area'] ?? '',
      city: map['city'] ?? '',
      childName: map['childName'] ?? '',
      childClass: map['childClass'] ?? '',
      preferredSubjects: List<String>.from(map['preferredSubjects'] ?? []),
      preferredTutorGender: map['preferredTutorGender'] ?? '',
      preferredTutorType: map['preferredTutorType'] ?? '',
      budgetRange: map['budgetRange'] ?? '',
      preferredSchedule: map['preferredSchedule'] ?? '',
      notes: map['notes'] ?? '',
      adminStatus: map['adminStatus'] ?? 'pending',
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}