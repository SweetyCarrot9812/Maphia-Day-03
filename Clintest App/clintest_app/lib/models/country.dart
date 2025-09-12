enum CountryCode {
  US('US', '미국', '🇺🇸'),
  UK('UK', '영국', '🇬🇧'),
  CA('CA', '캐나다', '🇨🇦'),
  AU('AU', '호주', '🇦🇺'),
  KR('KR', '대한민국', '🇰🇷'),
  JP('JP', '일본', '🇯🇵'),
  DE('DE', '독일', '🇩🇪'),
  FR('FR', '프랑스', '🇫🇷'),
  ES('ES', '스페인', '🇪🇸'),
  IT('IT', '이탈리아', '🇮🇹'),
  NL('NL', '네덜란드', '🇳🇱'),
  SE('SE', '스웨덴', '🇸🇪'),
  NO('NO', '노르웨이', '🇳🇴'),
  DK('DK', '덴마크', '🇩🇰'),
  SG('SG', '싱가포르', '🇸🇬'),
  CN('CN', '중국', '🇨🇳'),
  IN('IN', '인도', '🇮🇳'),
  BR('BR', '브라질', '🇧🇷'),
  MX('MX', '멕시코', '🇲🇽'),
  OTHER('OTHER', '기타', '🌍');

  const CountryCode(this.code, this.name, this.flag);
  
  final String code;
  final String name;
  final String flag;
  
  String get displayName => '$flag $name';
  
  static CountryCode fromCode(String code) {
    return CountryCode.values.firstWhere(
      (country) => country.code == code,
      orElse: () => CountryCode.OTHER,
    );
  }
}

enum LabelLocale {
  ko('ko', '한국어', '한국의 의료 용어와 표준 사용'),
  en('en', 'English', 'International medical terminology'),
  ja('ja', '日本語', '日本の医療用語基準'),
  zhCN('zh-CN', '简体中文', '中国医疗术语标准'),
  zhTW('zh-TW', '繁體中文', '台灣醫療術語標準'),
  de('de', 'Deutsch', 'Deutsche medizinische Terminologie'),
  fr('fr', 'Français', 'Terminologie médicale française'),
  es('es', 'Español', 'Terminología médica española'),
  pt('pt', 'Português', 'Terminologia médica portuguesa'),
  it('it', 'Italiano', 'Terminologia medica italiana'),
  nl('nl', 'Nederlands', 'Nederlandse medische terminologie'),
  sv('sv', 'Svenska', 'Svensk medicinsk terminologi'),
  no('no', 'Norsk', 'Norsk medisinsk terminologi'),
  da('da', 'Dansk', 'Dansk medicinsk terminologi');

  const LabelLocale(this.code, this.name, this.description);
  
  final String code;
  final String name;
  final String description;
  
  String get displayName => '$name ($code)';
  
  static LabelLocale fromCode(String code) {
    return LabelLocale.values.firstWhere(
      (locale) => locale.code == code,
      orElse: () => LabelLocale.en,
    );
  }
}