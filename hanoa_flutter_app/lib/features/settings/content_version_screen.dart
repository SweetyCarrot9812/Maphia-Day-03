import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/providers/app_provider.dart';

/// 콘텐츠 버전 관리 화면 - 개발/관리자용
class ContentVersionScreen extends StatefulWidget {
  const ContentVersionScreen({super.key});

  @override
  State<ContentVersionScreen> createState() => _ContentVersionScreenState();
}

class _ContentVersionScreenState extends State<ContentVersionScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 최신 버전 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().checkContentUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('콘텐츠 버전 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await context.read<AppProvider>().checkContentUpdates();
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 전체 업데이트 카드
              if (appProvider.hasContentUpdates)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.system_update,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '업데이트 사용 가능',
                                style: AppTextStyles.h4.copyWith(
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '새로운 콘텐츠 버전이 있습니다. 최신 기능과 개선사항을 받으려면 업데이트하세요.',
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: appProvider.isLoading ? null : () async {
                              final success = await appProvider.updateAllContent();
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('모든 콘텐츠 업데이트 완료'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: appProvider.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.download),
                            label: Text(appProvider.isLoading ? '업데이트 중...' : '모두 업데이트'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // 마지막 확인 시간
              if (appProvider.lastVersionCheck != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('마지막 확인'),
                    subtitle: Text(
                      _formatDateTime(appProvider.lastVersionCheck!),
                      style: AppTextStyles.caption,
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // 패키지별 버전 정보
              Text(
                '패키지별 버전',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.hanoaNavy,
                ),
              ),
              const SizedBox(height: 8),
              
              ...appProvider.contentVersions.entries.map(
                (entry) => _buildVersionCard(
                  context,
                  entry.key,
                  entry.value,
                  appProvider,
                ),
              ),
              
              if (appProvider.contentVersions.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '버전 정보가 없습니다',
                          style: AppTextStyles.bodyText.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '새로고침을 눌러 최신 정보를 확인하세요',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // 개발자 도구
              Text(
                '개발자 도구',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.hanoaNavy,
                ),
              ),
              const SizedBox(height: 8),
              
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.bug_report),
                      title: const Text('강제 버전 확인'),
                      subtitle: const Text('서버에서 최신 버전 정보를 강제로 가져옵니다'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await appProvider.devForceVersionCheck();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('버전 확인 완료'),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.clear_all),
                      title: const Text('캐시 초기화'),
                      subtitle: const Text('로컬 버전 캐시를 초기화합니다'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showClearCacheDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVersionCard(
    BuildContext context,
    String packageId,
    String version,
    AppProvider appProvider,
  ) {
    final packageName = _getPackageName(packageId);
    final icon = _getPackageIcon(packageId);
    
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(packageName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('현재 버전: $version'),
            Text(
              packageId,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'update':
                final success = await appProvider.updatePackageContent(packageId, version);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$packageName 업데이트 완료')),
                  );
                }
                break;
              case 'rollback':
                _showRollbackDialog(context, packageId, packageName);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'update',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('업데이트'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'rollback',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('롤백'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPackageName(String packageId) {
    switch (packageId) {
      case 'med_content':
        return '의학/간호학';
      case 'lang_content':
        return '언어 학습';
      case 'vocal_content':
        return '보컬 트레이너';
      case 'app_config':
        return '앱 설정';
      case 'feature_flags':
        return 'Feature Flag';
      default:
        return packageId;
    }
  }

  IconData _getPackageIcon(String packageId) {
    switch (packageId) {
      case 'med_content':
        return Icons.medical_services;
      case 'lang_content':
        return Icons.translate;
      case 'vocal_content':
        return Icons.mic;
      case 'app_config':
        return Icons.settings;
      case 'feature_flags':
        return Icons.flag;
      default:
        return Icons.inventory;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showRollbackDialog(BuildContext context, String packageId, String packageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$packageName 롤백'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이전 버전으로 롤백하시겠습니까?'),
            const SizedBox(height: 8),
            Text(
              '롤백할 버전: v2025.08',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '롤백 후 일부 기능이 제한될 수 있습니다',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final appProvider = context.read<AppProvider>();
              final success = await appProvider.rollbackPackage(packageId, 'v2025.08');
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$packageName 롤백 완료')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('롤백'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 초기화'),
        content: const Text(
          '로컬 버전 캐시를 초기화하면 모든 콘텐츠를 다시 다운로드해야 합니다.\n\n계속하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 캐시 초기화 로직 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('캐시 초기화 완료')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}