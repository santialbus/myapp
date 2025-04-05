import 'dart:ui';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 150.0,
      collapsedHeight: kToolbarHeight,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final isExpanded = constraints.maxHeight > kToolbarHeight;

          return ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/tren22.png',
                  fit: BoxFit.cover,
                ),
                if (!isExpanded)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      bottom: isExpanded ? 16.0 : 8.0,
                      right: 16.0,
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isExpanded ? 1.0 : 0.0,
                      child: const Text(
                        "Tu estación más cercana: Alicante/Alacant",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
