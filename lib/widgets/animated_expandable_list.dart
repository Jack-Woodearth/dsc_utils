import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

class AnimatedExpandableSliverList<T> extends StatefulWidget {
  const AnimatedExpandableSliverList(
      {super.key,
      required this.items,
      required this.childBuilder,
      this.iconData = Icons.list,
      required this.title});
  final List<T> items;
  final Widget Function(dynamic) childBuilder;
  final IconData iconData;
  final String title;
  @override
  State<AnimatedExpandableSliverList> createState() =>
      _AnimatedExpandableSliverListState();
}

class _AnimatedExpandableSliverListState<T>
    extends State<AnimatedExpandableSliverList<T>> {
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();
  late List<T> _itemsBak = widget.items.toList();
  late List<T> _itemsDynamic = widget.items.toList();
  @override
  void didUpdateWidget(covariant AnimatedExpandableSliverList<T> oldWidget) {
    if (oldWidget.items != widget.items) {
      _itemsBak = widget.items.toList();
      _itemsDynamic = widget.items.toList();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _removeItem() {
    if (_itemsDynamic.isEmpty) {
      return;
    }
    var index = _itemsDynamic.length - 1;
    _itemsDynamic.removeAt(index);
    _listKey.currentState?.removeItem(
        index, (context, animation) => _buildChild(animation, index));
  }

  void _addItem(T item) {
    final int index = _itemsDynamic.length;
    _itemsDynamic.add(item);
    _listKey.currentState?.insertItem(index);
  }

  void _removeAll() {
    while (_itemsDynamic.isNotEmpty) {
      _removeItem();
    }
  }

  void _showAll() {
    for (var item in _itemsBak) {
      _addItem(item);
    }
  }

  void _toggleShow() {
    if (_itemsDynamic.isEmpty) {
      _showAll();
    } else {
      _removeAll();
    }
  }

  bool arrowUp = false;
  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        StatefulBuilder(builder: (context, update) {
          return TitleWithIconSliverList(
            icon: widget.iconData,
            onTap: () {
              update(() {
                arrowUp = !arrowUp;
              });
              _toggleShow();
            },
            title: widget.title,
            arrowUp: arrowUp,
          );
        }),
        SliverAnimatedList(
          key: _listKey,
          itemBuilder: (context, index, animation) => FadeTransition(
              opacity: animation, child: _buildChild(animation, index)),
          initialItemCount: _itemsDynamic.length,
        ),
      ],
    );
  }

  Widget _buildChild(Animation<double> animation, int index) {
    return SizeTransition(
        sizeFactor: animation, child: widget.childBuilder(_itemsBak[index]));
  }
}

class TitleWithIconSliverList extends StatelessWidget {
  const TitleWithIconSliverList({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.showArrow = true,
    this.arrowUp = false,
    this.iconColor,
  }) : super(key: key);
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showArrow;
  final bool arrowUp;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (context, index) => SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20, 0, 0),
                    child: SizedBox(
                      // onTap: onTap,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            icon,
                            color: iconColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          showArrow
                              ? ExpandIcon(
                                  onPressed: (v) {
                                    onTap();
                                  },
                                  isExpanded: arrowUp,
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ),
                ),
            childCount: 1));
  }
}
