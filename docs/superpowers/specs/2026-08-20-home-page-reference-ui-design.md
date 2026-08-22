# Home Page Reference UI Design

Date: 2026-08-20
Status: Approved by user for implementation

## Goal

Update the Flutter app home page, currently the Today tab, to closely match the supplied Tibetan calendar reference image. The screen should use a deep red full-page background, gold header typography, bordered red content panels, large white date typography, Tibetan text emphasis, and a dark red/gold bottom navigation treatment.

## Scope

The implementation updates the mobile Flutter UI only. It does not change calendar synchronization, reminder behavior, backend data contracts, or dashboard publishing. Existing navigation destinations remain available.

## Layout

The Today tab becomes a vertically scrollable red daily-card screen:

- A top header with a serif italic gold `Select Day` label on the left and the current month title on the right.
- A large selected-day panel showing weekday, day number, a sacred-symbol style graphic, Tibetan date, daily English guidance, and a short quote.
- A second bordered panel showing Tibetan elemental text, English elemental title, and English explanatory copy.
- A three-column Date / Month / Year panel with dark headers, large white values, and smaller secondary labels.
- Bottom navigation styled as a dark red rounded bar with gold labels and icons. The app keeps the current four destinations: Today, Calendar, Practice, and More.

## Visual Style

The palette follows the reference image:

- Page background: dark maroon red.
- Panels: slightly lighter maroon red with thin brighter red borders.
- Primary text: white.
- Accent text and labels: warm gold.
- Navigation: dark red surface with gold inactive items and a white/gold selected indicator.

Flutter built-in font families are used. The script-like header uses a serif italic style; large date and panel headings use heavy sans-serif weights. No external font assets are added in this pass.

## Data Handling

The screen continues to consume the existing `CalendarEntry` and `CalendarMonth` objects. Existing entry fields populate weekday, day number, Tibetan date, title, and description. Reference-only fields that are not yet modeled, such as elemental combination and Date / Month / Year metadata, use static display values for now so the visual layout can be implemented without expanding the content model.

## Testing

Widget tests verify that the home screen renders the reference-style labels and content, keeps the existing calendar data visible, and remains usable under large text scaling. Existing navigation and sync tests must continue to pass.
