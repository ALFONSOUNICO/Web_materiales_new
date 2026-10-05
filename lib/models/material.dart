class MaterialSap {
  final String matnr;
  final String ersda;
  final String ernam;
  final List<VbapPosition> vbap;

  MaterialSap({
    required this.matnr,
    required this.ersda,
    required this.ernam,
    required this.vbap,
  });

  factory MaterialSap.fromJson(Map<String, dynamic> json) {
    return MaterialSap(
      matnr: json['MATNR']?.toString() ?? '',
      ersda: json['ERSDA']?.toString() ?? '',
      ernam: json['ERNAM']?.toString() ?? '',
      vbap: (json['VBAP'] as List<dynamic>? ?? [])
          .map(
            (item) => VbapPosition.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class VbapPosition {
  final String vbeln;
  final int posnr;
  final String matnr;
  final double wavwr;
  final double mwsbp;
  final String erdat;
  final String ernam;

  VbapPosition({
    required this.vbeln,
    required this.posnr,
    required this.matnr,
    required this.wavwr,
    required this.mwsbp,
    required this.erdat,
    required this.ernam,
  });

  factory VbapPosition.fromJson(Map<String, dynamic> json) {
    return VbapPosition(
      vbeln: json['VBELN']?.toString() ?? '',
      posnr: int.tryParse(json['POSNR']?.toString() ?? '0') ?? 0,
      matnr: json['MATNR']?.toString() ?? '',
      wavwr: double.tryParse(json['WAVWR']?.toString() ?? '0') ?? 0,
      mwsbp: double.tryParse(json['MWSBP']?.toString() ?? '0') ?? 0,
      erdat: json['ERDAT']?.toString() ?? '',
      ernam: json['ERNAM']?.toString() ?? '',
    );
  }
}

class MaterialResponse {
  final int total;
  final int pageSize;
  final int offset;
  final String fechaDesde;
  final String fechaHasta;
  final List<MaterialSap> materiales;
  final String message;

  MaterialResponse({
    required this.total,
    required this.pageSize,
    required this.offset,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.materiales,
    required this.message,
  });

  factory MaterialResponse.fromJson(Map<String, dynamic> json) {
    return MaterialResponse(
      total: int.tryParse(json['TOTAL']?.toString() ?? '0') ?? 0,
      pageSize: int.tryParse(json['PAGE_SIZE']?.toString() ?? '0') ?? 0,
      offset: int.tryParse(json['OFFSET']?.toString() ?? '0') ?? 0,
      fechaDesde: json['FECHA_DESDE']?.toString() ?? '',
      fechaHasta: json['FECHA_HASTA']?.toString() ?? '',
      materiales: (json['MATERIALES'] as List<dynamic>? ?? [])
          .map(
            (item) => MaterialSap.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      message: json['MESSAGE']?.toString() ?? '',
    );
  }
}