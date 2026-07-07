# selection_kit

Themable selection-control widgets for Flutter — radio groups, checkbox groups,
and their single-tile variants. Hooks-free, pure `StatefulWidget`.

## Quick start

```dart
import 'package:selection_kit/selection_kit.dart';

AppRadioGroup<String>(
  label: 'Booking type',
  isRequired: true,
  options: const [
    SelectionOption(value: 'single', title: 'Single', icon: Icon(Icons.person)),
    SelectionOption(value: 'family', title: 'Family',  icon: Icon(Icons.group)),
    SelectionOption(value: 'business', title: 'Business', icon: Icon(Icons.business)),
  ],
  groupValue: selectedType,
  onChanged: (v) => setState(() => selectedType = v),
);
```

```dart
AppCheckboxGroup<String>(
  label: 'Notification channels',
  options: const [
    SelectionOption(value: 'email', title: 'Email'),
    SelectionOption(value: 'sms', title: 'SMS'),
    SelectionOption(value: 'push', title: 'Push'),
  ],
  groupValues: selectedChannels,
  onChanged: (v) => setState(() => selectedChannels = v),
);
```

## App-wide theming

Wrap the part of the tree that uses selection widgets with a `SelectionKitTheme`:

```dart
SelectionKitTheme(
  data: const SelectionKitThemeData(
    selectedColor: Colors.indigo,
    borderRadius: 12,
    contentPadding: EdgeInsets.all(16),
  ),
  child: child,
);
```

Per-group properties on `AppRadioGroup` / `AppCheckboxGroup` always override
the inherited theme.

## Layouts

- `direction: Axis.vertical` (default) — `Column` of tiles, optional `separator` between them.
- `direction: Axis.horizontal` — `Wrap` with `spacing` and `runSpacing`.

Grid / horizontal-scroll modes are intentionally not in the API. Wrap the group
in your own `GridView` / `ListView` if you need them.

## Custom indicators

Pass `indicatorBuilder` to replace the default radio circle / checkbox square:

```dart
AppRadioGroup<int>(
  indicatorBuilder: (selected, enabled) => Icon(
    selected ? Icons.star : Icons.star_border,
    color: enabled ? Colors.amber : Colors.grey,
  ),
  ...
);
```

## Single tile

For one-off selectable rows use `AppRadio<T>` or `AppCheckbox<T>`:

```dart
AppCheckbox<bool>(
  value: true,
  selected: agreed,
  title: 'I agree to the terms',
  onChanged: (v) => setState(() => agreed = v ?? false),
);
```
