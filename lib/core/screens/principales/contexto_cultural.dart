import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

// ── Modelo de artículo ────────────────────────────────────────────────────────

class _Articulo {
  final String categoria;
  final String titulo;
  final String subtitulo;
  final String imagen;
  final String duracion;
  final String contenido;

  const _Articulo({
    required this.categoria,
    required this.titulo,
    required this.subtitulo,
    required this.imagen,
    required this.duracion,
    required this.contenido,
  });
}

// ── Datos ─────────────────────────────────────────────────────────────────────

const List<_Articulo> _heroArticulos = [
  _Articulo(
    categoria: 'COSMOVISIÓN',
    titulo: 'La Montaña en el Pensamiento Náhuatl',
    subtitulo:
        'Explora la geografía sagrada de los náhuatl y cómo se consideraba que las montañas contenían...',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/varias-monta%C3%B1as-con-muchos-arboles-y-un-atardecer-al-fondo-396971.png?w=1024&h=1024',
    duracion: '5 min',
    contenido:
        'En el pensamiento náhuatl, las montañas no eran simples accidentes geográficos. '
        'Eran seres vivos, recipientes de agua y fertilidad, conocidos como "Tepetl". '
        'Cada cerro tenía su propio dueño espiritual, un tlalocan que guardaba las lluvias y las cosechas.\n\n'
        'Los pueblos nahuas construyeron sus ciudades en relación directa con los volcanes y cerros circundantes. '
        'Tenochtitlan, por ejemplo, estaba orientada hacia el Popocatépetl y el Iztaccíhuatl, '
        'incorporando su energía sagrada al diseño urbano.\n\n'
        'Las ceremonias en honor a los cerros, conocidas como "Tepeilhuitl", se celebraban en el decimoséptimo mes '
        'del calendario ritual. Durante estas festividades, se elaboraban figuras de amaranto con forma de montaña '
        'que representaban a las deidades de los cerros y la lluvia.',
  ),
  _Articulo(
    categoria: 'MITOLOGÍA',
    titulo: 'Quetzalcóatl: La Serpiente Emplumada',
    subtitulo:
        'El dios del viento y la sabiduría, creador de la humanidad y patrón del conocimiento...',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/fire.png?w=1024&h=1024',
    duracion: '7 min',
    contenido:
        'Quetzalcóatl, cuyo nombre significa "serpiente emplumada" o "serpiente de plumas preciosas", '
        'es una de las deidades más importantes del panteón mesoamericano.\n\n'
        'Como dios del viento (Ehecatl), se le atribuye haber soplado para crear los rumbos del universo. '
        'Como dios de la sabiduría, fue el inventor del calendario, la escritura y las artes.\n\n'
        'El mito más conocido narra cómo Quetzalcóatl, en su forma humana como rey de Tula, '
        'fue engañado por Tezcatlipoca y obligado a abandonar su reino. '
        'Prometió regresar desde el oriente, promesa que los aztecas interpretarían siglos después '
        'con la llegada de los conquistadores españoles.',
  ),
];

const List<_Articulo> _infoArticulos = [
  _Articulo(
    categoria: 'FILOSOFÍA',
    titulo: "El concepto de 'Teotl'",
    subtitulo:
        'Entendiendo la dinámica, vivificando y eternamente presente fuerza divina...',
    imagen: 'https://69cd7410079511ce6100f7d7.imgix.net/fire.png?w=1024&h=1024',
    duracion: '4 min',
    contenido:
        '"Teotl" es el concepto náhuatl que podríamos traducir aproximadamente como "dios" o "lo divino", '
        'aunque su significado es mucho más profundo y abarcador.\n\n'
        'Para los nahuas, Teotl no era un dios personal o un ser con voluntad propia, '
        'sino una fuerza sagrada, dinámica y siempre cambiante que permea toda la existencia. '
        'Era simultáneamente la fuente de vida y de destrucción, de orden y de caos.\n\n'
        'Este concepto se relaciona estrechamente con el "tonalli", la energía solar y vital '
        'que cada ser humano recibe al nacer y que determina su destino y carácter. '
        'El tonalli podía fortalecerse o debilitarse según las acciones rituales y morales de la persona.',
  ),
  _Articulo(
    categoria: 'POESÍA',
    titulo: 'Flores y música',
    subtitulo:
        "'Xochitl, Cuicatl' - La metáfora de la poesía, el arte y la belleza...",
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/flower.png?w=1024&h=1024',
    duracion: '3 min',
    contenido:
        '"In xochitl, in cuicatl" — "la flor y el canto" — era la expresión náhuatl para referirse '
        'a la poesía, la música y las artes en general.\n\n'
        'Para los tlamatinime, los sabios nahuas, el arte era la única manera de expresar '
        'la verdad sobre el mundo transitorio en que vivimos. Mientras que la vida es efímera '
        'como las flores, la poesía permite vislumbrar algo de lo divino.\n\n'
        'El poeta más célebre del mundo náhuatl fue Nezahualcóyotl, rey de Texcoco, '
        'cuyas obras reflexionan sobre la fugacidad de la vida, la naturaleza de lo divino '
        'y la búsqueda del "verdadero Dios".',
  ),
  _Articulo(
    categoria: 'DEIDADES',
    titulo: 'Lluvia de Tlaloc',
    subtitulo:
        'La deidad de la lluvia y lo terrenal, dadora de vida y de tempestad...',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/lluvia-cayendo-sobre-plantas-866138.png?w=1024&h=1024',
    duracion: '5 min',
    contenido:
        'Tlaloc era el dios de la lluvia, del rayo y de la fertilidad terrestre. '
        'Su nombre proviene del náhuatl "tlalli" (tierra) y "oc" (estar en la superficie de algo), '
        'sugiriendo una presencia inmanente en la tierra misma.\n\n'
        'Su culto fue uno de los más antiguos y extendidos de Mesoamérica, antecediendo incluso '
        'a la civilización azteca. En el Templo Mayor de Tenochtitlan, '
        'Tlaloc compartía la cima con Huitzilopochtli, el dios solar de la guerra.\n\n'
        'Los niños eran sus ofrendas más preciadas. Se creía que su llanto invocaba la lluvia, '
        'y que al morir iban directamente al paraíso acuático de Tlaloc, el Tlalocan, '
        'un lugar de abundancia eterna.',
  ),
];

// ── Pantalla principal ────────────────────────────────────────────────────────

class DescubrirScreen extends StatefulWidget {
  const DescubrirScreen({super.key});

  @override
  State<DescubrirScreen> createState() => _DescubrirScreenState();
}

class _DescubrirScreenState extends State<DescubrirScreen> {
  final PageController _pageController = PageController();
  int _heroPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _abrirArticulo(_Articulo articulo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ArticuloScreen(articulo: articulo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(sw * 0.04),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Hero deslizable ────────────────────────────────
                  _HeroCarousel(
                    articulos: _heroArticulos,
                    controller: _pageController,
                    currentPage: _heroPage,
                    onPageChanged: (i) => setState(() => _heroPage = i),
                    onTap: _abrirArticulo,
                  ),

                  const SizedBox(height: 20),

                  // ── Sección ¿Lo sabías? ──────────────────────────────
                  _sectionTitle('¿Lo sabías?', isDark),

                  const SizedBox(height: 12),

                  ..._infoArticulos.map(
                    (a) => _InfoCard(
                      isDark: isDark,
                      articulo: a,
                      onTap: () => _abrirArticulo(a),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Quiz card ──────────────────────────────────────
                  _quizCard(),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, bool isDark) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: AppColors.secundario),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: isDark ? AppColors.textoClaro : AppColors.textoSecundario,
          ),
        ),
      ],
    );
  }

  Widget _quizCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secundario.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Cuestionario de cultura diaria',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pon a prueba tus conocimientos sobre los mitos',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.secundario,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.play_arrow, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ── Hero Carousel ─────────────────────────────────────────────────────────────

class _HeroCarousel extends StatelessWidget {
  final List<_Articulo> articulos;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<_Articulo> onTap;

  const _HeroCarousel({
    required this.articulos,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Slides ────────────────────────────────────────────────────
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: articulos.length,
            physics: const PageScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => _HeroSlide(
              articulo: articulos[i],
              onTap: () => onTap(articulos[i]),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Indicadores ───────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            articulos.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == currentPage ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == currentPage
                    ? AppColors.secundario
                    : AppColors.secundario.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final _Articulo articulo;
  final VoidCallback onTap;

  const _HeroSlide({required this.articulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen
            Image.network(
              articulo.imagen,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: Colors.grey.shade800,
              ),
            ),

            // Gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Contenido
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secundario.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      articulo.categoria,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    articulo.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    articulo.subtitulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.white60, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        articulo.duracion,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secundario,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Leer artículo',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final _Articulo articulo;
  final VoidCallback onTap;

  const _InfoCard({
    required this.isDark,
    required this.articulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.fondoOscuroSecundario
              : AppColors.fondoSecundario,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 2,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    articulo.titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textoClaro
                          : AppColors.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    articulo.subtitulo,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textoClaro
                          : AppColors.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Aprende más...',
                    style: TextStyle(
                      color: AppColors.secundario,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                articulo.imagen,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pantalla de artículo ──────────────────────────────────────────────────────

class _ArticuloScreen extends StatelessWidget {
  final _Articulo articulo;

  const _ArticuloScreen({required this.articulo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Icon(Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  Expanded(
                    child: Text(
                      articulo.categoria,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secundario,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // ── Contenido ─────────────────────────────────────────────
            Expanded(
              child: Center(
                child: SizedBox(
                  width: sw > 700 ? 600 : double.infinity,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(sw * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            articulo.imagen,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              height: 220,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Categoría + tiempo
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secundario
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                articulo.categoria,
                                style: const TextStyle(
                                  color: AppColors.secundario,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              articulo.duracion,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Título
                        Text(
                          articulo.titulo,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color:
                                Theme.of(context).colorScheme.onSurface,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtítulo
                        Text(
                          articulo.subtitulo,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Divisor
                        Divider(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.1),
                        ),

                        const SizedBox(height: 16),

                        // Contenido
                        Text(
                          articulo.contenido,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.85),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Botón volver
                        Center(
                          child: Container(
                            width: 220,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.secundario.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.maybePop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secundario,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Volver',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}