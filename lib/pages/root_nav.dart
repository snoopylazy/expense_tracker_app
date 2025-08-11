import 'package:expense_tracker_app/pages/history_screen.dart';
import 'package:expense_tracker_app/pages/home_screen.dart';
import 'package:flutter/material.dart';

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;
  final PageController _controller = PageController();

  final pages = const [
    HomeScreen(),
    HistoryScreen(),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey.shade50,
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _index = i),
        children: pages,
      ),
      bottomNavigationBar: _CurvedBottomBar(
        index: _index,
        onChanged: (i) {
          _controller.animateToPage(
            i,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}

class _CurvedBottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _CurvedBottomBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final inactive = Colors.grey.shade500;
    final active = Colors.blue.shade600;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipPath(
        clipper: _TopCurveClipper(),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: index == 0,
                activeColor: active,
                inactiveColor: inactive,
                onTap: () => onChanged(0),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'History',
                selected: index == 1,
                activeColor: active,
                inactiveColor: inactive,
                onTap: () => onChanged(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Creates a soft concave curve along the top edge to give a "curved" style
class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 16);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 0);
    path.quadraticBezierTo(size.width * 0.75, 0, size.width, 16);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}