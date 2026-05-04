import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/principales/cursos.dart';
import 'package:tepetl/core/screens/principales/diccionario.dart';
import 'package:tepetl/core/screens/principales/resumen_ia.dart';
import 'package:tepetl/core/screens/principalesadmin/analisis_ia_admin.dart';
import 'package:tepetl/core/screens/principalesadmin/gestion_usuarios.dart';
import 'package:tepetl/core/screens/principalesadmin/inicio_admin.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos_admin.dart'; 
import 'package:tepetl/core/widgets/bars/bottom_nav.dart';
import 'package:tepetl/core/widgets/bars/inicio_appbar.dart';

import 'contexto_cultural.dart';
import 'inicio.dart';

class MainScreen extends StatefulWidget {
  final bool isAdmin;
  final int initialIndex;
  final String? selectedCursoId;

  const MainScreen({
    super.key,
    this.isAdmin = false,
    this.initialIndex = 2,
    this.selectedCursoId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int currentIndex;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;

    screens = [
      const DescubrirScreen(),
      
      // 1.Pestaña de Estadísticas IA
      widget.isAdmin 
          ? const AnalisisGeneralContent() 
          : const ResumenIAScreen(),
          
      // 2.Pestaña de Inicio (Gestión de Lecciones / Mapa de Progreso)
      widget.isAdmin 
          ? const InicioAdminScreen() 
          : InicioScreen(selectedCursoId: widget.selectedCursoId),
          
      // 3.Pestaña de Cursos (NUEVO AJUSTE)
      widget.isAdmin 
          ? const CursosAdminScreen()
          : const CursosScreen(),
      widget.isAdmin 
          ? const DirectorioUsuariosScreen()
          : const DiccionarioScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: InicioAppBar(isDark: isDark),
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNav(
        isAdmin: widget.isAdmin,
        isDark: isDark,
        currentIndex: currentIndex,
        onTap: (i) {
          setState(() => currentIndex = i);
        },
      ),
    );
  }
}