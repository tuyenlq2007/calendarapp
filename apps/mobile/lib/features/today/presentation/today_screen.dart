import 'package:flutter/material.dart';

import '../../calendar/domain/calendar_entry.dart';

const _parchment = Color(0xFFF4D990);
const _panelParchment = Color(0xFFF8E6B3);
const _headerRed = Color(0xFFA9181D);
const _borderGold = Color(0xFFD4A85A);
const _metaGold = Color(0xFFF1E36A);
const _gold = Color(0xFFF6D985);
const _textDark = Color(0xFF2D130D);
const _deepBlue = Color(0xFF00385D);
const _maroon = Color(0xFF9B0F18);
const _green = Color(0xFF087326);
const _blue = Color(0xFF0C28D8);

class TodayScreen extends StatefulWidget {
  const TodayScreen({
    super.key,
    required this.monthTitle,
    required this.entry,
    this.showTodayButton = false,
    this.onTodaySelected,
    this.onPreviousDaySelected,
    this.onNextDaySelected,
  });

  final String monthTitle;
  final CalendarEntry entry;
  final bool showTodayButton;
  final VoidCallback? onTodaySelected;
  final VoidCallback? onPreviousDaySelected;
  final VoidCallback? onNextDaySelected;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  static const _swipeThreshold = 80.0;

  double _horizontalDragDistance = 0;
  bool _handledHorizontalDrag = false;

  void _resetHorizontalDrag() {
    _horizontalDragDistance = 0;
    _handledHorizontalDrag = false;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (_handledHorizontalDrag) return;

    _horizontalDragDistance += details.primaryDelta ?? 0;
    if (_horizontalDragDistance <= -_swipeThreshold) {
      _handledHorizontalDrag = true;
      widget.onNextDaySelected?.call();
    } else if (_horizontalDragDistance >= _swipeThreshold) {
      _handledHorizontalDrag = true;
      widget.onPreviousDaySelected?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _parchment,
      body: Column(
        children: [
          _TopHeader(
            monthTitle: widget.monthTitle,
            showTodayButton: widget.showTodayButton,
            onTodaySelected: widget.onTodaySelected,
          ),
          Expanded(
            child: GestureDetector(
              key: const ValueKey('today-swipe-area'),
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) => _resetHorizontalDrag(),
              onHorizontalDragUpdate: _handleHorizontalDragUpdate,
              onHorizontalDragEnd: (_) => _resetHorizontalDrag(),
              onHorizontalDragCancel: _resetHorizontalDrag,
              child: SingleChildScrollView(
                key: const ValueKey('today-scroll'),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                child: Column(
                  children: [
                    _SelectedDayPanel(entry: widget.entry),
                    const SizedBox(height: 10),
                    _ElementPanel(entry: widget.entry),
                    const SizedBox(height: 10),
                    _TibetanDateDetails(entry: widget.entry),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.monthTitle,
    required this.showTodayButton,
    required this.onTodaySelected,
  });

  final String monthTitle;
  final bool showTodayButton;
  final VoidCallback? onTodaySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _headerRed,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 7,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        monthTitle,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: _gold,
                              fontWeight: FontWeight.w800,
                              height: 1,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 11,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Barom Kagyu',
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: _gold,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              if (showTodayButton) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onTodaySelected,
                    icon: const Icon(Icons.today, size: 18),
                    label: const Text('Today'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0x33FFFFFF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedDayPanel extends StatelessWidget {
  const _SelectedDayPanel({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    return _ReferencePanel(
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _DateStack(entry: entry)),
              const SizedBox(width: 10),
              const _SacredSymbol(),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            entry.tibetanDateText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: _textDark,
              fontWeight: FontWeight.w700,
              height: 1.16,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            entry.titleEn,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _textDark,
              fontWeight: FontWeight.w900,
              height: 1.12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.descriptionEn,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _green,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateStack extends StatelessWidget {
  const _DateStack({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              entry.weekday.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _maroon,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 14),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                '${entry.day}',
                style: const TextStyle(
                  color: _deepBlue,
                  fontSize: 140,
                  fontWeight: FontWeight.w900,
                  height: .78,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SacredSymbol extends StatelessWidget {
  const _SacredSymbol();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Barom Kagyu logo',
      image: true,
      child: Image.asset(
        'assets/images/barom_kagyu_logo.png',
        width: 150,
        height: 159,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ElementPanel extends StatelessWidget {
  const _ElementPanel({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    final elementPair = entry.elementPairEn.trim().isEmpty
        ? 'Water - Wind'
        : entry.elementPairEn;
    final elementTitle = entry.elementCombinationTitleEn.trim().isEmpty
        ? 'Negative Elemental Combination'
        : entry.elementCombinationTitleEn;
    final elementDescription = entry.elementDescriptionEn.trim().isEmpty
        ? "This negative elemental combination will cause disharmony among one's loved ones"
        : entry.elementDescriptionEn;

    return _ReferencePanel(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
      child: Column(
        children: [
          if (entry.elementTibetanLine.trim().isNotEmpty) ...[
            Text(
              entry.elementTibetanLine,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _textDark,
                fontWeight: FontWeight.w800,
                height: 1.18,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            elementPair,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _textDark,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: 0,
            ),
          ),
          Text(
            elementTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _blue,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            elementDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _textDark,
              fontWeight: FontWeight.w700,
              height: 1.16,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TibetanDateDetails extends StatelessWidget {
  const _TibetanDateDetails({required this.entry});

  final CalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    final dateSubtitle = entry.elementPairEn.trim().isEmpty
        ? entry.tibetanDateText
        : entry.elementPairEn;
    final monthValue = entry.monthNumberText.trim().isEmpty
        ? '7'
        : entry.monthNumberText;
    final monthSubtitle = entry.monthElementAnimalEn.trim().isEmpty
        ? 'Fire Dog'
        : entry.monthElementAnimalEn;
    final yearValue = entry.yearNumberText.trim().isEmpty
        ? '2153'
        : entry.yearNumberText;
    final yearSubtitle = entry.yearElementAnimalEn.trim().isEmpty
        ? 'Fire Horse'
        : entry.yearElementAnimalEn;

    return _ReferencePanel(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _MetaCell(
                label: 'Date',
                value: '${entry.lunarDay}',
                subtitle: dateSubtitle,
              ),
            ),
            const _MetaDivider(),
            Expanded(
              child: _MetaCell(
                label: 'Month',
                value: monthValue,
                subtitle: monthSubtitle,
              ),
            ),
            const _MetaDivider(),
            Expanded(
              child: _MetaCell(
                label: 'Year',
                value: yearValue,
                subtitle: yearSubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          color: _metaGold,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Color(0xFF795D1D),
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 14),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: _maroon,
                    fontWeight: FontWeight.w900,
                    height: .9,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _textDark,
                  fontWeight: FontWeight.w600,
                  height: 1.08,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaDivider extends StatelessWidget {
  const _MetaDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: _borderGold);
  }
}

class _ReferencePanel extends StatelessWidget {
  const _ReferencePanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _panelParchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderGold),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
