import 'package:flutter/material.dart';

// Constantes de color basadas en tu diseño
class AppColors {
  static const Color primario = Color(0xFF009688); // Verde oscuro
  static const Color secundario = Color(0xFF00B074); // Verde vibrante
  static const Color background = Colors.white;
  static const Color cardShadow = Color(0x0A000000);
}

class DirectorioUsuariosScreen extends StatefulWidget {
  const DirectorioUsuariosScreen({super.key});

  @override
  State<DirectorioUsuariosScreen> createState() => _DirectorioUsuariosScreenState();
}

class _DirectorioUsuariosScreenState extends State<DirectorioUsuariosScreen> {
  // Datos simulados
  final List<Map<String, dynamic>> _usuarios = [
    {
      'nombre': 'Xochitl Juarez',
      'correo': 'xochitl@tepeyo.com',
      'nivel': 4,
      'progreso': '82%',
      'estado': 'online',
    },
    {
      'nombre': 'Tizoc Mendoza',
      'correo': 'tizoc.m@domain.mx',
      'nivel': 2,
      'progreso': '45%',
      'estado': 'offline',
    },
    {
      'nombre': 'Citlali Ramos',
      'correo': 'citlali.ramos@tepeyo.com',
      'nivel': 5,
      'progreso': '95%',
      'estado': 'online',
    },
    {
      'nombre': 'Eréndira Silva',
      'correo': 'erendira@banned.com',
      'estado': 'expulsado',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buscador
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por Nombre o Correo',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _FilterDropdown(label: 'Cursos: Náhuatl...'),
                  SizedBox(width: 8),
                  _FilterDropdown(label: 'Rol'),
                  SizedBox(width: 8),
                  _FilterDropdown(label: 'Estado'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ACCIONES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  '3 seleccionados',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionCard(
                  icon: Icons.block,
                  label: 'Expulsar',
                  iconColor: Colors.redAccent,
                  onTap: () {},
                ),
                _ActionCard(
                  icon: Icons.download_outlined,
                  label: 'Exportar',
                  iconColor: Colors.cyan,
                  onTap: () {},
                ),
                _ActionCard(
                  icon: Icons.refresh,
                  label: 'Recargar',
                  iconColor: Colors.orange,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Directorio de Usuarios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Directorio de Usuarios',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Ver todos (1,240)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de Usuarios
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _usuarios.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _UserCard(usuario: _usuarios[index]);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── NUEVA PANTALLA: PERFIL DE USUARIO ────────────────────────────────────────

class PerfilUsuarioScreen extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const PerfilUsuarioScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    // Datos simulados para los cursos basados en la imagen
    final bool isExpulsado = usuario['estado'] == 'expulsado';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PERFIL DE USUARIO',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Cabecera: Avatar, Nombre, Correo, Badge
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    usuario['nombre'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario['correo'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isExpulsado ? Colors.red.withOpacity(0.1) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isExpulsado ? 'Expulsado' : 'Estudiante',
                      style: TextStyle(
                        color: isExpulsado ? Colors.red : const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Se unió en Ene 2024',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Estadísticas (Nivel, Progreso, Racha)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  value: usuario['nivel']?.toString() ?? '-',
                  label: 'Nivel Actual',
                  icon: Icons.star_border,
                  color: Colors.orange,
                ),
                Container(width: 1, height: 40, color: Colors.grey[200]),
                _StatItem(
                  value: usuario['progreso'] ?? '-',
                  label: 'Progreso',
                  icon: Icons.trending_up,
                  color: AppColors.secundario,
                ),
                Container(width: 1, height: 40, color: Colors.grey[200]),
                const _StatItem(
                  value: '12',
                  label: 'Racha (Días)',
                  icon: Icons.local_fire_department_outlined,
                  color: Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Sección: Progreso en Cursos
            Row(
              children: const [
                Text(
                  'Progreso en Cursos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tarjetas de Cursos
            _CourseProgressCard(
              title: 'Náhuatl Básico A1',
              progressText: '10/12 Módulos completados',
              progressValue: 0.83,
              statusText: 'En curso',
              statusColor: Colors.orange,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 12),
            _CourseProgressCard(
              title: 'Vocabulario Cultural',
              progressText: 'Completado',
              progressValue: 1.0,
              statusText: 'Finalizado',
              statusColor: AppColors.secundario,
              iconColor: AppColors.secundario,
            ),
            const SizedBox(height: 40),

            // Botón de Descargar Reporte
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, color: Colors.black87),
                label: const Text(
                  'Descargar Reporte',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Componentes Auxiliares ───

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _CourseProgressCard extends StatelessWidget {
  final String title;
  final String progressText;
  final double progressValue;
  final String statusText;
  final Color statusColor;
  final Color iconColor;

  const _CourseProgressCard({
    required this.title,
    required this.progressText,
    required this.progressValue,
    required this.statusText,
    required this.statusColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.book_outlined, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            progressText,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[200],
              color: statusColor,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const _UserCard({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final bool isExpulsado = usuario['estado'] == 'expulsado';
    final bool isOnline = usuario['estado'] == 'online';

    Color statusColor;
    if (isExpulsado) {
      statusColor = Colors.red;
    } else if (isOnline) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilUsuarioScreen(usuario: usuario),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, color: Colors.grey[400]),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        usuario['nombre'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isExpulsado ? Colors.grey[600] : Colors.black,
                        ),
                      ),
                      if (isExpulsado) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.lock_outline, color: Colors.red, size: 14),
                      ]
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    usuario['correo'],
                    style: TextStyle(
                      color: isExpulsado ? Colors.grey[500] : AppColors.secundario,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (!isExpulsado) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secundario.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Nivel ${usuario['nivel']}',
                            style: const TextStyle(
                              color: AppColors.secundario,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          usuario['progreso'],
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Expulsado',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secundario.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.secundario,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  const _FilterDropdown({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2E7D32), size: 16),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.27,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}