import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/dev_tools_service.dart';

class DevToolsWidget extends StatefulWidget {
  final Widget child;

  const DevToolsWidget({
    super.key,
    required this.child,
  });

  @override
  State<DevToolsWidget> createState() => _DevToolsWidgetState();
}

class _DevToolsWidgetState extends State<DevToolsWidget> {
  bool _isExpanded = false;
  DateTime _lastReloadTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // 릴리즈 모드에서는 개발 도구 숨김
    if (!DevToolsService.isDebugMode) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        // 개발자 도구 플로팅 버튼
        Positioned(
          top: 20.h,
          right: 20.w,
          child: _buildDevToolsPanel(),
        ),
      ],
    );
  }

  Widget _buildDevToolsPanel() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isExpanded ? 200.w : 48.w,
        height: _isExpanded ? 140.h : 48.h,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: _isExpanded ? _buildExpandedPanel() : _buildCollapsedButton(),
      ),
    );
  }

  Widget _buildCollapsedButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isExpanded = true;
        });
      },
      icon: Icon(
        Icons.developer_mode,
        color: Colors.orange,
        size: 28.r,
      ),
      tooltip: '개발자 도구',
    );
  }

  Widget _buildExpandedPanel() {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dev Tools',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = false;
                  });
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.r,
                ),
                constraints: BoxConstraints(
                  minWidth: 24.w,
                  minHeight: 24.h,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Hot Reload 버튼
          _buildDevButton(
            icon: Icons.refresh,
            label: 'Hot Reload',
            color: Colors.blue,
            onPressed: () {
              _performHotReload();
            },
          ),
          
          SizedBox(height: 4.h),
          
          // Hot Restart 버튼
          _buildDevButton(
            icon: Icons.restart_alt,
            label: 'Hot Restart',
            color: Colors.orange,
            onPressed: () {
              _performHotRestart();
            },
          ),
          
          SizedBox(height: 4.h),
          
          // 마지막 새로고침 시간
          Text(
            '마지막: ${_formatTime(_lastReloadTime)}',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14.r, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          minimumSize: Size(0, 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  void _performHotReload() {
    setState(() {
      _lastReloadTime = DateTime.now();
    });
    
    DevToolsService.performHotReload();
    
    // 시각적 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Hot Reload 실행됨'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 100.h,
          right: 16.w,
          left: 16.w,
        ),
      ),
    );
  }

  void _performHotRestart() {
    setState(() {
      _lastReloadTime = DateTime.now();
    });
    
    DevToolsService.performHotRestart();
    
    // 시각적 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restart_alt, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Hot Restart 실행됨'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 100.h,
          right: 16.w,
          left: 16.w,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}