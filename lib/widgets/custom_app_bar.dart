import 'dart:ui';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? onExpandFilters;

  const CustomAppBar({Key? key, this.onExpandFilters}) : super(key: key);

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
                Image.asset('assets/images/tren22.png', fit: BoxFit.cover),
                if (!isExpanded)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: const Color.fromRGBO(0, 0, 0, 0.2),
                    ),
                  ),
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2),
                    BlendMode.darken,
                  ),
                  child: Container(),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      bottom: isExpanded ? 16.0 : 8.0,
                      right: 16.0,
                    ),
                    child: isExpanded
                        ? SearchBarWidget(onExpandFilters: onExpandFilters)
                        : AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 0.0,
                      child: Container(),
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

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onExpandFilters;

  const SearchBarWidget({Key? key, this.onExpandFilters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (onExpandFilters != null) {
                onExpandFilters!();
              }
            },
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.white, size: 24.0),
                SizedBox(width: 8.0),
                Text(
                  "Alicante to All",
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
