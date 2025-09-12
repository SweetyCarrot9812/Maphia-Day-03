import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  String _selectedServer = '집 (기본값)';
  final TextEditingController _customUrlController = TextEditingController();
  
  final Map<String, String> _serverOptions = {
    '집 (기본값)': 'http://172.30.1.36:3001',
    '일터': 'http://192.168.1.100:3001',
    '로컬 개발': 'http://localhost:3001',
    '직접 입력': '',
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentServer();
  }

  Future<void> _loadCurrentServer() async {
    final savedUrl = StorageService.getString('server_url');
    if (savedUrl != null) {
      // 저장된 URL과 일치하는 옵션 찾기
      final matchedKey = _serverOptions.entries
          .firstWhere((entry) => entry.value == savedUrl, 
                     orElse: () => const MapEntry('직접 입력', ''))
          .key;
      
      setState(() {
        if (matchedKey == '직접 입력') {
          _selectedServer = '직접 입력';
          _customUrlController.text = savedUrl;
        } else {
          _selectedServer = matchedKey;
        }
      });
    }
  }

  Future<void> _saveServerConfig() async {
    String serverUrl;
    
    if (_selectedServer == '직접 입력') {
      if (_customUrlController.text.isEmpty) {
        _showErrorDialog('서버 URL을 입력해주세요');
        return;
      }
      serverUrl = _customUrlController.text.trim();
      
      // URL 형식 검증
      if (!serverUrl.startsWith('http://') && !serverUrl.startsWith('https://')) {
        serverUrl = 'http://$serverUrl';
      }
    } else {
      serverUrl = _serverOptions[_selectedServer]!;
    }

    try {
      await StorageService.setString('server_url', serverUrl);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('서버 설정이 저장되었습니다. 앱을 재시작하면 적용됩니다.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 2초 후 자동으로 뒤로 가기
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      _showErrorDialog('설정 저장 실패: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('서버 설정'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '사용할 서버를 선택하세요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            
            // 서버 옵션 라디오 버튼
            Expanded(
              child: ListView(
                children: _serverOptions.keys.map((serverName) {
                  return Card(
                    child: RadioListTile<String>(
                      title: Text(serverName),
                      subtitle: _serverOptions[serverName]!.isNotEmpty
                          ? Text(
                              _serverOptions[serverName]!,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            )
                          : null,
                      value: serverName,
                      groupValue: _selectedServer,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedServer = value!;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // 직접 입력 필드
            if (_selectedServer == '직접 입력') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customUrlController,
                decoration: const InputDecoration(
                  labelText: '서버 URL',
                  hintText: '예: 192.168.1.100:3001',
                  border: OutlineInputBorder(),
                  prefixText: 'http://',
                ),
                keyboardType: TextInputType.url,
              ),
            ],
            
            const SizedBox(height: 24),
            
            // 저장 버튼
            ElevatedButton(
              onPressed: _saveServerConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '설정 저장',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 설명 텍스트
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                '💡 팁:\n'
                '• 집에서 사용: 집 (기본값) 선택\n'
                '• 일터에서 사용: 일터 선택 후 실제 IP로 수정 필요\n'
                '• 설정 변경 후 앱을 완전히 종료했다가 다시 실행하세요',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }
}