import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? onExpandFilters;
  final String? originCity;

  const CustomAppBar({Key? key, this.onExpandFilters, this.originCity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: kToolbarHeight + 20,
      collapsedHeight: kToolbarHeight + 20,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/tren22.png', fit: BoxFit.cover),
            Container(
              color: Colors.black.withOpacity(0.2),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: SearchBarWidget(
                  onExpandFilters: onExpandFilters,
                  originCity: originCity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onExpandFilters;
  final String? originCity;

  const SearchBarWidget({Key? key, this.onExpandFilters, this.originCity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String originCity = "Alicante"; //Pruebas
    final displayText = "${originCity ?? "Tu zona"} to All";

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
              children: [
                const Icon(Icons.search, color: Colors.white, size: 24.0),
                const SizedBox(width: 8.0),
                Text(
                  displayText,
                  style: const TextStyle(
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
