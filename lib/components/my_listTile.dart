import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListtile extends StatelessWidget {
  final String title;
  final String trailing;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  const MyListtile({
    super.key,
    required this.title,
    required this.trailing,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: onEditPressed,
            icon: Icons.edit_outlined,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          SlidableAction(
            onPressed: onDeletePressed,
            icon: Icons.delete_outline,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          trailing: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              trailing,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
