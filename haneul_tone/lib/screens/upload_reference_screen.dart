import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../models/audio_reference.dart';
import '../services/database_service.dart';
import '../services/pitch_analysis_service.dart';

class UploadReferenceScreen extends StatefulWidget {
  const UploadReferenceScreen({super.key});

  @override
  State<UploadReferenceScreen> createState() => _UploadReferenceScreenState();
}

class _UploadReferenceScreenState extends State<UploadReferenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  String? _selectedFilePath;
  String? _fileName;
  String _selectedKey = 'C';
  String _selectedScaleType = 'Major';
  int _selectedOctaves = 1;
  double _selectedA4 = 440.0;
  bool _isUploading = false;
  
  // 음계 옵션
  final List<String> _keys = [
    'C', 'C#/Db', 'D', 'D#/Eb', 'E', 'F', 
    'F#/Gb', 'G', 'G#/Ab', 'A', 'A#/Bb', 'B'
  ];
  
  final List<String> _scaleTypes = ['Major', 'Minor', 'Pentatonic', 'Chromatic'];
  final List<int> _octaveOptions = [1, 2, 3, 4];
  final List<double> _a4Options = [440.0, 442.0, 444.0];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'm4a', 'aac', 'flac'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilePath = file.path;
          _fileName = file.name;
        });
        
        // 파일명에서 자동으로 제목 생성 (확장자 제거)
        if (_titleController.text.isEmpty) {
          final nameWithoutExtension = path.basenameWithoutExtension(file.name);
          _titleController.text = nameWithoutExtension;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('파일 선택 완료: ${file.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('파일 선택 오류: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadReference() async {
    if (!_formKey.currentState!.validate() || _selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 필수 정보를 입력하고 파일을 선택해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // 앱 데이터 디렉토리 가져오기
      final directory = await getApplicationDocumentsDirectory();
      final audioReferencesDir = Directory(path.join(directory.path, 'audio_references'));
      
      if (!await audioReferencesDir.exists()) {
        await audioReferencesDir.create(recursive: true);
      }

      // 파일을 앱 내부 저장소로 복사
      final originalFile = File(_selectedFilePath!);
      final fileExtension = path.extension(_fileName!);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = '${_selectedKey}_${_selectedScaleType}_${_selectedOctaves}oct_$timestamp$fileExtension';
      final newFilePath = path.join(audioReferencesDir.path, newFileName);
      
      await originalFile.copy(newFilePath);

      // 데이터베이스에 메타데이터 저장
      final audioReference = AudioReference(
        title: _titleController.text.trim(),
        filePath: newFilePath,
        key: _selectedKey,
        scaleType: _selectedScaleType,
        octaves: _selectedOctaves,
        a4Freq: _selectedA4,
        createdAt: DateTime.now(),
      );

      final databaseService = DatabaseService();
      final referenceId = await databaseService.insertAudioReference(audioReference);

      // 생성된 AudioReference 객체 (ID 포함)
      final savedReference = audioReference.copyWith(id: referenceId);

      // 피치 분석 수행
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('오디오 분석 중...'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      try {
        final pitchData = await PitchAnalysisService.analyzeAudioFile(
          newFilePath, 
          savedReference
        );

        if (pitchData != null) {
          await databaseService.insertPitchData(pitchData);
          print('피치 분석 완료: ${pitchData.pitchCurve.length}개 포인트');
        } else {
          print('피치 분석 실패');
        }
      } catch (e) {
        print('피치 분석 오류: $e');
      }

      // 성공 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('레퍼런스 오디오 업로드 및 분석이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // 성공 시 이전 화면으로 돌아가기
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('업로드 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('레퍼런스 오디오 업로드'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 메시지
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '업로드 가이드',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 피아노로 녹음한 스케일 파일을 업로드하세요\n'
                        '• 지원 형식: WAV, MP3, M4A, AAC, FLAC\n'
                        '• 정확한 키와 옥타브 정보를 입력해주세요',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 파일 선택
              Text(
                '오디오 파일 선택',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedFilePath != null ? Colors.green : Colors.grey,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickAudioFile,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFilePath != null
                                ? Icons.check_circle
                                : Icons.upload_file,
                            size: 48,
                            color: _selectedFilePath != null
                                ? Colors.green
                                : Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFilePath != null
                                ? _fileName!
                                : '파일 선택하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _selectedFilePath != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedFilePath != null
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                            ),
                          ),
                          if (_selectedFilePath == null)
                            Text(
                              'WAV, MP3, M4A, AAC, FLAC 파일을 선택하세요',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 제목 입력
              Text(
                '제목',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '예: C Major Scale 2 Octaves',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // 음계 설정
              Text(
                '음계 설정',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('키 (Key)'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _selectedKey,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          items: _keys.map((key) {
                            return DropdownMenuItem(
                              value: key,
                              child: Text(key),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKey = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('스케일 타입'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _selectedScaleType,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          items: _scaleTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedScaleType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('옥타브 수'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<int>(
                          value: _selectedOctaves,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          items: _octaveOptions.map((octave) {
                            return DropdownMenuItem(
                              value: octave,
                              child: Text('$octave 옥타브'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOctaves = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('A4 주파수 (Hz)'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<double>(
                          value: _selectedA4,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          items: _a4Options.map((freq) {
                            return DropdownMenuItem(
                              value: freq,
                              child: Text('${freq.toInt()} Hz'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedA4 = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 업로드 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadReference,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUploading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('업로드 중...'),
                          ],
                        )
                      : const Text(
                          '레퍼런스 업로드',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}