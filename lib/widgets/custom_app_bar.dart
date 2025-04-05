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
                // Fondo con la imagen
                Image.asset(
                  'assets/images/tren22.png',
                  fit: BoxFit.cover,
                ),
                // Aplicar el filtro de desenfoque cuando no esté expandido
                if (!isExpanded)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Color.fromRGBO(0, 0, 0, 0.2), // Opacidad usando Color.fromRGBO
                    ),
                  ),
                // Añadir una capa de color con opacidad a la imagen para darle un efecto
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
