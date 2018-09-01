import 'package:flutter/material.dart';
import 'package:bodt_chat/searchablePopupMenu/show.dart';

class SearchablePopupMenuButton<T> extends StatefulWidget {
  const SearchablePopupMenuButton({
    Key key,
    @required this.itemBuilder,
    this.initialValue,
    this.onSelected,
    this.onCanceled,
    this.tooltip,
    this.elevation = 8.0,
    this.padding = const EdgeInsets.all(8.0),
    this.child,
    this.icon,
  }) : assert(itemBuilder != null),
        assert(!(child != null && icon != null)), // fails if passed both parameters
        super(key: key);

  final PopupMenuItemBuilder<T> itemBuilder;
  final T initialValue;
  final PopupMenuItemSelected<T> onSelected;
  final PopupMenuCanceled onCanceled;
  final String tooltip;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final Icon icon;

  @override
  _SearchablePopupMenuButtonState<T> createState() => new _SearchablePopupMenuButtonState<T>();
}

class _SearchablePopupMenuButtonState<T> extends State<SearchablePopupMenuButton<T>> {
  void showButtonMenu() {
    final RenderBox button = context.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    final RelativeRect position = new RelativeRect.fromRect(
      new Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showSearchableMenu<T>(
      context: context,
      elevation: widget.elevation,
      items: widget.itemBuilder(context),
      initialValue: widget.initialValue,
      position: position,
    )
        .then<void>((T newValue) {
      if (!mounted)
        return null;
      if (newValue == null) {
        if (widget.onCanceled != null)
          widget.onCanceled();
        return null;
      }
      if (widget.onSelected != null)
        widget.onSelected(newValue);
    });
  }

  Icon _getIcon(TargetPlatform platform) {
    assert(platform != null);
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const Icon(Icons.more_vert);
      case TargetPlatform.iOS:
        return const Icon(Icons.more_horiz);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child != null ?
      new InkWell(
        onTap: showButtonMenu,
        child: widget.child,
      ) : new IconButton(
        icon: widget.icon ?? _getIcon(Theme.of(context).platform),
        padding: widget.padding,
        tooltip: widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
        onPressed: showButtonMenu,
    );
  }
}