class AdminVariables {
  num? convinienceFee;
  num? installmentDuration;
  List<String>? categories;
  List<String>? brands;
  num? expiredFee;
  bool? allowVendors;
  bool? isLive;
  AdminVariablesUpdates? updates;

  AdminVariables({
    this.brands,
    this.categories,
    this.convinienceFee,
    this.expiredFee,
    this.installmentDuration,
    this.allowVendors,
    this.isLive,
    this.updates,
  });

  factory AdminVariables.fromJson(Map<String, dynamic> json) => AdminVariables(
        categories: List.from(json["categories"], growable: true),
        brands: json["brands"] != null
            ? List.from(json["brands"], growable: true)
            : [],
        convinienceFee: json["convenience fee"],
        expiredFee: json["expired fee"],
        installmentDuration: json["installment duration"],
        allowVendors: json["allow vendors"],
        isLive: json["isLive"],
        updates: json["updates"] != null
            ? AdminVariablesUpdates.fromJson(json["updates"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "categories": categories!.toList(),
        "convenience fee": convinienceFee,
        "brands": brands!.toList(),
        "expired fee": expiredFee,
        "isLive": isLive,
        "installment duration": installmentDuration,
        "allow vendors": allowVendors,
        "updates": updates?.toJson(),
      };
}

class AdminVariablesUpdates {
  String? latestVersion;
  bool? isUpdateAvailable;
  bool? isUpdateMandatory;

  AdminVariablesUpdates({
    this.latestVersion,
    this.isUpdateMandatory,
    this.isUpdateAvailable,
  });

  factory AdminVariablesUpdates.fromJson(Map<String, dynamic> json) =>
      AdminVariablesUpdates(
        latestVersion: json["latest version"],
        isUpdateAvailable: json["isUpdate"],
        isUpdateMandatory: json["isUpdateMandatory"],
      );

  Map<String, dynamic> toJson() => {
        "latest version": latestVersion,
        "isUpdate": isUpdateAvailable,
        "isUpdateMandatory": isUpdateMandatory,
      };
}
