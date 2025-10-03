import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/theme_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección Apariencia
          _SectionHeader(title: 'Apariencia'),
          Card(
            child: Obx(() => SwitchListTile(
              title: const Text('Tema oscuro'),
              subtitle: const Text('Cambiar entre tema claro y oscuro'),
              value: controller.isDarkMode,
              onChanged: controller.toggleTheme,
              secondary: Icon(
                controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            )),
          ),

          // Sección Información del Sistema
          _SectionHeader(title: 'Sistema'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Servicio de Datos'),
                  subtitle: const Text('Usando: Firebase (Windows)'),
                  leading: const Icon(
                    Icons.cloud_done,
                    color: Colors.green,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Versión'),
                  subtitle: const Text('1.0.0'),
                  leading: const Icon(Icons.info_outline),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sección Notificaciones
          _SectionHeader(title: 'Notificaciones'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Recordatorios de ubicación'),
                  subtitle: const Text('Recibir alertas cuando estés cerca de una tienda'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Get.snackbar(
                      'Información',
                      'Los recordatorios se configuran individualmente para cada lista',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Notificaciones push'),
                  subtitle: const Text('Permitir notificaciones de la aplicación'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Get.snackbar(
                      'Información',
                      'Puedes gestionar las notificaciones desde la configuración del sistema',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sección Privacidad
          _SectionHeader(title: 'Privacidad y Datos'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Información de privacidad'),
                  subtitle: const Text('Cómo usamos tus datos'),
                  leading: const Icon(Icons.privacy_tip),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyInfo(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Eliminar todos los datos'),
                  subtitle: const Text('Borrar todas las listas de forma permanente'),
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDeleteAllDataDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sección Información
          _SectionHeader(title: 'Información'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Acerca de'),
                  subtitle: const Text('Información de la aplicación'),
                  leading: const Icon(Icons.info),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Versión'),
                  subtitle: const Text('1.0.0'),
                  leading: const Icon(Icons.app_settings_alt),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Tecnologías utilizadas'),
                  subtitle: const Text('Flutter, GetX, Firebase'),
                  leading: const Icon(Icons.code),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTechnologiesDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botón de ayuda
          Card(
            child: ListTile(
              title: const Text('¿Necesitas ayuda?'),
              subtitle: const Text('Guía de uso y preguntas frecuentes'),
              leading: const Icon(Icons.help),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showHelpDialog(context),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showDeleteAllDataDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('¡Advertencia!'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar TODAS tus listas de compras?\n\n'
          'Esta acción no se puede deshacer y perderás todos tus datos permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Funcionalidad no implementada',
                'Esta función se implementará en una versión futura',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );
  }

  void _showTechnologiesDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Tecnologías Utilizadas'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frontend:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Flutter 3.35.2'),
              Text('• GetX 4.6.6 (Estado, rutas, dependencias)'),
              SizedBox(height: 16),
              Text(
                'Backend:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Firebase Core'),
              Text('• Cloud Firestore'),
              SizedBox(height: 16),
              Text(
                'Servicios:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Geolocator (Ubicación)'),
              Text('• Flutter Local Notifications'),
              Text('• Permission Handler'),
              SizedBox(height: 16),
              Text(
                'Otras librerías:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Intl (Formateo de fechas)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Guía de Uso'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cómo usar Smart Shopping List:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '1. Crear listas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Toca el botón "+" en la pantalla principal'),
              Text('• Escribe un nombre y descripción'),
              SizedBox(height: 12),
              Text(
                '2. Agregar artículos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Entra a una lista y toca el botón "+"'),
              Text('• Completa la información del artículo'),
              Text('• Asigna categorías y precios'),
              SizedBox(height: 12),
              Text(
                '3. Recordatorios de ubicación:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Toca el ícono de ubicación en una lista'),
              Text('• Ve al lugar donde compras'),
              Text('• Recibirás notificaciones cuando estés cerca'),
              SizedBox(height: 12),
              Text(
                '4. Marcar como completado:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Toca la casilla junto a cada artículo'),
              Text('• Los completados aparecen en una sección separada'),
              SizedBox(height: 12),
              Text(
                '5. Personalización:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Cambia entre tema claro y oscuro'),
              Text('• Organiza por categorías'),
              Text('• Busca listas con la barra de búsqueda'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Acerca de'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Shopping List by Lou jeje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Versión 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Una aplicación inteligente para gestionar tus listas de compras con recordatorios basados en ubicación.',
            ),
            SizedBox(height: 16),
            Text(
              'Características:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Listas de compras sincronizadas'),
            Text('• Recordatorios por ubicación'),
            Text('• Tema claro/oscuro'),
            Text('• Categorización de productos'),
            Text('• Notificaciones inteligentes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacidad y Datos'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Uso de Datos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Tus listas se almacenan de forma segura en Firebase'),
              Text('• La ubicación se usa solo para recordatorios locales'),
              Text('• No compartimos tu información con terceros'),
              Text('• Puedes eliminar todos tus datos en cualquier momento'),
              SizedBox(height: 16),
              Text(
                'Permisos Requeridos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Ubicación: Para recordatorios basados en proximidad'),
              Text('• Notificaciones: Para alertas y recordatorios'),
              Text('• Internet: Para sincronizar tus listas'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}