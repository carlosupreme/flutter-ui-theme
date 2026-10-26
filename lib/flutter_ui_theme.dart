/// Plug-and-play Flutter design system.
///
/// Start with [buildUiTheme] and a [UiTheme]; everything else reads from it via
/// `context.ui`. See README.md for the catalog and AGENTS.md for adoption.
library;

// Tokens & theme
export 'src/tokens/build_theme.dart';
export 'src/tokens/ui_colors.dart';
export 'src/tokens/ui_effects.dart';
export 'src/tokens/ui_motion.dart';
export 'src/tokens/ui_shape.dart';
export 'src/tokens/ui_theme.dart';
export 'src/tokens/ui_typography.dart';

// Transitions
export 'src/transitions/page_transitions.dart' show UiPageTransitionsBuilder;
export 'src/transitions/rise.dart';
export 'src/transitions/screen_switcher.dart';

// Widgets
export 'src/widgets/buttons.dart';
export 'src/widgets/inputs.dart';
export 'src/widgets/lists.dart';
export 'src/widgets/pressable.dart';
export 'src/widgets/surfaces.dart';
export 'src/widgets/text_widgets.dart' show UiRollingText, UiMarqueeText;

// Navigation
export 'src/navigation/nav_bar.dart';
export 'src/navigation/nav_rail.dart';
export 'src/navigation/shell.dart';

// Overlays
export 'src/overlays/dialogs.dart';
export 'src/overlays/edge_blur.dart';
export 'src/overlays/glass_routes.dart';
export 'src/overlays/toast.dart';
