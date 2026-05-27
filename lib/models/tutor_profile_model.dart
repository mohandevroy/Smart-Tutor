class TutorProfileModel {
  final String uid;
  final String fullName;
  final String phone;
  final String email;
  final String profileImage;
  final String gender;
  final String currentLocation;
  final String permanentLocation;
  final String qualification;
  final String universityOrCollege;
  final String department;
  final String yearOrSemester;
  final String cgpaOrResult;
  final List<String> subjects;
  final List<String> preferredClasses;
  final String teachingExperience;
  final String teachingStyle;
  final String expectedSalary;
  final List<String> availableDays;
  final String preferredArea;
  final String medium;
  final String tutoringMode;
  final String bio;
  final String achievements;
  final String documentUrl;
  final String verificationStatus;
  final double guardianRatingAverage;
  final int guardianTotalReviews;
  final double adminRating;
  final String adminStatus;
  final DateTime updatedAt;

  TutorProfileModel({
    required this.uid,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.profileImage,
    required this.gender,
    required this.currentLocation,
    required this.permanentLocation,
    required this.qualification,
    required this.universityOrCollege,
    required this.department,
    required this.yearOrSemester,
    required this.cgpaOrResult,
    required this.subjects,
    required this.preferredClasses,
    required this.teachingExperience,
    required this.teachingStyle,
    required this.expectedSalary,
    required this.availableDays,
    required this.preferredArea,
    required this.medium,
    required this.tutoringMode,
    required this.bio,
    required this.achievements,
    required this.documentUrl,
    required this.verificationStatus,
    required this.guardianRatingAverage,
    required this.guardianTotalReviews,
    required this.adminRating,
    required this.adminStatus,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'profileImage': profileImage,
      'gender': gender,
      'currentLocation': currentLocation,
      'permanentLocation': permanentLocation,
      'qualification': qualification,
      'universityOrCollege': universityOrCollege,
      'department': department,
      'yearOrSemester': yearOrSemester,
      'cgpaOrResult': cgpaOrResult,
      'subjects': subjects,
      'preferredClasses': preferredClasses,
      'teachingExperience': teachingExperience,
      'teachingStyle': teachingStyle,
      'expectedSalary': expectedSalary,
      'availableDays': availableDays,
      'preferredArea': preferredArea,
      'medium': medium,
      'tutoringMode': tutoringMode,
      'bio': bio,
      'achievements': achievements,
      'documentUrl': documentUrl,
      'verificationStatus': verificationStatus,
      'guardianRatingAverage': guardianRatingAverage,
      'guardianTotalReviews': guardianTotalReviews,
      'adminRating': adminRating,
      'adminStatus': adminStatus,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TutorProfileModel.fromMap(Map<String, dynamic> map) {
    return TutorProfileModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'] ?? '',
      gender: map['gender'] ?? '',
      currentLocation: map['currentLocation'] ?? '',
      permanentLocation: map['permanentLocation'] ?? '',
      qualification: map['qualification'] ?? '',
      universityOrCollege: map['universityOrCollege'] ?? '',
      department: map['department'] ?? '',
      yearOrSemester: map['yearOrSemester'] ?? '',
      cgpaOrResult: map['cgpaOrResult'] ?? '',
      subjects: List<String>.from(map['subjects'] ?? []),
      preferredClasses: List<String>.from(map['preferredClasses'] ?? []),
      availableDays: List<String>.from(map['availableDays'] ?? []),
      teachingExperience: map['teachingExperience'] ?? '',
      teachingStyle: map['teachingStyle'] ?? '',
      expectedSalary: map['expectedSalary'] ?? '',
      preferredArea: map['preferredArea'] ?? '',
      medium: map['medium'] ?? '',
      tutoringMode: map['tutoringMode'] ?? '',
      bio: map['bio'] ?? '',
      achievements: map['achievements'] ?? '',
      documentUrl: map['documentUrl'] ?? '',
      verificationStatus: map['verificationStatus'] ?? 'not_submitted',
      guardianRatingAverage:
          (map['guardianRatingAverage'] ?? 0).toDouble(),
      guardianTotalReviews: map['guardianTotalReviews'] ?? 0,
      adminRating: (map['adminRating'] ?? 0).toDouble(),
      adminStatus: map['adminStatus'] ?? 'pending',
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}