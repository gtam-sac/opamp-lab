class ExperimentSession {
  final int? id;
  final String experimentType;
  final String waveformType;
  final double resistanceOhm;
  final double capacitanceF;
  final double amplitudeV;
  final double frequencyHz;
  final String? notes;
  final DateTime? createdAt;

  const ExperimentSession({
    required this.id,
    required this.experimentType,
    required this.waveformType,
    required this.resistanceOhm,
    required this.capacitanceF,
    required this.amplitudeV,
    required this.frequencyHz,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toRequestJson() => {
        'experimentType': experimentType,
        'waveformType': waveformType,
        'resistanceOhm': resistanceOhm,
        'capacitanceF': capacitanceF,
        'amplitudeV': amplitudeV,
        'frequencyHz': frequencyHz,
        if (notes != null) 'notes': notes,
      };

  factory ExperimentSession.fromJson(Map<String, dynamic> json) {
    return ExperimentSession(
      id: (json['id'] as num?)?.toInt(),
      experimentType: json['experiment_type'] as String,
      waveformType: json['waveform_type'] as String,
      resistanceOhm: (json['resistance_ohm'] as num).toDouble(),
      capacitanceF: (json['capacitance_f'] as num).toDouble(),
      amplitudeV: (json['amplitude_v'] as num).toDouble(),
      frequencyHz: (json['frequency_hz'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
