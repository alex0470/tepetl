import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';

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
        'Explora la geografía sagrada de los náhuatl y cómo se consideraba que las montañas contenían el corazón mismo de la vida, la lluvia y los tesoros de la tierra.',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/varias-monta%C3%B1as-con-muchos-arboles-y-un-atardecer-al-fondo-396971.png?w=1024&h=1024',
    duracion: '8 min',
    contenido:
        'En el pensamiento náhuatl, las montañas no eran simples accidentes geográficos. '
        'Eran seres vivos, recipientes de agua y fertilidad, conocidos como "Tepetl". '
        'Cada cerro tenía su propio dueño espiritual, un tlalocan que guardaba las lluvias y las cosechas, '
        'y con quien la comunidad debía mantener una relación continua de ofrenda y gratitud.\n\n'
        'Los pueblos nahuas construyeron sus ciudades en relación directa con los volcanes y cerros circundantes. '
        'Tenochtitlan, por ejemplo, estaba orientada hacia el Popocatépetl y el Iztaccíhuatl, '
        'incorporando su energía sagrada al diseño urbano. Los templos eran, en sí mismos, montañas artificiales: '
        'pirámides que reproducían la forma del cerro sagrado para acercar al ser humano a los planos divinos.\n\n'
        'Las ceremonias en honor a los cerros, conocidas como "Tepeilhuitl", se celebraban en el decimoséptimo mes '
        'del calendario ritual. Durante estas festividades, se elaboraban figuras de amaranto con forma de montaña '
        'que representaban a las deidades de los cerros y la lluvia. Estas figuras eran luego consumidas '
        'ritualmente, en un acto de comunión sagrada con las fuerzas de la naturaleza.\n\n'
        'El Tepetl era también símbolo de poder político. Los gobernantes nahuas adoptaban nombres de montañas '
        'para expresar su autoridad permanente e inamovible. La palabra "altepetl" —agua-montaña— designaba '
        'precisamente a la ciudad-estado, uniendo los dos elementos fundamentales de la vida: '
        'el agua que nutre y la tierra elevada que protege.\n\n'
        'Existen además relatos de cerros que "hablan": en ciertos momentos del año, los sacerdotes '
        'subían a la cima en ayuno y vigilia para escuchar los mensajes que el cerro enviaba a través '
        'del viento, los truenos o las visiones inducidas por el ayuno prolongado. La montaña era, '
        'en ese sentido, un oráculo vivo.\n\n'
        'Hoy en día, comunidades indígenas del centro de México —nahuas, otomíes, mazahuas— siguen realizando '
        'peregrinaciones a los cerros sagrados, manteniendo viva una tradición de miles de años que reconoce '
        'en la montaña un ser vivo y generoso con quien el ser humano debe mantener una relación '
        'de respeto, escucha y reciprocidad permanente.',
  ),
  _Articulo(
    categoria: 'MITOLOGÍA',
    titulo: 'Quetzalcóatl: La Serpiente Emplumada',
    subtitulo:
        'El dios del viento y la sabiduría, creador de la humanidad y patrón del conocimiento en el mundo náhuatl.',
    imagen: 'https://69cd7410079511ce6100f7d7.imgix.net/fire.png?w=1024&h=1024',
    duracion: '10 min',
    contenido:
        'Quetzalcóatl, cuyo nombre significa "serpiente emplumada" o "serpiente de plumas preciosas", '
        'es una de las deidades más importantes y complejas del panteón mesoamericano. '
        'Su culto atravesó siglos y civilizaciones, desde Teotihuacan hasta los aztecas, '
        'dejando huellas imborrables en el arte, la arquitectura y el pensamiento de toda la región.\n\n'
        'Como dios del viento (Ehecatl), se le atribuye haber soplado para crear los rumbos del universo. '
        'Como dios de la sabiduría, fue el inventor del calendario, la escritura y las artes. '
        'También se le consideraba el patrono de los sacerdotes y los estudiantes del calmecac, '
        'la escuela donde se formaban las élites religiosas e intelectuales del mundo náhuatl.\n\n'
        'El mito de la creación del ser humano lo muestra descendiendo al Mictlan —el inframundo— '
        'para robar los huesos de los hombres anteriores. Al escapar, tropezó y los huesos se '
        'fragmentaron: de ahí la diversidad de tallas y formas del cuerpo humano. Luego mezcló '
        'esos huesos con su propia sangre y así nació la humanidad actual, llamada el "quinto sol".\n\n'
        'El mito más conocido narra cómo Quetzalcóatl, en su forma humana como rey de Tula, '
        'fue engañado por Tezcatlipoca mediante un espejo negro que le mostró su propia vejez y fealdad. '
        'Humillado y borracho, cometió actos que lo obligaron a abandonar su reino. '
        'Prometió regresar desde el oriente, promesa que los aztecas interpretarían fatalmente '
        'con la llegada de Hernán Cortés en 1519.\n\n'
        'Su dualidad es fascinante: como Ehecatl usaba una máscara con pico de ave para soplar el viento; '
        'como Venus era la estrella del amanecer, guiando a viajeros y comerciantes por rutas peligrosas. '
        'Sus templos eran circulares —únicos en Mesoamérica— para que el viento pudiera fluir sin obstáculos '
        'alrededor de la estructura.\n\n'
        'La influencia de Quetzalcóatl se extendió por toda Mesoamérica. En la cultura maya fue conocido como '
        'Kukulcán; en la quiché como Gucumatz. Su imagen —la serpiente cubierta de plumas de quetzal— '
        'aparece en monumentos desde Teotihuacan hasta Chichén Itzá, '
        'testimonio silencioso de una fe compartida a través de siglos y culturas.',
  ),
  _Articulo(
    categoria: 'HISTORIA',
    titulo: 'Tenochtitlan: La Ciudad sobre el Lago',
    subtitulo:
        'La capital del Imperio Azteca, fundada sobre un islote en el lago Texcoco, fue una de las ciudades más grandes del mundo en su época.',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/lluvia-cayendo-sobre-plantas-866138.png?w=1024&h=1024',
    duracion: '9 min',
    contenido:
        'Según la leyenda, los mexicas buscaron durante décadas el lugar donde se cumpliría la profecía: '
        'un águila posada sobre un nopal devorando una serpiente. En 1325, lo encontraron en un pequeño islote '
        'del lago Texcoco, en el corazón del Valle de México. Lo que parecía un sitio inhóspito '
        'se convertiría en el centro del mayor imperio que Mesoamérica había conocido.\n\n'
        'Lo que comenzó como un humilde asentamiento se transformó en dos siglos en una metrópolis de hasta '
        '300,000 habitantes, una de las ciudades más pobladas del mundo en 1500. '
        'Tenochtitlan impresionó a los propios conquistadores españoles: Bernal Díaz del Castillo escribió '
        'que al verla por primera vez creyeron estar ante una visión de ensueño, '
        'pues nada igual habían contemplado en España ni en ningún otro reino.\n\n'
        'La ciudad se organizaba en cuatro grandes barrios —campan— que se extendían desde el Templo Mayor, '
        'el centro ritual y político. Tres grandes calzadas la conectaban con tierra firme: '
        'la de Tlacopan al oeste, la de Iztapalapa al sur y la de Tepeyac al norte. '
        'Un sofisticado acueducto de doble tubo traía agua dulce desde Chapultepec, '
        'y miles de canoas circulaban diariamente por la red interna de canales.\n\n'
        'Las chinampas, islas artificiales construidas sobre el lago, rodeaban la ciudad y producían '
        'cosechas extraordinarias de maíz, frijol, chile, calabaza y flores. '
        'Este sistema agrícola —que aún puede verse en Xochimilco— fue uno de los más productivos '
        'del mundo preindustrial, capaz de alimentar a una población urbana de decenas de miles de personas.\n\n'
        'El Templo Mayor, corazón de la ciudad, era una pirámide doble de 45 metros de altura '
        'dedicada simultáneamente a Tlaloc, dios de la lluvia, y a Huitzilopochtli, dios solar de la guerra. '
        'Su orientación no era arbitraria: cada año, en las fechas del equinoccio, el sol nacía '
        'exactamente entre los dos templos de la cima, confirmando que la ciudad entera era un instrumento '
        'astronómico de precisión.\n\n'
        'Hoy, bajo las calles del centro histórico de Ciudad de México, los arqueólogos continúan '
        'descubriendo los vestigios de Tenochtitlan. Cada obra de metro o construcción nueva '
        'puede revelar una ofrenda, un muro, una escultura. La capital mexicana moderna '
        'se erige literalmente sobre los cimientos de una civilización extraordinaria '
        'que sigue hablando desde las profundidades de la tierra.',
  ),
];

const List<_Articulo> _infoArticulos = [
  _Articulo(
    categoria: 'FILOSOFÍA',
    titulo: "El concepto de 'Teotl'",
    subtitulo:
        'Entendiendo la dinámica, vivificando y eternamente presente fuerza divina en la cosmovisión náhuatl.',
    imagen: 'https://69cd7410079511ce6100f7d7.imgix.net/fire.png?w=1024&h=1024',
    duracion: '6 min',
    contenido:
        '"Teotl" es el concepto náhuatl que podríamos traducir aproximadamente como "dios" o "lo divino", '
        'aunque su significado es mucho más profundo y abarcador que cualquier traducción occidental.\n\n'
        'Para los nahuas, Teotl no era un dios personal o un ser con voluntad propia, '
        'sino una fuerza sagrada, dinámica y siempre cambiante que permea toda la existencia. '
        'Era simultáneamente la fuente de vida y de destrucción, de orden y de caos, '
        'uniendo en sí mismo los opuestos que la filosofía occidental tendería a separar.\n\n'
        'Este concepto se relaciona estrechamente con el "tonalli", la energía solar y vital '
        'que cada ser humano recibe al nacer según el día del calendario ritual en que llega al mundo. '
        'El tonalli determinaba el carácter, los talentos y el destino general de la persona, '
        'aunque podía fortalecerse o debilitarse según las acciones rituales y morales a lo largo de la vida.\n\n'
        'Los tlamatinime —sabios y filósofos nahuas— desarrollaron reflexiones profundas en torno a Teotl. '
        'Para ellos, todo el universo era una manifestación de esta fuerza divina en constante movimiento. '
        'El ser humano, los animales, las plantas, los astros, el viento: todos eran expresiones distintas '
        'de un mismo Teotl que nunca se detiene.\n\n'
        'Algunos estudiosos modernos han comparado Teotl con conceptos de otras tradiciones: '
        'el Tao chino, el Brahman hindú, o el "ser" de la filosofía griega. Sin embargo, '
        'los nahuas le daban una dimensión profundamente moral: actuar en armonía con Teotl '
        'era la fuente del bien; apartarse de esa armonía generaba caos, enfermedad y destrucción. '
        'La ética náhuatl era, en ese sentido, una ética cósmica.',
  ),
  _Articulo(
    categoria: 'POESÍA',
    titulo: 'Flores y música',
    subtitulo:
        "'Xochitl, Cuicatl' - La metáfora de la poesía, el arte y la búsqueda de verdad en el mundo náhuatl.",
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/flower.png?w=1024&h=1024',
    duracion: '5 min',
    contenido:
        '"In xochitl, in cuicatl" — "la flor y el canto" — era la expresión náhuatl para referirse '
        'a la poesía, la música y las artes en general. Esta metáfora no era casual: '
        'las flores son efímeras y perfumadas, y los cantos son etéreos e intangibles. '
        'Ambos apuntan a algo que va más allá de lo visible y lo permanente.\n\n'
        'Para los tlamatinime, los sabios nahuas, el arte era la única manera de expresar '
        'la verdad sobre el mundo transitorio en que vivimos. La filosofía náhuatl partía '
        'de una pregunta fundamental: ¿es verdad lo que vemos? ¿Es posible decir palabras verdaderas '
        'sobre la tierra? La respuesta era "in xochitl, in cuicatl": solo el arte rozaba la verdad.\n\n'
        'El poeta más célebre del mundo náhuatl fue Nezahualcóyotl, rey-poeta de Texcoco (1402-1472), '
        'cuyas obras reflexionan con asombrosa profundidad sobre la fugacidad de la vida, '
        'la naturaleza de lo divino y la búsqueda del "verdadero Dios" —una figura singular '
        'que algunos interpretaron como un impulso monoteísta dentro del politeísmo náhuatl.\n\n'
        'Sus poemas, transmitidos oralmente durante generaciones y recopilados por frailes tras la conquista, '
        'siguen emocionando a lectores de todo el mundo. Su pregunta más famosa resuena '
        'con fuerza intacta: "¿Es verdad que se vive en la tierra? No para siempre en la tierra, '
        'solo un poco aquí. Aunque sea de jade se quiebra, aunque sea de oro se rompe, '
        'aunque sea plumaje de quetzal se desgarra. No para siempre en la tierra, solo un poco aquí."\n\n'
        'La tradición poética náhuatl sobrevivió a la conquista en manuscritos como el '
        'Cantares Mexicanos y los Romances de los Señores de Nueva España, '
        'testimonios únicos de una literatura oral de extraordinaria belleza y complejidad filosófica.',
  ),
  _Articulo(
    categoria: 'DEIDADES',
    titulo: 'Tlaloc: Señor de la Lluvia',
    subtitulo:
        'La deidad de la lluvia y lo terrenal, dadora de vida y de tempestad, venerada durante más de dos mil años.',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/lluvia-cayendo-sobre-plantas-866138.png?w=1024&h=1024',
    duracion: '7 min',
    contenido:
        'Tlaloc era el dios de la lluvia, del rayo y de la fertilidad terrestre. '
        'Su nombre proviene del náhuatl "tlalli" (tierra) y "oc" (estar en la superficie de algo), '
        'sugiriendo una presencia inmanente y constante en la tierra misma. '
        'Era un dios ambivalente: podía dar vida con la lluvia generosa o arrebatarla '
        'con las inundaciones, el granizo y los rayos.\n\n'
        'Su culto fue uno de los más antiguos y extendidos de Mesoamérica, antecediendo incluso '
        'a la civilización azteca por más de mil años. En Teotihuacan ya existían pinturas murales '
        'dedicadas a él, con sus característicos ojos circulares y sus colmillos curvados. '
        'En el Templo Mayor de Tenochtitlan, Tlaloc compartía la cima con Huitzilopochtli, '
        'el dios solar de la guerra —una dualidad que expresaba las dos fuentes del poder mexica: '
        'el sustento agrícola y la expansión militar.\n\n'
        'Los niños pequeños eran sus ofrendas más preciadas. Se creía que su llanto —que evocaba '
        'la lluvia— era especialmente grato al dios. Los sacerdotes interpretaban el llanto '
        'de los niños como una señal favorable: si lloraban al ser ofrecidos, la lluvia vendría. '
        'Al morir iban directamente al paraíso acuático de Tlaloc, el Tlalocan, '
        'descrito como un jardín de eterna abundancia, flores y música.\n\n'
        'Tlaloc se reconoce fácilmente en el arte prehispánico por sus grandes ojos circulares '
        '—a menudo formados por serpientes entrelazadas— sus colmillos curvados que evocan '
        'el agua que cae, y sus anteojeras características. Era de color azul-verde, '
        'el color del agua y de la vegetación viva. Su cuerpo a veces se pintaba como la lluvia misma.\n\n'
        'Sus ayudantes, los tlaloque, habitaban en las cimas de las cuatro montañas cardinales '
        'y eran los encargados de liberar o retener las lluvias. Cada uno controlaba un tipo diferente: '
        'lluvias benéficas, heladas, granizo y sequía. Las comunidades agrícolas nahuas '
        'negociaban con ellos a través de ofrendas, ayunos y ceremonias en los cerros, '
        'una tradición que en muchas comunidades indígenas continúa hasta el día de hoy.',
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
      MaterialPageRoute(builder: (_) => _ArticuloScreen(articulo: articulo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 700;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? double.infinity : 1200),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * (isWide ? 0.02 : 0.04),
                    vertical: sw * (isWide ? 0.03 : 0.04),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (isWide)
                        _WideLayout(
                          heroArticulos: _heroArticulos,
                          infoArticulos: _infoArticulos,
                          pageController: _pageController,
                          heroPage: _heroPage,
                          onPageChanged: (i) => setState(() => _heroPage = i),
                          onTap: _abrirArticulo,
                          isDark: isDark,
                        )
                      else
                        _MobileLayout(
                          heroArticulos: _heroArticulos,
                          infoArticulos: _infoArticulos,
                          pageController: _pageController,
                          heroPage: _heroPage,
                          onPageChanged: (i) => setState(() => _heroPage = i),
                          onTap: _abrirArticulo,
                          isDark: isDark,
                        ),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Layout Ancho (Desktop / Tablet) ──────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final List<_Articulo> heroArticulos;
  final List<_Articulo> infoArticulos;
  final PageController pageController;
  final int heroPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<_Articulo> onTap;
  final bool isDark;

  const _WideLayout({
    required this.heroArticulos,
    required this.infoArticulos,
    required this.pageController,
    required this.heroPage,
    required this.onPageChanged,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 560,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _HeroCarousel(
                      articulos: heroArticulos,
                      controller: pageController,
                      currentPage: heroPage,
                      onPageChanged: onPageChanged,
                      onTap: onTap,
                      height: 520,
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -80,

                      child: _HeroPreviewCard(
                        articulo: heroArticulos[heroPage],

                        onTap: () =>
                            onTap(heroArticulos[heroPage]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          flex: 45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                isDark: isDark,
                text: '¿Lo sabías?',
              ),

              const SizedBox(height: 12),

              ...infoArticulos.map(
                (a) => _InfoCard(
                  isDark: isDark,
                  articulo: a,
                  onTap: () => onTap(a),
                ),
              ),

              const SizedBox(height: 16),

              _QuizCard(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Layout Móvil ──────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final List<_Articulo> heroArticulos;
  final List<_Articulo> infoArticulos;
  final PageController pageController;
  final int heroPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<_Articulo> onTap;
  final bool isDark;

  const _MobileLayout({
    required this.heroArticulos,
    required this.infoArticulos,
    required this.pageController,
    required this.heroPage,
    required this.onPageChanged,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCarousel(
          articulos: heroArticulos,
          controller: pageController,
          currentPage: heroPage,
          onPageChanged: onPageChanged,
          onTap: onTap,
          height: 260,
        ),
        const SizedBox(height: 20),
        _SectionTitle(isDark: isDark, text: '¿Lo sabías?'),
        const SizedBox(height: 12),
        ...infoArticulos.map(
          (a) => _InfoCard(isDark: isDark, articulo: a, onTap: () => onTap(a)),
        ),
        const SizedBox(height: 20),
        _QuizCard(),
      ],
    );
  }
}

// ── Helpers compartidos ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final bool isDark;
  final String text;
  const _SectionTitle({required this.isDark, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 10, color: AppColors.secundario),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: isDark ? AppColors.textoClaro : AppColors.textoSecundario,
          ),
        ),
      ],
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secundario.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.secundario,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.center_focus_strong, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Reto diario: cultura viva',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  'Pon a prueba tus conocimientos sobre los mitos y tradiciones',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.secundario.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}

// ── _HeroPreviewCard — onTap inyectado desde _WideLayout ─────────────────────

class _HeroPreviewCard extends StatelessWidget {
  final _Articulo articulo;
  final VoidCallback onTap;

  const _HeroPreviewCard({required this.articulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avance del artículo',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            articulo.titulo,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            articulo.subtitulo,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            articulo.contenido,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          // "Ver más detalles" dispara el onTap del padre (_abrirArticulo)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secundario,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Ver más detalles',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
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
  final double height;

  const _HeroCarousel({
    required this.articulos,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTap,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
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
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowButton(
              icon: Icons.chevron_left,
              onTap: currentPage > 0
                  ? () => controller.previousPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            ...List.generate(
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
            const SizedBox(width: 8),
            _ArrowButton(
              icon: Icons.chevron_right,
              onTap: currentPage < articulos.length - 1
                  ? () => controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    )
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap != null ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.secundario.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.secundario),
        ),
      ),
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
            Image.network(
              articulo.imagen,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: Colors.grey.shade800),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.80),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secundario.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      articulo.categoria,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    articulo.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    articulo.subtitulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white60, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        articulo.duracion,
                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secundario,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          minimumSize: const Size(120, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Leer artículo',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(3, 4),
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
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: isDark ? AppColors.textoClaro : AppColors.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    articulo.subtitulo,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textoClaro : AppColors.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aprende más...',
                    style: TextStyle(
                      color: AppColors.secundario,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                articulo.imagen,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 76,
                  height: 76,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
    final isWide = sw > 700;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  BotonAtras(
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Text(
                      articulo.categoria,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
              child: isWide
                  ? _ArticuloWide(articulo: articulo, isDark: isDark)
                  : _ArticuloNarrow(articulo: articulo, isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Artículo: layout ancho ────────────────────────────────────────────────────

class _ArticuloWide extends StatelessWidget {
  final _Articulo articulo;
  final bool isDark;

  const _ArticuloWide({required this.articulo, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Columna izquierda: imagen + meta (sin botón Volver) ──────
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    articulo.imagen,
                    height: 340,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(height: 340, color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.secundario.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        articulo.categoria,
                        style: const TextStyle(
                          color: AppColors.secundario,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 15, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      articulo.duracion,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 48),

          // ── Columna derecha: texto ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulo.titulo,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  articulo.subtitulo,
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Divider(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 20),
                Text(
                  articulo.contenido,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.9,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Artículo: layout estrecho (móvil) ────────────────────────────────────────

class _ArticuloNarrow extends StatelessWidget {
  final _Articulo articulo;
  final bool isDark;

  const _ArticuloNarrow({required this.articulo, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.all(sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              articulo.imagen,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(height: 220, color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secundario.withValues(alpha: 0.15),
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
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                articulo.duracion,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            articulo.titulo,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            articulo.subtitulo,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            articulo.contenido,
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}