class Disease {
  final String url;
  final Identification identification;

  Disease({
    required this.url,
    required this.identification,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      url: json['url'] as String,
      identification: Identification.fromJson(
          json['identification'] as Map<String, dynamic>),
    );
  }
}

class Identification {
  final String name;
  final String description;
  final List<Symptom> symptoms;
  final String severity;
  final Treatment treatment;

  Identification({
    required this.name,
    required this.description,
    required this.symptoms,
    required this.severity,
    required this.treatment,
  });

  factory Identification.fromJson(Map<String, dynamic> json) {
    return Identification(
      name: json['name'] as String,
      description: json['description'] as String,
      symptoms: (json['symptoms'] as List)
          .map((symptom) => Symptom.fromJson(symptom as Map<String, dynamic>))
          .toList(),
      severity: json['severity'] as String,
      treatment: Treatment.fromJson(json['treatment'] as Map<String, dynamic>),
    );
  }
}

class Symptom {
  final String title;
  final String description;

  Symptom({
    required this.title,
    required this.description,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    // Since the symptom is structured as {"title": "description"}
    final entry = json.entries.first;
    return Symptom(
      title: entry.key,
      description: entry.value as String,
    );
  }
}

class Treatment {
  final List<String> prevention;
  final List<String> chemical;
  final List<String> biological;

  Treatment({
    required this.prevention,
    required this.chemical,
    required this.biological,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      prevention: List<String>.from(json['prevention'] as List),
      chemical: List<String>.from(json['chemical'] as List),
      biological: List<String>.from(json['biological'] as List),
    );
  }
}
