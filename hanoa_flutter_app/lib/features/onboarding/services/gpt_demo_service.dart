import 'dart:math';
import '../models/onboarding_models.dart';
import '../../../core/constants/app_constants.dart';

/// GPT 집사 데모 서비스 (실제 API 없이 시뮬레이션)
class GPTDemoService {
  static const _botMessages = {
    OnboardingStep.greeting: [
      "안녕하세요! 저는 Hanoa의 집사 AI입니다 😊\n\n오늘부터 여러분의 학습 여정을 함께하게 될 텐데요, 먼저 서로 알아가는 시간을 가져볼까요?\n\n시작하기 전에, 어떻게 불러드리면 될까요?",
      "Hanoa에 오신 것을 환영합니다! ✨\n\n저는 여러분의 학습을 도와드릴 AI 집사예요. 앞으로 함께 멋진 여행을 떠나게 될 것 같아서 벌써 설레네요!\n\n자, 그럼 먼저 이름부터 알려주시겠어요?",
    ],
    OnboardingStep.name: [
      "반갑습니다! 멋진 이름이네요 👋\n\nHanoa는 여러 가지 학습 분야를 제공하는데, 어떤 분야에 가장 관심이 있으신가요?\n\n지금은 '공부' 분야가 준비되어 있어요!",
      "좋은 이름이에요! 😄\n\n이제 본격적으로 시작해볼까요? Hanoa에서는 다양한 학습 패키지를 제공하는데, 현재는 '공부' 분야가 가장 충실하게 준비되어 있어요.\n\n어떠세요, 관심 있으신가요?",
    ],
    OnboardingStep.package: [
      "좋은 선택이에요! 📚\n\n'공부' 분야에는 여러 세부 영역이 있는데, 특히 어떤 분야에 관심이 있으신지 알려주시겠어요?\n\n현재 준비된 분야들을 보여드릴게요!",
      "훌륭해요! 🎯\n\n공부 분야를 선택해주셨네요. 이제 조금 더 구체적으로 들어가 보죠. 어떤 세부 분야에서 학습하고 싶으신가요?\n\n아래에서 선택해주세요!",
    ],
    OnboardingStep.studyField: [
      "정말 좋은 분야네요! 🏥📖\n\n학습을 더 효과적으로 도와드리기 위해 알림 설정을 해보는 건 어떨까요?\n\n매일 일정한 시간에 학습 알림을 받으시면 꾸준히 공부하는 데 도움이 될 거예요!",
      "완벽한 선택입니다! ⭐\n\n이제 학습을 지속할 수 있도록 도와드리고 싶어요. 알림 기능을 활용하시면 매일 규칙적으로 학습할 수 있어요.\n\n알림을 받고 싶은 시간이 있나요?",
    ],
    OnboardingStep.notifications: [
      "좋아요! 꾸준한 학습 습관을 만드는 데 도움이 될 거예요 ⏰\n\n마지막으로 지역 설정을 확인해볼까요? 현재 한국으로 설정되어 있는데, 맞나요?\n\n지역에 맞는 콘텐츠와 시간대를 제공해드리려고 해요!",
      "완벽해요! 시간 관리의 달인이 되실 것 같아요 ⌚\n\n이제 거의 다 끝났어요! 지역 설정만 확인하면 되는데, 현재 대한민국으로 설정되어 있어요.\n\n이대로 진행해도 될까요?",
    ],
    OnboardingStep.location: [
      "네, 확인되었어요! 🌍\n\n마지막 단계예요. Hanoa에서 더 나은 학습 경험을 제공하기 위해 학습 데이터를 수집하고 분석하려고 해요.\n\n물론 모든 데이터는 안전하게 암호화되어 보관되니 안심하세요! 동의해주시겠어요?",
      "지역 설정 완료! 🗺️\n\n이제 정말 마지막이에요! 개인화된 학습 경험을 위해 학습 패턴과 진도를 분석하려고 하는데요.\n\n개인정보는 철저히 보호되며, 학습 개선 목적으로만 사용됩니다. 동의하시나요?",
    ],
    OnboardingStep.consent: [
      "감사합니다! 🙏\n\n이제 모든 설정이 완료되었어요! 정리해드릴게요:\n\n✨ 설정하신 내용들이 모두 완벽해요!\n\n준비가 되셨다면, 반짝이는 새로운 Hanoa의 세계로 들어가보실까요?",
      "훌륭해요! 모든 준비가 완료되었습니다! 🎉\n\n지금까지 설정해주신 내용들을 바탕으로 맞춤형 학습 환경을 준비했어요.\n\n그럼 이제... 여러분만의 특별한 Hanoa 여행을 시작해볼까요? ✨",
    ],
  };

  static const _quickReplies = {
    OnboardingStep.greeting: ['이름 입력하기'],
    OnboardingStep.name: ['공부'],
    OnboardingStep.package: ['공부 선택'],
    OnboardingStep.studyField: ['의학 및 간호학', '언어'],
    OnboardingStep.notifications: ['알림 받기', '나중에 설정'],
    OnboardingStep.location: ['한국 맞음', '다른 지역'],
    OnboardingStep.consent: ['동의합니다', '더 알아보기'],
    OnboardingStep.summary: ['시작하기!', '다시 수정'],
  };

  /// GPT 집사 메시지 생성 (데모용)
  static Future<ChatMessage> getBotMessage(
    OnboardingStep step, {
    String? userName,
    OnboardingData? currentData,
  }) async {
    // API 호출 시뮬레이션 (실제로는 GPT API 호출)
    await Future.delayed(const Duration(milliseconds: 800));

    final messages = _botMessages[step] ?? ['안녕하세요!'];
    final randomMessage = messages[Random().nextInt(messages.length)];
    
    // 사용자 이름이 있을 때 개인화
    String personalizedMessage = randomMessage;
    if (userName != null && userName.isNotEmpty) {
      personalizedMessage = personalizedMessage.replaceAll('여러분', '${userName}님');
    }

    // 특별한 경우 처리
    if (step == OnboardingStep.summary && currentData != null) {
      personalizedMessage = _generateSummaryMessage(currentData);
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: personalizedMessage,
      isFromBot: true,
      timestamp: DateTime.now(),
      step: step,
      quickReplies: _quickReplies[step],
    );
  }

  /// 사용자 응답 처리 (데모용)
  static Future<ChatMessage> processUserResponse(
    String userInput,
    OnboardingStep currentStep,
    OnboardingData currentData,
  ) async {
    // API 처리 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 300));

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userInput,
      isFromBot: false,
      timestamp: DateTime.now(),
      step: currentStep,
    );
  }

  /// 사용자 입력 검증 (데모용)
  static String? validateUserInput(String input, OnboardingStep step) {
    switch (step) {
      case OnboardingStep.name:
        if (input.trim().isEmpty) {
          return '이름을 입력해주세요';
        }
        if (input.trim().length > AppConstants.maxNameLength) {
          return '이름이 너무 길어요 (${AppConstants.maxNameLength}자 이내)';
        }
        break;
        
      case OnboardingStep.notifications:
        if (input.contains(':')) {
          final parts = input.split(':');
          if (parts.length != 2) {
            return '시간 형식이 올바르지 않아요 (예: 07:30)';
          }
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour == null || minute == null || 
              hour < 0 || hour > 23 || minute < 0 || minute > 59) {
            return '올바른 시간을 입력해주세요 (00:00 ~ 23:59)';
          }
        }
        break;
        
      default:
        break;
    }
    
    return null; // 검증 통과
  }

  /// 시간 포맷 자동 보정
  static String? autoCorrectTime(String input) {
    // 숫자만 입력된 경우
    if (RegExp(r'^\d{3,4}$').hasMatch(input)) {
      if (input.length == 3) {
        // 730 -> 07:30
        return '0${input[0]}:${input.substring(1)}';
      } else {
        // 0730 -> 07:30
        return '${input.substring(0, 2)}:${input.substring(2)}';
      }
    }
    
    // 점으로 구분된 경우
    if (input.contains('.')) {
      return input.replaceAll('.', ':');
    }
    
    // 공백으로 구분된 경우
    if (input.contains(' ')) {
      return input.replaceAll(' ', ':');
    }
    
    return null;
  }

  /// 요약 메시지 생성
  static String _generateSummaryMessage(OnboardingData data) {
    final name = data.displayName ?? '사용자';
    final field = data.studyField ?? '선택된 분야';
    final time = data.notificationTime ?? '설정된 시간';
    
    return '''정말 멋져요, $name님! 🎉

설정해주신 내용을 정리해드릴게요:

📚 관심 분야: $field
⏰ 알림 시간: $time에 매일
🌍 지역: 대한민국
✅ 데이터 수집 동의 완료

모든 준비가 끝났어요! 이제 $name님만의 특별한 학습 여정이 시작됩니다.

준비되셨나요? ✨''';
  }

  /// 온보딩 데이터 업데이트
  static OnboardingData updateDataFromResponse(
    OnboardingData currentData,
    String userInput,
    OnboardingStep step,
  ) {
    switch (step) {
      case OnboardingStep.name:
        return OnboardingData(
          displayName: userInput.trim(),
          preferredPackage: currentData.preferredPackage,
          studyField: currentData.studyField,
          notificationsEnabled: currentData.notificationsEnabled,
          notificationTime: currentData.notificationTime,
          languageCode: currentData.languageCode,
          countryCode: currentData.countryCode,
          dataConsentGiven: currentData.dataConsentGiven,
        );
        
      case OnboardingStep.package:
        return OnboardingData(
          displayName: currentData.displayName,
          preferredPackage: AppConstants.moduleStudyId,
          studyField: currentData.studyField,
          notificationsEnabled: currentData.notificationsEnabled,
          notificationTime: currentData.notificationTime,
          languageCode: currentData.languageCode,
          countryCode: currentData.countryCode,
          dataConsentGiven: currentData.dataConsentGiven,
        );
        
      case OnboardingStep.studyField:
        String field = userInput.contains('의학') || userInput.contains('간호') 
            ? AppConstants.defaultStudyField 
            : '언어';
        return OnboardingData(
          displayName: currentData.displayName,
          preferredPackage: currentData.preferredPackage,
          studyField: field,
          notificationsEnabled: currentData.notificationsEnabled,
          notificationTime: currentData.notificationTime,
          languageCode: currentData.languageCode,
          countryCode: currentData.countryCode,
          dataConsentGiven: currentData.dataConsentGiven,
        );
        
      case OnboardingStep.notifications:
        bool enabled = !userInput.contains('나중에');
        String? time = enabled ? 
            (autoCorrectTime(userInput) ?? userInput.trim()) : 
            AppConstants.defaultAlarmTime;
        return OnboardingData(
          displayName: currentData.displayName,
          preferredPackage: currentData.preferredPackage,
          studyField: currentData.studyField,
          notificationsEnabled: enabled,
          notificationTime: time,
          languageCode: currentData.languageCode,
          countryCode: currentData.countryCode,
          dataConsentGiven: currentData.dataConsentGiven,
        );
        
      case OnboardingStep.location:
        return OnboardingData(
          displayName: currentData.displayName,
          preferredPackage: currentData.preferredPackage,
          studyField: currentData.studyField,
          notificationsEnabled: currentData.notificationsEnabled,
          notificationTime: currentData.notificationTime,
          languageCode: 'ko',
          countryCode: 'KR',
          dataConsentGiven: currentData.dataConsentGiven,
        );
        
      case OnboardingStep.consent:
        bool consent = userInput.contains('동의') || userInput.contains('네');
        return OnboardingData(
          displayName: currentData.displayName,
          preferredPackage: currentData.preferredPackage,
          studyField: currentData.studyField,
          notificationsEnabled: currentData.notificationsEnabled,
          notificationTime: currentData.notificationTime,
          languageCode: currentData.languageCode,
          countryCode: currentData.countryCode,
          dataConsentGiven: consent,
        );
        
      default:
        return currentData;
    }
  }
}