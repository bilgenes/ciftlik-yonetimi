class Cow {
  String id;
  String name;
  String tagNumber;
  DateTime birthDate;
  String category;
  String? motherId;
  String? motherName;
  DateTime? pregnancyStartDate;
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
    this.pregnancyStartDate,
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
    if (months < 0) {
      years--;
      months += 12;
    }
    return '$years Yıl, $months Ay';
  }

  int get ageInDays => DateTime.now().difference(birthDate).inDays;

  factory Cow.fromJson(Map<String, dynamic> json) {
    return Cow(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'İsimsiz',
      tagNumber: json['tag_number'] ?? '',
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : DateTime.now(),
      category: json['category'] ?? 'Diğer',
      motherId: json['mother_id']?.toString(),
      motherName: json['mother']?['name'] ?? json['mother']?['tag_number'],
      pregnancyStartDate: json['pregnancy_start_date'] != null
          ? DateTime.parse(json['pregnancy_start_date'])
          : null,
      chronicDisease: json['chronic_disease'] ?? 'Yok',
      calfCount: json['calf_count'] != null
          ? int.parse(json['calf_count'].toString())
          : 0,
      medicalHistory: json['medical_history'] ?? 'Temiz',
      totalMilkProduced:
          double.tryParse(json['total_milk_produced']?.toString() ?? '0') ??
          0.0,
      totalIncome:
          double.tryParse(json['total_income']?.toString() ?? '0') ?? 0.0,
      totalCost: double.tryParse(json['total_cost']?.toString() ?? '0') ?? 0.0,
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'Aktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name, 'tag_number': tagNumber,
      // Laravel'in sevdiği tarih formatı (Y-m-d)
      'birth_date':
          "${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}",
      'category': category, 'mother_id': motherId,
      'pregnancy_start_date': pregnancyStartDate != null
          ? "${pregnancyStartDate!.year}-${pregnancyStartDate!.month.toString().padLeft(2, '0')}-${pregnancyStartDate!.day.toString().padLeft(2, '0')}"
          : null,
      'chronic_disease': chronicDisease, 'calf_count': calfCount,
      'medical_history': medicalHistory,
      'total_milk_produced': totalMilkProduced,
      'total_income': totalIncome,
      'total_cost': totalCost,
      'notes': notes,
      'status': status,
    };
  }
}
