import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A simple floating development button that appears only in debug mode
/// Positioned in the top-right corner for quick access to dev tools
class FloatingDevButton extends StatefulWidget {
  const FloatingDevButton({super.key});

  @override
  State<FloatingDevButton> createState() => _FloatingDevButtonState();
}

class _FloatingDevButtonState extends State<FloatingDevButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _triggerHotReload() {
    // Provide visual feedback since actual hot reload is handled by Flutter's dev server
    _showSnackBar('🔥 Hot Reload Triggered');
    
    // Trigger haptic feedback (if available)
    HapticFeedback.lightImpact();
    
    // Close the expanded menu
    if (_isExpanded) {
      _toggleMenu();
    }
  }

  void _showInspector() {
    _showSnackBar('🔍 Flutter Inspector (check IDE)');
    if (_isExpanded) {
      _toggleMenu();
    }
  }

  void _clearCache() {
    _showSnackBar('🗑️ Cache Cleared (simulated)');
    if (_isExpanded) {
      _toggleMenu();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 80,
          left: 16,
          right: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 60, // Below the title bar
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expanded menu items
          if (_isExpanded) ...[
            ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DevActionButton(
                    icon: Icons.refresh,
                    label: 'Hot Reload',
                    color: Colors.orange,
                    onPressed: _triggerHotReload,
                  ),
                  const SizedBox(height: 8),
                  _DevActionButton(
                    icon: Icons.bug_report,
                    label: 'Inspector',
                    color: Colors.purple,
                    onPressed: _showInspector,
                  ),
                  const SizedBox(height: 8),
                  _DevActionButton(
                    icon: Icons.clear_all,
                    label: 'Clear Cache',
                    color: Colors.red,
                    onPressed: _clearCache,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
          
          // Main floating button
          FloatingActionButton(
            mini: true,
            heroTag: "dev_button",
            backgroundColor: _isExpanded 
                ? Colors.red.shade400 
                : Colors.blue.shade600,
            foregroundColor: Colors.white,
            elevation: 6,
            onPressed: _toggleMenu,
            tooltip: _isExpanded ? 'Close Dev Tools' : 'Open Dev Tools',
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isExpanded ? Icons.close : Icons.developer_mode,
                key: ValueKey(_isExpanded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom button for development actions
class _DevActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DevActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}