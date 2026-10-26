import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_ui_theme/flutter_ui_theme.dart';

import 'palettes.dart';

// ---------------------------------------------------------------------------
// Shared page frame
// ---------------------------------------------------------------------------

/// Scrolling page with a centered max-width column and a staggered entrance.
/// Bottom padding comes from MediaQuery, which `UiShell` sets so content clears
/// the floating nav bar.
class _Page extends StatelessWidget {
  const _Page({required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        math.max(media.padding.top, 0) + 22,
        20,
        media.padding.bottom + 28,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: riseAll([
                UiScreenHeader(title: title, subtitle: subtitle),
                const SizedBox(height: 22),
                ...children,
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 26, 4, 10),
      child: Text(
        text.toUpperCase(),
        style: ui.typography.strong(
          11.5,
          weight: FontWeight.w700,
          color: ui.colors.textSecondary,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overview
// ---------------------------------------------------------------------------

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return _Page(
      title: 'Good morning, Dr. Ruiz',
      subtitle: 'Tuesday  ·  12 appointments today',
      children: [
        const Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Patients',
                value: 1248,
                icon: Icons.groups_rounded,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _Stat(
                label: 'Today',
                value: 12,
                icon: Icons.event_available_rounded,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _Stat(
                label: 'Waiting',
                value: 3,
                icon: Icons.hourglass_bottom_rounded,
                live: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _NextAppointment(),
        const _Label('Today'),
        UiOptionGroup([
          for (final p in _patients)
            UiOption(
              p.name,
              detail: '${p.time}  ·  ${p.reason}',
              leading: _Avatar(p.name),
              trailing: UiBadge(p.status, color: p.color(ui), small: true),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PatientPage(patient: p),
                ),
              ),
            ),
        ]),
        const _Label('Loading state'),
        const _SkeletonCard(),
      ],
    );
  }
}

class Patient {
  const Patient(this.name, this.time, this.reason, this.status);

  final String name;
  final String time;
  final String reason;
  final String status;

  Color color(UiTheme ui) => switch (status) {
    'In room' => ui.colors.success,
    'Waiting' => ui.colors.warning,
    _ => ui.colors.info,
  };
}

const _patients = [
  Patient('Ana Martínez', '09:30', 'Follow-up', 'In room'),
  Patient('Luis Hernández', '10:15', 'Blood pressure check', 'Waiting'),
  Patient('Sofía Ramírez', '11:00', 'First consultation', 'Booked'),
  Patient('Mateo Gómez', '11:45', 'Lab results', 'Booked'),
];

class _Avatar extends StatelessWidget {
  const _Avatar(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final initials = name.split(' ').map((w) => w[0]).take(2).join();
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ui.colors.accentSoft,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: ui.typography.strong(
          13,
          weight: FontWeight.w800,
          color: ui.colors.accent,
        ),
      ),
    );
  }
}

class _Stat extends StatefulWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    this.live = false,
  });

  final String label;
  final int value;
  final IconData icon;
  final bool live;

  @override
  State<_Stat> createState() => _StatState();
}

class _StatState extends State<_Stat> {
  late int _value = widget.value;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.live) {
      _timer = Timer.periodic(const Duration(milliseconds: 2400), (_) {
        if (mounted) setState(() => _value = (_value + 1) % 10);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final text = _value >= 1000
        ? '${_value ~/ 1000},${(_value % 1000).toString().padLeft(3, '0')}'
        : '$_value';
    return UiCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(widget.icon, size: 20, color: ui.colors.accent),
          const SizedBox(height: 14),
          UiRollingText(
            text,
            style: ui.typography.display(
              30,
              weight: FontWeight.w800,
              color: ui.colors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: ui.typography.strong(
              12.5,
              weight: FontWeight.w600,
              color: ui.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass card over a colorful backdrop, the clearest demo of the glass look.
class _NextAppointment extends StatelessWidget {
  const _NextAppointment();

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final c = ui.colors;
    return ClipRRect(
      borderRadius: ui.shape.cardRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.accent, c.accentAlt, c.info],
                ),
              ),
            ),
          ),
          Positioned(
            right: -30,
            top: -40,
            child: _Blob(c.warning.withValues(alpha: 0.55), 150),
          ),
          Positioned(
            left: -20,
            bottom: -50,
            child: _Blob(c.success.withValues(alpha: 0.5), 130),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: UiGlassSurface(
              radius: ui.shape.card - 6,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'NEXT UP',
                        style: ui.typography.strong(
                          11,
                          weight: FontWeight.w800,
                          color: c.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      UiBadge(
                        'In 12 min',
                        color: c.accent,
                        icon: Icons.schedule_rounded,
                        small: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ana Martínez',
                    style: ui.typography.strong(
                      22,
                      weight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Follow-up  ·  Room 3  ·  09:30',
                    style: ui.typography.strong(
                      13,
                      weight: FontWeight.w500,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: UiPrimaryButton(
                          label: 'Start consultation',
                          icon: Icons.play_arrow_rounded,
                          height: 48,
                          onPressed: () => showUiToast(
                            context,
                            'Consultation started',
                            subtitle: 'Timer is running',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      UiSecondaryButton(label: 'Reschedule', onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob(this.color, this.size);

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return UiCard(
      child: Row(
        children: [
          const SizedBox(
            width: 46,
            height: 46,
            child: UiShimmer(radius: 23, repeat: true),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 160,
                  height: 14,
                  child: UiShimmer(radius: 7, repeat: true),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 110,
                  height: 12,
                  child: UiShimmer(radius: 6, repeat: true),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 64,
            height: 30,
            child: const UiShimmer(radius: 15, repeat: true),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pushed route (demonstrates the page transition)
// ---------------------------------------------------------------------------

class PatientPage extends StatelessWidget {
  const PatientPage({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UiScreenHeader(
                    title: patient.name,
                    subtitle: '${patient.time}  ·  ${patient.reason}',
                    onBack: () => Navigator.of(context).maybePop(),
                    badge: UiBadge(
                      patient.status,
                      color: patient.color(ui),
                      small: true,
                    ),
                    actions: [
                      UiRoundButton(
                        icon: Icons.more_horiz_rounded,
                        semanticLabel: 'More',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  UiListGroup([
                    const UiListRow(label: 'Age', control: Text('42')),
                    const UiListRow(label: 'Blood type', control: Text('O+')),
                    UiListRow(
                      label: 'Allergies',
                      control: UiBadge('Penicillin', color: ui.colors.danger),
                    ),
                  ]),
                  const Spacer(),
                  UiPrimaryButton(
                    label: 'Open record',
                    icon: Icons.folder_open_rounded,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  UiSecondaryButton(
                    label: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Components
// ---------------------------------------------------------------------------

class ComponentsPage extends StatefulWidget {
  const ComponentsPage({super.key});

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  final _search = TextEditingController();
  bool _loading = false;
  bool _reminders = true;
  bool _sms = false;
  String _range = 'week';
  String _filter = 'All';
  int _duration = 30;
  bool _check = true;
  double _slider = 0.4;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return _Page(
      title: 'Components',
      subtitle: 'Every widget reads colors, radii and motion from UiTheme',
      children: [
        const _Label('Buttons'),
        UiPrimaryButton(
          label: 'Confirm appointment',
          icon: Icons.check_rounded,
          onPressed: () {},
        ),
        const SizedBox(height: 10),
        UiPrimaryButton(
          label: _loading ? 'Saving…' : 'Tap to see loading',
          loading: _loading,
          onPressed: () {
            setState(() => _loading = true);
            Future<void>.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _loading = false);
            });
          },
        ),
        const SizedBox(height: 10),
        const UiPrimaryButton(label: 'Disabled', onPressed: null),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            UiSecondaryButton(
              label: 'Export PDF',
              icon: Icons.download_rounded,
              onPressed: () {},
            ),
            UiSecondaryButton(
              label: 'Add note',
              icon: Icons.edit_note_rounded,
              onPressed: () {},
            ),
            UiRoundButton(
              icon: Icons.add_rounded,
              semanticLabel: 'Add',
              onPressed: () {},
            ),
            UiRoundButton(
              icon: Icons.call_rounded,
              semanticLabel: 'Call',
              filled: true,
              onPressed: () {},
            ),
            UiRoundButton(
              icon: Icons.favorite_border_rounded,
              semanticLabel: 'Favorite',
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in ['All', 'Today', 'Pending', 'Done'])
              UiPill(
                label: f,
                selected: _filter == f,
                onPressed: () => setState(() => _filter = f),
              ),
            UiPill(
              label: 'Urgent',
              icon: Icons.priority_high_rounded,
              background: ui.colors.danger.withValues(alpha: 0.14),
              foreground: ui.colors.danger,
              onPressed: () {},
            ),
          ],
        ),
        const _Label('Inputs'),
        UiSearchField(
          controller: _search,
          hint: 'Search patients',
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Full name',
            hintText: 'As on the ID',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: 'Enter a valid address',
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: UiSegmentedToggle<String>(
            segments: const [
              UiSegment(value: 'day', label: 'Day'),
              UiSegment(value: 'week', label: 'Week'),
              UiSegment(value: 'month', label: 'Month'),
            ],
            value: _range,
            onChanged: (v) => setState(() => _range = v),
          ),
        ),
        const _Label('Settings rows'),
        UiListGroup([
          UiListRow(
            label: 'Appointment reminders',
            control: UiSwitch(
              value: _reminders,
              onChanged: (v) => setState(() => _reminders = v),
              semanticLabel: 'Reminders',
            ),
          ),
          UiListRow(
            label: 'SMS to patients',
            control: UiSwitch(
              value: _sms,
              onChanged: (v) => setState(() => _sms = v),
              semanticLabel: 'SMS',
            ),
          ),
          UiListRow(
            label: 'Default duration (min)',
            control: UiStepper(
              value: '$_duration',
              onDecrement: () =>
                  setState(() => _duration = math.max(5, _duration - 5)),
              onIncrement: () => setState(() => _duration += 5),
            ),
          ),
        ]),
        const _Label('Lists'),
        UiOptionGroup([
          UiOption(
            'Dr. Ruiz',
            detail: 'Cardiology',
            icon: Icons.person_outline_rounded,
            selected: true,
            onTap: () {},
          ),
          UiOption(
            'Dr. Lee',
            detail: 'General practice',
            icon: Icons.person_outline_rounded,
            onTap: () {},
          ),
          UiOption(
            'Archive patient',
            icon: Icons.archive_outlined,
            onTap: () {},
          ),
          UiOption(
            'Delete record',
            icon: Icons.delete_outline_rounded,
            danger: true,
            onTap: () {},
          ),
        ]),
        const _Label('Cards'),
        UiCard(
          onTap: () => showUiToast(
            context,
            'Card tapped',
            icon: Icons.touch_app_rounded,
          ),
          child: Row(
            children: [
              Icon(Icons.medical_services_rounded, color: ui.colors.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Tappable card with the springy press',
                  style: ui.typography.strong(
                    14.5,
                    weight: FontWeight.w600,
                    color: ui.colors.text,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: ui.colors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            const UiBadge('Beta', icon: Icons.science_rounded),
            UiBadge('Paid', color: ui.colors.success),
            UiBadge('Overdue', color: ui.colors.danger),
            UiBadge('Draft', color: ui.colors.info),
          ],
        ),
        const _Label('Stock Material widgets, restyled by the theme'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton(onPressed: () {}, child: const Text('FilledButton')),
            OutlinedButton(
              onPressed: () {},
              child: const Text('OutlinedButton'),
            ),
            TextButton(onPressed: () {}, child: const Text('TextButton')),
            const Chip(label: Text('Chip')),
            Switch(value: _check, onChanged: (v) => setState(() => _check = v)),
            Checkbox(
              value: _check,
              onChanged: (v) => setState(() => _check = v ?? false),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Slider(value: _slider, onChanged: (v) => setState(() => _slider = v)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Overlays
// ---------------------------------------------------------------------------

class OverlaysPage extends StatelessWidget {
  const OverlaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return _Page(
      title: 'Overlays',
      subtitle: 'Sheets, dialogs and toasts over a blurred backdrop',
      children: [
        const _Label('Sheets and dialogs'),
        UiOptionGroup([
          UiOption(
            'Bottom sheet (centered panel on desktop)',
            icon: Icons.vertical_align_bottom_rounded,
            onTap: () => showUiSheet<void>(
              context: context,
              builder: (_) => const QuickCreateSheet(),
            ),
          ),
          UiOption(
            'Confirm dialog',
            icon: Icons.help_outline_rounded,
            onTap: () async {
              final ok = await showUiConfirm(
                context,
                title: 'Cancel appointment?',
                body:
                    'Ana Martínez will be notified by SMS and the slot will be released.',
                confirmLabel: 'Cancel appointment',
                cancelLabel: 'Keep it',
                danger: true,
              );
              if (context.mounted) {
                unawaited(
                  showUiToast(
                    context,
                    ok ? 'Appointment cancelled' : 'Kept as is',
                    icon: ok ? Icons.event_busy_rounded : Icons.check_rounded,
                    accent: ok ? ui.colors.danger : ui.colors.success,
                  ),
                );
              }
            },
          ),
          UiOption(
            'Date picker',
            icon: Icons.calendar_month_rounded,
            onTap: () => showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
            ),
          ),
          UiOption(
            'Time picker',
            icon: Icons.schedule_rounded,
            onTap: () => showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 9, minute: 30),
            ),
          ),
        ]),
        const _Label('Toasts'),
        UiOptionGroup([
          UiOption(
            'Success, top',
            icon: Icons.check_rounded,
            onTap: () => showUiToast(
              context,
              'Record saved',
              subtitle: 'Synced just now',
            ),
          ),
          UiOption(
            'With action, bottom',
            icon: Icons.undo_rounded,
            onTap: () => showUiToast(
              context,
              'Patient archived',
              icon: Icons.archive_rounded,
              accent: ui.colors.info,
              actionLabel: 'Undo',
              position: UiToastPosition.bottom,
            ),
          ),
          UiOption(
            'Error',
            icon: Icons.error_outline_rounded,
            onTap: () => showUiToast(
              context,
              'Could not reach the server',
              subtitle:
                  'Your changes are saved on this device and will sync when you are back online.',
              icon: Icons.cloud_off_rounded,
              accent: ui.colors.danger,
            ),
          ),
          UiOption(
            'Stock SnackBar (themed)',
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Message sent'),
                action: SnackBarAction(label: 'Undo', onPressed: () {}),
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

class QuickCreateSheet extends StatelessWidget {
  const QuickCreateSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: uiSheetPadding(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const UiSheetHandle(),
          const SizedBox(height: 16),
          const UiSheetTitle(
            'Create new',
            subtitle: 'What would you like to add?',
          ),
          const SizedBox(height: 18),
          UiOptionGroup([
            UiOption(
              'Appointment',
              icon: Icons.event_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            UiOption(
              'Patient',
              icon: Icons.person_add_alt_1_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            UiOption(
              'Prescription',
              icon: Icons.medication_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ]),
          const SizedBox(height: 14),
          UiSecondaryButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

class ThemePage extends StatelessWidget {
  const ThemePage({
    super.key,
    required this.brand,
    required this.mode,
    required this.onBrand,
    required this.onMode,
  });

  final Brand brand;
  final Mode mode;
  final ValueChanged<Brand> onBrand;
  final ValueChanged<Mode> onMode;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final c = ui.colors;
    final swatches = <(String, Color)>[
      ('background', c.background),
      ('surface', c.surface),
      ('surfaceAlt', c.surfaceAlt),
      ('border', c.border),
      ('text', c.text),
      ('textSecondary', c.textSecondary),
      ('primary', c.primary),
      ('accent', c.accent),
      ('accentAlt', c.accentAlt),
      ('success', c.success),
      ('info', c.info),
      ('warning', c.warning),
      ('danger', c.danger),
    ];
    return _Page(
      title: 'Theme',
      subtitle: 'One UiTheme object drives everything',
      children: [
        const _Label('Preview'),
        UiListGroup([
          UiListRow(
            label: 'Mode',
            control: UiSegmentedToggle<Mode>(
              segments: const [
                UiSegment(value: Mode.light, label: 'Light'),
                UiSegment(value: Mode.dark, label: 'Dark'),
                UiSegment(value: Mode.amoled, label: 'AMOLED'),
              ],
              value: mode,
              onChanged: onMode,
              hPad: 10,
            ),
          ),
          UiListRow(
            label: 'Brand',
            control: UiSegmentedToggle<Brand>(
              segments: const [
                UiSegment(value: Brand.original, label: 'Original'),
                UiSegment(value: Brand.clinic, label: 'Clinic'),
              ],
              value: brand,
              onChanged: onBrand,
              hPad: 12,
            ),
          ),
        ]),
        const _Label('Colors'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (name, color) in swatches) _Swatch(name, color),
          ],
        ),
        const _Label('Typography'),
        UiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Display 34',
                style: ui.typography.display(
                  34,
                  weight: FontWeight.w800,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Title 20 · strong',
                style: ui.typography.strong(
                  20,
                  weight: FontWeight.w800,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Label 14 · strong w600',
                style: ui.typography.strong(
                  14,
                  weight: FontWeight.w600,
                  color: c.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Body 14. The quick brown fox jumps over the lazy dog. 0123456789',
                style: ui.typography.body(14, color: c.textSecondary),
              ),
            ],
          ),
        ),
        const _Label('Shape'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (name, r) in [
              ('small', ui.shape.small),
              ('group', ui.shape.group),
              ('card', ui.shape.card),
              ('sheet', ui.shape.sheet),
              ('pill', 28.0),
            ])
              Container(
                width: 92,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(r),
                ),
                child: Text(
                  name,
                  style: ui.typography.strong(
                    12,
                    weight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return SizedBox(
      width: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: ui.shape.groupRadius,
              border: Border.all(color: ui.colors.border),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: ui.typography.strong(
              11.5,
              weight: FontWeight.w600,
              color: ui.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
