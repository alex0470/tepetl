import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart'; // Asegúrate de que esta ruta sea correcta en tu proyecto

// ── Modelos ───────────────────────────────────────────────────────────────────

class _Categoria {
  final String nombre;
  final IconData icono;
  final Color colorFondo;
  final Color colorIcono;

  const _Categoria({
    required this.nombre,
    required this.icono,
    required this.colorFondo,
    required this.colorIcono,
  });
}

class _Frase {
  final String nahuatl;
  final String espanol;
  const _Frase(this.nahuatl, this.espanol);
}

class _EntradaDiccionario {
  final String palabra;
  final String traduccion;
  final String fonetica;
  final String contextoCultural;
  final IconData icono;
  final String categoria; // Agregado para filtrar por categoría
  final List<_Frase> frases;

  const _EntradaDiccionario({
    required this.palabra,
    required this.traduccion,
    required this.fonetica,
    required this.contextoCultural,
    required this.icono,
    required this.categoria,
    required this.frases,
  });
}

// ── Datos Mock ────────────────────────────────────────────────────────────────

final List<_Categoria> _categorias = [
  _Categoria(
      nombre: 'Naturaleza',
      icono: Icons.eco_outlined,
      colorFondo: AppColors.azul1.withValues(alpha: 0.2),
      colorIcono: AppColors.azul1),
  _Categoria(
      nombre: 'Animales',
      icono: Icons.pets,
      colorFondo: AppColors.naranja1.withValues(alpha: 0.2),
      colorIcono: AppColors.naranja1),
  _Categoria(
      nombre: 'Espíritu',
      icono: Icons.auto_awesome,
      colorFondo: AppColors.morado1.withValues(alpha: 0.2),
      colorIcono: AppColors.morado1),
  _Categoria(
      nombre: 'Hogar',
      icono: Icons.home_outlined,
      colorFondo: AppColors.amarillo1.withValues(alpha: 0.2),
      colorIcono: AppColors.amarillo1),
];

// Entrada especial para la palabra del día
const _EntradaDiccionario _palabraDelDia = _EntradaDiccionario(
  palabra: 'Cempasúchil',
  traduccion: 'Flor de veinte pétalos',
  fonetica: '/cem-pa-sú-chil/',
  contextoCultural:
      'Del náhuatl "Cempohualxochitl" (veinte flores). Su aroma y color guían a las almas hacia el altar en la tradición del Día de Muertos.',
  icono: Icons.local_florist_outlined,
  categoria: 'Naturaleza',
  frases: [
    _Frase('Cempohualxochitl cualli', 'La flor de cempasúchil es buena'),
  ],
);

const List<_EntradaDiccionario> _entradas = [
  _EntradaDiccionario(
    palabra: 'Atl',
    traduccion: 'Agua / Fuente de vida',
    fonetica: '/atl/',
    contextoCultural:
        'El agua es uno de los elementos más sagrados. En combinación con tepetl (montaña), forma el concepto de altépetl, que significa pueblo o ciudad.',
    icono: Icons.water_drop_outlined,
    categoria: 'Naturaleza',
    frases: [
      _Frase('In atl chipahuac', 'El agua es limpia'),
    ],
  ),
  _EntradaDiccionario(
    palabra: 'Tonatiuh',
    traduccion: 'Sol / El que va iluminando',
    fonetica: '/to-ná-tiuh/',
    contextoCultural:
        'Representa al quinto sol en la mitología mexica, la deidad solar que rige la era actual y exige movimiento continuo.',
    icono: Icons.wb_sunny_outlined,
    categoria: 'Espíritu',
    frases: [
      _Frase('Tonatiuh tlahuía', 'El sol ilumina'),
    ],
  ),
  _EntradaDiccionario(
    palabra: 'Tepetl',
    traduccion: 'Montaña / Cerro sagrado',
    fonetica: '/té-petl/',
    contextoCultural:
        'En la filosofía Náhuatl, Tepetl no es solo una formación geográfica. Es un ente sagrado que alberga el agua. Las montañas eran vistas como vasijas gigantes que guardaban las nubes y el sustento de la vida.',
    icono: Icons.landscape_outlined,
    categoria: 'Naturaleza',
    frases: [
      _Frase('In tepetl cualli', 'La montaña es buena'),
      _Frase('Niteco tlacpac in tepetl', 'Estoy en la cima de la montaña'),
    ],
  ),
  _EntradaDiccionario(
    palabra: 'Metztli',
    traduccion: 'Luna / Centro del maguey',
    fonetica: '/méts-tli/',
    contextoCultural:
        'Asociada a la feminidad, la fertilidad y la agricultura. En el mito, el conejo en la luna fue arrojado por los dioses para atenuar su brillo.',
    icono: Icons.nightlight_outlined,
    categoria: 'Espíritu',
    frases: [
      _Frase('Metztli cualo', 'Eclipse de luna (la luna es comida)'),
    ],
  ),
  _EntradaDiccionario(
    palabra: 'Calli',
    traduccion: 'Casa / Hogar',
    fonetica: '/cál-li/',
    contextoCultural:
        'La casa era el centro del universo familiar, construida usualmente con adobe. Además, es uno de los signos de los días en el calendario mexica (Tonalpohualli).',
    icono: Icons.home_outlined,
    categoria: 'Hogar',
    frases: [
      _Frase('Nocaltzin', 'Mi venerable casa'),
      _Frase('Calli cualli', 'Buena casa'),
    ],
  ),
  _EntradaDiccionario(
    palabra: 'Misto',
    traduccion: 'Gato',
    fonetica: '/mís-to/',
    contextoCultural:
        'Una adaptación fonética posterior a la conquista para referirse a los gatos domésticos traídos por los españoles.',
    icono: Icons.pets,
    categoria: 'Animales',
    frases: [
      _Frase('Misto cochi', 'El gato duerme'),
    ],
  ),
  _EntradaDiccionario(
    palabra: 'Itzcuintli',
    traduccion: 'Perro',
    fonetica: '/its-cuín-tli/',
    contextoCultural:
        'Animal de compañía sagrado que, según la creencia, ayudaba a las almas a cruzar el río Chiconahuapan hacia el Mictlán.',
    icono: Icons.pets_outlined,
    categoria: 'Animales',
    frases: [
      _Frase('Itzcuintli choca', 'El perro ladra/llora'),
    ],
  ),
  _EntradaDiccionario(
    palabra: 'Yolotl',
    traduccion: 'Corazón',
    fonetica: '/yó-lotl/',
    contextoCultural:
        'Sede de la vitalidad, el alma y la memoria. En la cosmovisión nahua, uno debe crear "un rostro y un corazón" (In ixtli in yolotl) para estar completo.',
    icono: Icons.favorite_border,
    categoria: 'Espíritu',
    frases: [
      _Frase('Noyolo', 'Mi corazón'),
    ],
  ),
];

// ── Pantalla Principal (Wrapper Responsivo) ───────────────────────────────────

class DiccionarioScreen extends StatefulWidget {
  const DiccionarioScreen({super.key});

  @override
  State<DiccionarioScreen> createState() => _DiccionarioScreenState();
}

class _DiccionarioScreenState extends State<DiccionarioScreen> {
  _EntradaDiccionario? palabraSeleccionada;
  String _busqueda = '';
  String? _categoriaSeleccionada;
  bool _mostrarTodo = false;

  void _abrirDetalle(_EntradaDiccionario entrada, bool isWide) {
    if (isWide) {
      setState(() {
        palabraSeleccionada = entrada;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _DiccionarioDetallePantalla(entrada: entrada),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Seleccionar por defecto "Tepetl" para pantallas grandes
    palabraSeleccionada = _entradas.firstWhere((e) => e.palabra == 'Tepetl',
        orElse: () => _entradas.first);
  }

  // Filtrado de entradas
  List<_EntradaDiccionario> get _entradasFiltradas {
    List<_EntradaDiccionario> filtradas = _entradas.where((e) {
      final coincideBusqueda =
          e.palabra.toLowerCase().contains(_busqueda.toLowerCase()) ||
              e.traduccion.toLowerCase().contains(_busqueda.toLowerCase());
      final coincideCategoria = _categoriaSeleccionada == null ||
          e.categoria == _categoriaSeleccionada;
      return coincideBusqueda && coincideCategoria;
    }).toList();

    // Si no se ha dado a "Ver todo" y no hay búsqueda/filtro activo, mostrar solo 3
    if (!_mostrarTodo && _busqueda.isEmpty && _categoriaSeleccionada == null) {
      return filtradas.take(3).toList();
    }
    return filtradas;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 900;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      // SafeArea envuelve el cuerpo completo para que no se encime con la barra de estado superior
      body: SafeArea(
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna Izquierda: Lista
                  SizedBox(
                    width: 800,
                    child: _DiccionarioListado(
                      isDark: isDark,
                      entradasFiltradas: _entradasFiltradas,
                      busqueda: _busqueda,
                      categoriaSeleccionada: _categoriaSeleccionada,
                      mostrarTodo: _mostrarTodo,
                      onBusquedaChanged: (val) =>
                          setState(() => _busqueda = val),
                      onCategoriaTap: (cat) {
                        setState(() {
                          _categoriaSeleccionada =
                              _categoriaSeleccionada == cat ? null : cat;
                        });
                      },
                      onVerTodoTap: () =>
                          setState(() => _mostrarTodo = !_mostrarTodo),
                      onEntradaTap: (e) => _abrirDetalle(e, true),
                    ),
                  ),
                  // Separador
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: isDark ? AppColors.extraOscuro120 : AppColors.extra120,
                  ),
                  // Columna Derecha: Detalle
                  Expanded(
                    child: palabraSeleccionada == null
                        ? Center(
                            child: Text(
                              'Selecciona una palabra',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                          )
                        : _DetallePalabraView(
                            entrada: palabraSeleccionada!,
                            isDark: isDark,
                          ),
                  ),
                ],
              )
            : _DiccionarioListado(
                isDark: isDark,
                entradasFiltradas: _entradasFiltradas,
                busqueda: _busqueda,
                categoriaSeleccionada: _categoriaSeleccionada,
                mostrarTodo: _mostrarTodo,
                onBusquedaChanged: (val) => setState(() => _busqueda = val),
                onCategoriaTap: (cat) {
                  setState(() {
                    _categoriaSeleccionada =
                        _categoriaSeleccionada == cat ? null : cat;
                  });
                },
                onVerTodoTap: () =>
                    setState(() => _mostrarTodo = !_mostrarTodo),
                onEntradaTap: (e) => _abrirDetalle(e, false),
              ),
      ),
    );
  }
}

// ── Lado Izquierdo: Listado (Móvil y Master) ──────────────────────────────────

class _DiccionarioListado extends StatelessWidget {
  final bool isDark;
  final List<_EntradaDiccionario> entradasFiltradas;
  final String busqueda;
  final String? categoriaSeleccionada;
  final bool mostrarTodo;
  final ValueChanged<String> onBusquedaChanged;
  final ValueChanged<String> onCategoriaTap;
  final VoidCallback onVerTodoTap;
  final Function(_EntradaDiccionario) onEntradaTap;

  const _DiccionarioListado({
    required this.isDark,
    required this.entradasFiltradas,
    required this.busqueda,
    required this.categoriaSeleccionada,
    required this.mostrarTodo,
    required this.onBusquedaChanged,
    required this.onCategoriaTap,
    required this.onVerTodoTap,
    required this.onEntradaTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: onBusquedaChanged,
            decoration: InputDecoration(
              hintText: 'Busca una palabra o concepto...',
              hintStyle: TextStyle(fontSize: 14, color: Theme.of( context).colorScheme.onSurface.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              filled: true,
              fillColor: isDark
                  ? AppColors.fondoOscuroSecundario
                  : AppColors.fondoSecundario,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                    color: isDark ? AppColors.textoClaro.withValues(alpha: 0.4) : AppColors.textoSecundario.withValues(alpha: 0.4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                    color: isDark ? AppColors.textoClaro.withValues(alpha: 0.4) : AppColors.textoSecundario.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: AppColors.secundario),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Palabra del Día (se oculta si hay texto en el buscador o hay filtro por categoría)
          if (busqueda.isEmpty && categoriaSeleccionada == null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Palabra del Día',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'DESTACADO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.naranja1,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => onEntradaTap(_palabraDelDia),
              child: _TarjetaPalabraDia(isDark: isDark),
            ),
            const SizedBox(height: 24),
          ],

          // Categorías
          Text(
            'Categorías',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _categorias
                .map((c) => _ItemCategoria(
                      categoria: c,
                      seleccionada: categoriaSeleccionada == c.nombre,
                      onTap: () => onCategoriaTap(c.nombre),
                    ))
                .toList(),
          ),

          const SizedBox(height: 24),

          // Entradas Recientes / Resultados
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (busqueda.isNotEmpty || categoriaSeleccionada != null)
                    ? 'Resultados'
                    : 'Entradas Recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color:Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (busqueda.isEmpty && categoriaSeleccionada == null)
                GestureDetector(
                  onTap: onVerTodoTap,
                  child: Text(
                    mostrarTodo ? 'Ver menos' : 'Ver todo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secundario,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (entradasFiltradas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No se encontraron resultados.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 18),
                ),
              ),
            )
          else
            Column(
              children: entradasFiltradas
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TarjetaEntrada(
                          entrada: e,
                          isDark: isDark,
                          onTap: () => onEntradaTap(e),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

// ── Lado Derecho: Pantalla Independiente de Detalle (Para Móviles) ────────────

class _DiccionarioDetallePantalla extends StatelessWidget {
  final _EntradaDiccionario entrada;

  const _DiccionarioDetallePantalla({required this.entrada});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      // RESTAURAMOS EL APPBAR para poder ir hacia atrás en móviles
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
        title: Text(
          entrada.palabra, // Mostrar el nombre de la palabra como título
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: _DetallePalabraView(entrada: entrada, isDark: isDark),
      ),
    );
  }
}

// ── Vista de Detalle (Reusable para Móvil y Web) ──────────────────────────────

class _DetallePalabraView extends StatelessWidget {
  final _EntradaDiccionario entrada;
  final bool isDark;

  const _DetallePalabraView({
    required this.entrada,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título de la Palabra
          Text(
            entrada.palabra,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: AppColors.secundario,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entrada.traduccion
                .split(' / ')
                .first, // Solo muestra la traducción principal
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Botón Audio
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_circle_fill, size: 22),
            label: const Text(
              'Escuchar pronunciación',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secundario,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Tarjeta Contexto Cultural IA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.fondoOscuroSecundario
                  : AppColors.fondoSecundario, // Gris verdoso muy claro
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 18, color: AppColors.secundario),
                        const SizedBox(width: 8),
                        Text(
                          'CONTEXTO CULTURAL IA',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.secundario,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  entrada.contextoCultural,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Uso en Frases
          if (entrada.frases.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.format_quote,
                      size: 18, color: AppColors.secundario),
                  const SizedBox(width: 8),
                  Text(
                    'Uso en frases',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: entrada.frases
                  .map((f) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.fondoOscuroSecundario
                              : AppColors.fondoSecundario,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 2,
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.nahuatl,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secundario,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              f.espanol,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.95)
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Botón Generar Ejercicio
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.fondoOscuroSecundario
                    : AppColors.fondoSecundario,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 2,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome_outlined,
                      color: AppColors.secundario, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'Practicar esta palabra',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generar ejercicio rápido con IA',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Componentes Pequeños ──────────────────────────────────────────────────────

class _TarjetaPalabraDia extends StatelessWidget {
  final bool isDark;

  const _TarjetaPalabraDia({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
              'https://69cd7410079511ce6100f7d7.imgix.net/flower.png?w=600&h=400'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
            stops: const [0.3, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cempasúchil',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '/cem-pa-sú-chil/',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secundario,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Del náhuatl "Cempohualxochitl" (veinte flores). Su aroma y color guían a las almas hacia el altar en la tradición del Día de Muertos.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Explorar origen cultural',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amarillo1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward,
                    size: 14, color: AppColors.amarillo1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCategoria extends StatelessWidget {
  final _Categoria categoria;
  final bool seleccionada;
  final VoidCallback onTap;

  const _ItemCategoria({
    required this.categoria,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: categoria.colorFondo,
              borderRadius: BorderRadius.circular(16),
              border: seleccionada
                  ? Border.all(color: categoria.colorIcono, width: 2)
                  : null,
            ),
            child: Center(
              child: Icon(categoria.icono,
                  color: categoria.colorIcono, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            categoria.nombre,
            style: TextStyle(
              fontSize: 11,
              fontWeight: seleccionada ? FontWeight.bold : FontWeight.w600,
              color: seleccionada ? categoria.colorIcono : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaEntrada extends StatelessWidget {
  final _EntradaDiccionario entrada;
  final bool isDark;
  final VoidCallback onTap;

  const _TarjetaEntrada({
    required this.entrada,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(entrada.icono,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entrada.palabra,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entrada.traduccion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_outline,
                color: AppColors.azul1, size: 22),
            const SizedBox(width: 12),
            Icon(Icons.bookmark_border,
                color: AppColors.naranja1, size: 22),
          ],
        ),
      ),
    );
  }
}