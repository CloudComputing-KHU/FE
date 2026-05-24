class FamilyLink {
  const FamilyLink({
    required this.linkId,
    required this.parentUserId,
    required this.childUserId,
    required this.status,
    this.connectedAt,
  });

  final String linkId;
  final String parentUserId;
  final String childUserId;
  final String status;
  final DateTime? connectedAt;

  factory FamilyLink.fromJson(Map<String, dynamic> json) {
    return FamilyLink(
      linkId: _readString(json, const ['link_id', 'linkId']) ?? '',
      parentUserId:
          _readString(json, const ['parent_user_id', 'parentUserId']) ?? '',
      childUserId:
          _readString(json, const ['child_user_id', 'childUserId']) ?? '',
      status: _readString(json, const ['status']) ?? '',
      connectedAt: _readDate(json, const ['connected_at', 'connectedAt']),
    );
  }

  bool get isActive => status == 'active';
}

class FamilyInvite {
  const FamilyInvite({
    required this.inviteCode,
    required this.childUserId,
    required this.status,
    this.createdAt,
    this.expiresAt,
    this.message,
  });

  final String inviteCode;
  final String childUserId;
  final String status;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final String? message;

  factory FamilyInvite.fromJson(Map<String, dynamic> json) {
    return FamilyInvite(
      inviteCode: _readString(json, const ['invite_code', 'inviteCode']) ?? '',
      childUserId:
          _readString(json, const ['child_user_id', 'childUserId']) ?? '',
      status: _readString(json, const ['status']) ?? '',
      createdAt: _readDate(json, const ['created_at', 'createdAt']),
      expiresAt: _readDate(json, const ['expires_at', 'expiresAt']),
      message: _readString(json, const ['message']),
    );
  }

  bool get isPending => status == 'pending';
}

class FamilyMe {
  const FamilyMe({
    required this.userId,
    required this.role,
    this.activeLink,
    this.pendingInvite,
  });

  final String userId;
  final String role;
  final FamilyLink? activeLink;
  final FamilyInvite? pendingInvite;

  factory FamilyMe.fromJson(Map<String, dynamic> json) {
    final activeLinkJson = json['active_link'];
    final pendingInviteJson = json['pending_invite'];
    return FamilyMe(
      userId: _readString(json, const ['user_id', 'userId']) ?? '',
      role: _readString(json, const ['role']) ?? '',
      activeLink: activeLinkJson is Map<String, dynamic>
          ? FamilyLink.fromJson(activeLinkJson)
          : null,
      pendingInvite: pendingInviteJson is Map<String, dynamic>
          ? FamilyInvite.fromJson(pendingInviteJson)
          : null,
    );
  }

  bool get isConnected => activeLink?.isActive == true;
}

class FamilyConnectResult {
  const FamilyConnectResult({this.message, required this.link});

  final String? message;
  final FamilyLink link;

  factory FamilyConnectResult.fromJson(Map<String, dynamic> json) {
    return FamilyConnectResult(
      message: _readString(json, const ['message']),
      link: FamilyLink.fromJson(json),
    );
  }
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
  final value = _readString(json, keys);
  if (value == null) return null;
  return DateTime.tryParse(value)?.toLocal();
}
