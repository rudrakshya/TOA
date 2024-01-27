class SaveReturn {
  final int status;
  final bool res;
  final String lastId;

  SaveReturn({
    required this.status,
    required this.res,
    required this.lastId,
  });

  factory SaveReturn.fromJson(Map<String, dynamic> json) {
    return SaveReturn(
      status: json['status'],
      res: json['res'],
      lastId: json['last_id'],
    );
  }
}
