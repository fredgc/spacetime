import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import "printer.dart";

class MyShortcutManager {
  List<_ShortcutMapper> menus = [];

  void add(_ShortcutMapper menu) {
    menus.add(menu);
  }

  void clear() {
    menus.clear();
  }

  // Make the interstitial widget
  Widget build(BuildContext context, Widget child) {
    Map<Type, Action<Intent>> actions = {};
    Map<ShortcutActivator, Intent> shortcuts = {};
    for (var menu in menus) {
      // Log.menus.log("Shortcut manager registering $menu");
      menu.register(actions, shortcuts);
    }

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(actions: actions, child: child),
    );
  }

  void dumpShortcuts() {
    Map<Type, Action<Intent>> actions = {};
    Map<ShortcutActivator, Intent> shortcuts = {};
    for (var menu in menus) {
      // Log.menus.log("Shortcut manager registering $menu for debug.");
      menu.register(actions, shortcuts);
    }
    Log.menus.log("GREEN: Here are all the shortcuts -----------------");
    List<ShortcutActivator> keys = shortcuts.keys.toList();
    int compare(a, b) {
      if (a is SingleActivator && b is SingleActivator) {
        int diff = a.trigger.keyLabel.compareTo(b.trigger.keyLabel);
        if (diff == 0) {
          if (a.control == b.control) return 0;
          if (a.control) return -1;
          return 1;
        }
        return diff;
      }
      return a.toString().compareTo(b.toString());
    }

    keys.sort(compare);
    ShortcutActivator? prev;
    for (var s in keys) {
      if (compare(s, prev) == 0) {
        Log.menus.log("  RED: This matches previous.");
      }
      prev = s;
      Intent intent = shortcuts[s]!;
      Action? action = actions[intent.runtimeType];
      Log.menus.log("  Shortcut $s maps to $intent, to action=$action");
    }
  }
}

abstract class _ShortcutMapper {
  void register(
    Map<Type, Action<Intent>> actionMap,
    Map<ShortcutActivator, Intent> shortcutMap,
  );
}

abstract class HasShortcut {
  MenuSerializableShortcut? get shortcut;
}

// XXX maybe this should be a menu builder?
// TODO:Make this a child MySubmenu (with the build).
// TODO: Or have two builds (Submenu and Menuanchor). what?
// The shortcut manager needs to iterate through and get MyMenuItem.add().
class MyMenu with ChangeNotifier implements _ShortcutMapper {
  final String title;
  List<MyMenuItem> items = [];
  bool isExpanded = false;
  MyMenu(this.title);

  @override
  void register(
    Map<Type, Action<Intent>> actionMap,
    Map<ShortcutActivator, Intent> shortcutMap,
  ) {
    // Log.menus.log("MyMenu registering $title");
    for (var item in items) {
      // Log.menus.log("  MyMenu trying to register $item");
      item.register(actionMap, shortcutMap);
    }
  }

  // XXX Rethink this design.
  // Notify all listeners so that the menu is rebuilt.
  void rebuild() {
    // XXX Log.menus.log("Notify rebuild for menu '$title'");
    notifyListeners();
  }

  // Build a submenu button that expands to this menu.
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: this,
      builder: (BuildContext context, Widget? child) {
        return SubmenuButton(
          menuChildren: items
              .map((item) => item.makeMenuButton(context))
              .toList(),
          child: Text(title),
        );
      },
    );
  }

  // Build a submenu button that expands to this menu.
  Widget buildDrawerList(BuildContext context, [bool? initiallyExpanded]) {
    return ListenableBuilder(
      listenable: this,
      builder: (BuildContext context, Widget? child) {
        return ExpansionTile(
          title: Text(title),
          initiallyExpanded: initiallyExpanded ?? isExpanded,
          onExpansionChanged: (expanded) {
            isExpanded = expanded;
          },
          childrenPadding: EdgeInsets.only(left: 10),
          children: items.map((item) => item.makeMenuButton(context)).toList(),
        );
      },
    );
  }
}

class MyMenuItem extends Intent implements _ShortcutMapper, HasShortcut {
  @override
  final MenuSerializableShortcut? shortcut;
  final VoidCallback? callback;
  final String name;
  final String tip;

  final bool Function()? isEnabledCallback;
  bool get isEnabled =>
      isEnabledCallback == null ? true : isEnabledCallback!.call();

  // TODO: which one is actually used? logical is not used often.
  const MyMenuItem.logical(
    this.name, {
    this.callback,
    this.shortcut,
    this.tip = "",
    this.isEnabledCallback,
  });

  MyMenuItem(
    this.name, {
    this.callback,
    LogicalKeyboardKey? key,
    this.tip = "",
    this.isEnabledCallback,
  }) : shortcut = key == null ? null : SingleActivator(key, control: true);

  @override
  void register(
    Map<Type, Action<Intent>> actionMap,
    Map<ShortcutActivator, Intent> shortcutMap,
  ) {
    // Log.menus.log("    In MyMenuItem.register $this, shortcut=$shortcut");
    if (shortcut == null) return;
    actionMap[MyMenuItem] = CallbackAction(onInvoke: callCallback);
    if (shortcutMap.containsKey(shortcut!)) {
      // Log.menus.log("RED: warning. $shortcut already in shortcut map.");
    }
    shortcutMap[shortcut!] = this;
  }

  Widget makeMenuButtonNoTip(BuildContext context) {
    return MenuItemButton(
      overflowAxis: Axis.vertical,
      shortcut: shortcut,
      onPressed: !isEnabled
          ? null
          : () {
              Scaffold.of(context).closeDrawer();
              onPressed();
            },
      child: Text(
        name,
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget makeMenuButton(BuildContext context) {
    // TODO: use IconButton instead?
    // TODO: or use leadingIcon or trailingIcon.
    if (tip.isEmpty) {
      return makeMenuButtonNoTip(context);
    } else {
      return Tooltip(
        message: tip,
        waitDuration: Duration(seconds: 3), //TODO: set elsewhere.
        child: makeMenuButtonNoTip(context),
      );
    }
  }

  static void callCallback(Intent intent) {
    MyMenuItem here = intent as MyMenuItem;
    Log.menus.log(
      "Calling ${here.name} shortcut. isEnabled = ${here.isEnabled}",
    );
    if (here.isEnabled) here.callback?.call();
    Log.menus.log("Menu finished ${here.name}");
  }

  void onPressed() {
    // Log.menus.log("onPressed: $name for button, isEnabled = $isEnabled");
    if (isEnabled) callback?.call();
    // Log.menus.log("Menu finished ${name}");
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => name;
}

class MyMenuSpacer extends MyMenuItem {
  MyMenuSpacer() : super("");

  @override
  Widget makeMenuButton(BuildContext context) => Divider();
}

Widget toText(Object t) {
  return Text(t.toString(), softWrap: false, overflow: TextOverflow.ellipsis);
}

String empty(Object t) => "";

class ListChooser<T extends Object> extends ValueNotifier<T>
    implements _ShortcutMapper {
  final List<T> possible;
  final Icon Function(T)? makeIcon;
  final Widget Function(T) makeButton;
  final String Function(T) tooltip;
  final String message; // The main tool tip.
  final Key? key;

  ListChooser(
    this.possible, {
    this.key,
    T? initial,
    this.makeButton = toText,
    this.tooltip = empty,
    this.makeIcon,
    this.message = "",
  }) : super(initial ?? possible[0]);

  void _toggle(MenuController controller) {
    if (controller.isOpen) {
      controller.close();
    } else {
      controller.open();
    }
  }

  // XXX -- maybe have a "get shortcut" function always.
  MenuItemButton makeChild(T item) {
    MenuSerializableShortcut? shortcut = (item is HasShortcut)
        ? item.shortcut
        : null;
    return MenuItemButton(
      key: ValueKey("$T-Chooser-$item"),
      shortcut: shortcut,
      onPressed: () {
        // Log.menus.log("YELLOW: Changed value of menu to $item");
        value = item;
      },
      child: makeIcon == null ? makeButton(item) : makeIcon!.call(item),
    );
  }

  List<MenuItemButton> buildChildren() {
    return possible.map((v) => makeChild(v)).toList();
  }

  Widget build(BuildContext context) {
    // Log.menus.log("ZZZ: Building for $T. key = $key");
    return ValueListenableBuilder<T>(
      key: key ?? ValueKey("$T-Chooser"),
      valueListenable: this,
      builder: (BuildContext context, T v1, Widget? child) {
        // Log.menus.log("Building menu w/value = $value, v1 = $v1.");
        return MenuAnchor(
          builder:
              (BuildContext context, MenuController controller, Widget? child) {
                // If this is an icon menu, then use an Icon button. Othewise,
                // use a TextButton.
                return makeIcon == null
                    ? Tooltip(
                        message: message,
                        waitDuration: Duration(
                          seconds: 3,
                        ), //TODO: set elsewhere.
                        child: TextButton(
                          onPressed: () => _toggle(controller),
                          child: makeButton(value),
                        ),
                      )
                    : IconButton(
                        onPressed: () => _toggle(controller),
                        icon: makeIcon!.call(value),
                      );
              },
          menuChildren: buildChildren(),
        );
      },
    );
  }

  @override
  void register(
    Map<Type, Action<Intent>> actionMap,
    Map<ShortcutActivator, Intent> shortcutMap,
  ) {
    // Log.menus.log("In ListChooser.register for $this.");
    for (T item in possible) {
      // Log.menus.log("  looking at '$item'");
      if (item is HasShortcut) {
        HasShortcut item2 = item as HasShortcut;
        // Log.menus.log("    Might register '$item2'");
        if (item2.shortcut == null) continue;
        MenuSerializableShortcut shortcut = item2.shortcut!;
        // Log.menus.log("    '$item2' has a shortcut $shortcut");
        // XXX -- this does not work because it checks to see if they
        // are identical, not equal.
        if (shortcutMap.containsKey(shortcut)) {
          Log.menus.log("RED: warning. $shortcut already in shortcut map.");
        }
        actionMap[_ChoiceIntent<T>] = CallbackAction(onInvoke: setValue);
        shortcutMap[shortcut] = _ChoiceIntent(this, item);
      }
    }
  }

  void setValue(Intent intent) {
    _ChoiceIntent x = intent as _ChoiceIntent;
    // Log.menus.log("Got shortcut callback in $this for ${x.menu} to be ${x.item}");
    x.menu.value = x.item;
  }
}

class RadioItem<T extends Object> extends MyMenuItem {
  final T item;
  final ValueNotifier<T> group;

  RadioItem(
    super.name,
    this.item,
    this.group, {
    super.callback,
    super.tip = "",
    super.isEnabledCallback,
  });

  @override
  Widget makeMenuButtonNoTip(BuildContext context) {
    MenuSerializableShortcut? sk = shortcut;
    // Log.menus.log("  makeMenuButtonNoTip for $item");
    if (item is HasShortcut) {
      HasShortcut item2 = item as HasShortcut;
      sk = item2.shortcut;
      // Log.menus.log("ORANGE: Item $item has shortcut $sk");
    }
    return RadioMenuButton<T>(
      value: item,
      shortcut: sk,

      groupValue: group.value,
      onChanged: (T? v) {
        // Log.menus.log("Changed radio menu to $v, through $item");
        group.value = v!;
        // XXX do something with callback?
      },
      // XXX This doesn't work. size is unconstrained.
      // child: LayoutBuilder(
      //   builder: (context, size) {
      //     Log.menus.log("RED: Make ${name} the box ${zzz(size)}");
      //     return SizedBox(
      //       height: size.maxHeight,
      //       width: size.maxWidth,
      //       child: Text(name,
      //       softWrap: false,
      //       maxLines: 1,
      //       overflow: TextOverflow.ellipsis),
      //     );
      // }),

      // XXX This doesn't wrap correctly.
      child: Text(
        name,
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class RadioChooser<T extends Object> extends ListChooser<T> {
  RadioChooser(
    super.possible, {
    super.initial,
    super.makeButton = toText,
    super.tooltip = empty,
    super.makeIcon,
    super.message = "",
  });

  List<RadioItem<T>> makeItems() {
    return possible
        .map(
          (item) => RadioItem(item.toString(), item, this, tip: tooltip(item)),
        )
        .toList();
  }
}

void errorCallback() {
  Log.menus.log("RED: wrong callback.");
}

class ChoiceItem extends MyMenuItem {
  ChoiceItem(
    super.name, {
    super.callback = errorCallback,
    super.key,
    super.tip = "",
    super.isEnabledCallback,
  });
}

class _ChoiceIntent<T extends Object> extends Intent {
  final ListChooser<T> menu;
  final T item;
  const _ChoiceIntent(this.menu, this.item);
}

class RangeChooser extends ListChooser<int> {
  // Create a ListChooser that is uses the array [0..length] as the values.
  RangeChooser(
    int length, {
    super.key,
    super.initial = 0,
    super.makeButton = toText,
    super.tooltip = empty,
    super.makeIcon,
    super.message = "",
  }) : super([for (int i = 0; i < length; i++) i]);
}
