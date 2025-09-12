/// 온보딩 관련 모델들
class OnboardingData {
  String? displayName;
  String? preferredPackage;
  String? studyField;
  bool? notificationsEnabled;
  String? notificationTime;
  String? languageCode;
  String? countryCode;
  bool? dataConsentGiven;

  OnboardingData({
    this.displayName,
    this.preferredPackage,
    this.studyField,
    this.notificationsEnabled,
    this.notificationTime,
    this.languageCode,
    this.countryCode,
    this.dataConsentGiven,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'preferredPackage': preferredPackage,
      'studyField': studyField,
      'notificationsEnabled': notificationsEnabled,
      'notificationTime': notificationTime,
      'languageCode': languageCode,
      'countryCode': countryCode,
      'dataConsentGiven': dataConsentGiven,
    };
  }

  bool get isComplete {
    return displayName != null &&
        preferredPackage != null &&
        studyField != null &&
        notificationsEnabled != null &&
        notificationTime != null &&
        languageCode != null &&
        countryCode != null &&
        dataConsentGiven == true;
  }

  double get completionProgress {
    int completed = 0;
    int total = 8;

    if (displayName != null) completed++;
    if (preferredPackage != null) completed++;
    if (studyField != null) completed++;
    if (notificationsEnabled != null) completed++;
    if (notificationTime != null) completed++;
    if (languageCode != null) completed++;
    if (countryCode != null) completed++;
    if (dataConsentGiven == true) completed++;

    return completed / total;
  }
}

/// GPT 집사 대화 턴
enum OnboardingStep {
  greeting(1, '안녕하세요! 👋'),
  name(2, '이름을 알려주세요'),
  package(3, '관심 분야를 선택해주세요'),
  studyField(4, '세부 분야를 선택해주세요'),
  notifications(5, '알림 설정을 해보세요'),
  location(6, '지역 설정을 확인해주세요'),
  consent(7, '개인정보 수집에 동의해주세요'),
  summary(8, '설정을 확인해주세요');

  const OnboardingStep(this.stepNumber, this.title);
  final int stepNumber;
  final String title;

  OnboardingStep? get next {
    switch (this) {
      case OnboardingStep.greeting:
        return OnboardingStep.name;
      case OnboardingStep.name:
        return OnboardingStep.package;
      case OnboardingStep.package:
        return OnboardingStep.studyField;
      case OnboardingStep.studyField:
        return OnboardingStep.notifications;
      case OnboardingStep.notifications:
        return OnboardingStep.location;
      case OnboardingStep.location:
        return OnboardingStep.consent;
      case OnboardingStep.consent:
        return OnboardingStep.summary;
      case OnboardingStep.summary:
        return null;
    }
  }

  OnboardingStep? get previous {
    switch (this) {
      case OnboardingStep.greeting:
        return null;
      case OnboardingStep.name:
        return OnboardingStep.greeting;
      case OnboardingStep.package:
        return OnboardingStep.name;
      case OnboardingStep.studyField:
        return OnboardingStep.package;
      case OnboardingStep.notifications:
        return OnboardingStep.studyField;
      case OnboardingStep.location:
        return OnboardingStep.notifications;
      case OnboardingStep.consent:
        return OnboardingStep.location;
      case OnboardingStep.summary:
        return OnboardingStep.consent;
    }
  }
}

/// GPT 집사 메시지
class ChatMessage {
  final String id;
  final String content;
  final bool isFromBot;
  final DateTime timestamp;
  final OnboardingStep? step;
  final List<String>? quickReplies;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromBot,
    required this.timestamp,
    this.step,
    this.quickReplies,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isFromBot,
    DateTime? timestamp,
    OnboardingStep? step,
    List<String>? quickReplies,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isFromBot: isFromBot ?? this.isFromBot,
      timestamp: timestamp ?? this.timestamp,
      step: step ?? this.step,
      quickReplies: quickReplies ?? this.quickReplies,
    );
  }
}

/// 온보딩 완료 결과
class OnboardingResult {
  final OnboardingData data;
  final bool isSuccess;
  final String? errorMessage;

  OnboardingResult({
    required this.data,
    required this.isSuccess,
    this.errorMessage,
  });
}