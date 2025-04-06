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
                Image.asset('assets/images/tren22.png', fit: BoxFit.cover),
                // Aplicar el filtro de desenfoque cuando no esté expandido
                if (!isExpanded)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Color.fromRGBO(
                        0,
                        0,
                        0,
                        0.2,
                      ), // Opacidad usando Color.fromRGBO
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
                    child:
                        isExpanded
                            ? const SearchBarWidget() // Mostrar el widget de la barra de búsqueda
                            : AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity:
                                  0.0, // Mantener la opacidad en 0 cuando no está expandido
                              child:
                                  Container(), // Espacio vacío para evitar errores de diseño
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

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:
              isSearching
                  ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    onTapOutside: (event) {
                      // Close the search when tapping outside the TextField
                      setState(() {
                        isSearching = false;
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : GestureDetector(
                    onTap: () {
                      setState(() {
                        isSearching = true;
                      });
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
