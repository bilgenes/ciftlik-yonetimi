class Cow {
  String id;
  String name;
  String tagNumber;
  DateTime birthDate;
  String category;
  String? motherId; // <-- YENİ EKLENDİ
  String? motherName; // <-- YENİ EKLENDİ (UI'da göstermek için)
  String chronicDisease;
  int calfCount;
  String medicalHistory;
  double totalMilkProduced;
  double totalIncome;
  double totalCost;
  String notes;
  String status;

  Cow({
    required this.id,
    required this.name,
    required this.tagNumber,
    required this.birthDate,
    required this.category,
    this.motherId,
    this.motherName,
    this.chronicDisease = 'Yok',
    this.calfCount = 0,
    this.medicalHistory = 'Temiz',
    this.totalMilkProduced = 0.0,
    this.totalIncome = 0.0,
    this.totalCost = 0.0,
    this.notes = '',
    this.status = 'Aktif',
  });

  String get ageString {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      days += 30;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    return '$years Yıl, $months Ay, $days Gün';
  }

  // Yaşını gün olarak veren yardımcı fonksiyon (Hesaplamalar için lazım)
  int get ageInDays {
    return DateTime.now().difference(birthDate).inDays;
  }

  factory Cow.fromJson(Map<String, dynamic> json) {
    return Cow(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'İsimsiz',
      tagNumber: json['tag_number'] ?? '',
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : DateTime.now(),
      category: json['category'] ?? 'Diğer',
      motherId: json['mother_id']?.toString(), // <-- YENİ EKLENDİ
      motherName:
          json['mother']?['name'] ??
          json['mother']?['tag_number'], // İlişkiyle gelirse
      chronicDisease: json['chronic_disease'] ?? 'Yok',
      calfCount: json['calf_count'] != null
          ? int.parse(json['calf_count'].toString())
          : 0,
      medicalHistory: json['medical_history'] ?? 'Temiz',
      totalMilkProduced: json['total_milk_produced'] != null
          ? double.parse(json['total_milk_produced'].toString())
          : 0.0,
      totalIncome: json['total_income'] != null
          ? double.parse(json['total_income'].toString())
          : 0.0,
      totalCost: json['total_cost'] != null
          ? double.parse(json['total_cost'].toString())
          : 0.0,
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'Aktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tag_number': tagNumber,
      'birth_date': birthDate.toIso8601String(),
      'category': category,
      'mother_id': motherId, // <-- YENİ EKLENDİ
      'chronic_disease': chronicDisease,
      'calf_count': calfCount,
      'medical_history': medicalHistory,
      'total_milk_produced': totalMilkProduced,
      'total_income': totalIncome,
      'total_cost': totalCost,
      'notes': notes,
      'status': status,
    };
  }
}
