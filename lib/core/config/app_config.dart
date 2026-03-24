class AppConfig {
  static const String appName = '고향마켓';
  static const String appDescription = '농어민 AI 직거래 플랫폼';
  static const String appVersion = '1.0.0';

  // 기본 지역 (파일럿)
  static const String defaultRegion = '신안군';
  static const String defaultProvince = '전라남도';

  // 상품 카테고리
  static const List<Map<String, String>> categories = [
    {'key': 'vegetable', 'name': '채소', 'icon': '🥬'},
    {'key': 'fruit', 'name': '과일', 'icon': '🍊'},
    {'key': 'seafood', 'name': '수산물', 'icon': '🐟'},
    {'key': 'grain', 'name': '곡물', 'icon': '🌾'},
    {'key': 'salt', 'name': '천일염', 'icon': '🧂'},
    {'key': 'processed', 'name': '가공식품', 'icon': '🫙'},
    {'key': 'seaweed', 'name': '해조류', 'icon': '🌿'},
    {'key': 'other', 'name': '기타', 'icon': '📦'},
  ];

  // 228개 시군구 중 파일럿 지역
  static const List<Map<String, String>> pilotRegions = [
    {'code': 'sinan', 'name': '신안군', 'province': '전라남도'},
    {'code': 'muan', 'name': '무안군', 'province': '전라남도'},
    {'code': 'mokpo', 'name': '목포시', 'province': '전라남도'},
  ];
}
