# Flutter Desktop Dev Tools Widget

## Overview

A simple, stable Hot Reload developer tools widget designed for Flutter desktop development. This widget provides quick access to common development actions without complex dependencies or experimental APIs.

## Features

### 🎯 Debug Mode Only
- Automatically appears only when `kDebugMode` is true
- Completely hidden in release builds
- No performance impact on production

### 🔧 Development Actions
- **Hot Reload**: Triggers visual feedback for hot reload events
- **Flutter Inspector**: Provides reminder to check IDE for inspector
- **Clear Cache**: Simulates cache clearing with user feedback

### 🎨 User Interface
- **Floating Button**: Positioned in top-right corner (below title bar)
- **Expandable Menu**: Animated menu with smooth transitions
- **Visual Feedback**: SnackBar notifications for all actions
- **Haptic Feedback**: Light haptic feedback on interactions (when available)

## Implementation Details

### Files Created

1. **`lib/shared/widgets/floating_dev_button.dart`**
   - Main widget implementation
   - Uses only stable Flutter APIs (Material, Animation, Foundation)
   - No platform-specific or experimental dependencies

2. **`lib/shared/widgets/app_window_frame.dart` (Modified)**
   - Integrated dev button as overlay using Stack widget
   - Minimal impact on existing layout

### Technical Architecture

#### Widget Structure
```dart
FloatingDevButton
├── Positioned (top-right corner)
├── Column (expandable menu)
│   ├── ScaleTransition (animated menu items)
│   └── FloatingActionButton (main toggle)
└── _DevActionButton (custom action buttons)
```

#### Key Components

1. **Animation Controller**
   - Single ticker animation controller
   - 200ms duration with easeInOut curve
   - Scale animation for smooth menu transitions

2. **State Management**
   - Simple boolean for expanded state
   - Automatic cleanup of animation controller
   - Proper lifecycle management

3. **User Feedback**
   - SnackBar notifications for all actions
   - Haptic feedback integration
   - Visual state changes (button colors)

### API Usage

The widget uses only stable, well-established Flutter APIs:

- `flutter/foundation.dart` - kDebugMode for debug detection
- `flutter/material.dart` - UI components and theming
- `flutter/services.dart` - HapticFeedback for touch feedback
- Standard animation and state management patterns

### Integration

The dev button integrates seamlessly with the existing app structure:

1. **Non-Intrusive**: Uses Stack overlay, doesn't modify existing layout
2. **Responsive**: Positioned relative to title bar
3. **Theme Aware**: Uses Material Design components and system colors
4. **Accessible**: Proper tooltips and semantic labels

## Usage

### Automatic Integration
The dev button automatically appears in debug mode when the app runs. No manual activation required.

### Development Workflow
1. **Hot Reload**: Click main button → Select "Hot Reload" → Visual confirmation
2. **Inspector**: Click main button → Select "Inspector" → Reminder shown
3. **Clear Cache**: Click main button → Select "Clear Cache" → Confirmation shown

### Keyboard Shortcuts
While the widget doesn't implement keyboard shortcuts directly, it complements IDE shortcuts:
- `Ctrl+S` (IDE): Save and hot reload
- `Ctrl+Shift+P` (IDE): Command palette
- Dev button: Visual feedback and quick access

## Customization

### Position
To change the button position, modify the `Positioned` widget in `floating_dev_button.dart`:

```dart
Positioned(
  top: 60,    // Distance from top
  right: 16,  // Distance from right
  child: ...
)
```

### Colors
Customize button colors by modifying the color properties:

```dart
backgroundColor: _isExpanded 
    ? Colors.red.shade400      // Expanded state color
    : Colors.blue.shade600,    // Default state color
```

### Actions
Add new development actions by:

1. Adding a new `_DevActionButton` to the menu
2. Implementing the action method
3. Adding appropriate visual feedback

## Troubleshooting

### Button Not Showing
- Ensure app is running in debug mode
- Check that `kDebugMode` is true
- Verify the widget is included in the widget tree

### Animation Issues
- Animation controller is automatically disposed
- Check for proper widget lifecycle management
- Ensure SingleTickerProviderStateMixin is used

### Layout Conflicts
- Dev button uses absolute positioning (Positioned widget)
- Minimal impact on existing layout through Stack overlay
- Z-index automatically handled by Flutter's rendering system

## Performance Considerations

### Debug Mode Impact
- Widget only exists in debug builds
- Animation controller properly disposed
- Minimal memory footprint

### Production Impact
- **Zero impact**: Widget returns `SizedBox.shrink()` in release mode
- No runtime overhead in production builds
- Tree shaking eliminates debug-only code

## Future Enhancements

### Potential Additions
- **Console Log Viewer**: In-app log display
- **Performance Metrics**: Frame rate and memory usage
- **Network Monitor**: API call tracking
- **State Inspector**: Live state viewing

### Advanced Features
- **Keyboard Shortcuts**: Global shortcut support
- **Customizable Actions**: User-configurable action buttons
- **Theme Integration**: Better integration with app themes
- **Persistence**: Remember expanded state across sessions

## Compatibility

### Flutter Version
- Compatible with Flutter 3.0+
- Uses stable APIs only
- No version-specific dependencies

### Platform Support
- **Windows**: Primary target, fully tested
- **macOS**: Should work without modifications
- **Linux**: Should work without modifications
- **Mobile**: Not recommended (different UX patterns)

### IDE Integration
- **VS Code**: Complements built-in hot reload
- **Android Studio**: Works alongside IDE tools
- **IntelliJ**: Compatible with existing shortcuts

## Contributing

When modifying the dev tools widget:

1. **Maintain Stability**: Use only stable Flutter APIs
2. **Debug Only**: Ensure all features are debug-mode only
3. **Performance**: Keep animations lightweight
4. **User Feedback**: Provide clear visual feedback for all actions
5. **Documentation**: Update this README for any changes

## License

This dev tools implementation is part of the Hanoa project and follows the same licensing terms.