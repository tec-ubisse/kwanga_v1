import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/app_text_theme.dart';
import 'package:kwanga/screens/login_screens/phone_login.dart';
import 'package:kwanga/screens/navigation_screens/custom_drawer.dart';
import 'package:kwanga/providers/auth_provider.dart';

import 'edit_profile_screen.dart';

class ConfigurationsScreen extends ConsumerWidget {
  const ConfigurationsScreen({super.key});

  String _getUserInitials(String? nome, String? apelido) {
    if (nome == null || apelido == null) return '?';

    final firstInitial = nome.isNotEmpty ? nome[0].toUpperCase() : '';
    final lastInitial = apelido.isNotEmpty ? apelido[0].toUpperCase() : '';

    return '$firstInitial$lastInitial';
  }

  String _getUserFullName(String? nome, String? apelido, String phone) {
    if (nome != null && apelido != null) {
      return '$nome $apelido';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(
          'Configurações',
          style: AppTextTheme.headlineLarge(context)
              .copyWith(fontWeight: FontWeight.w500, color: colors.onPrimary),
        ),
      ),
      drawer: const CustomDrawer(),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar dados',
                  style: AppTextTheme.headlineSmall(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: AppTextTheme.bodySmall(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Nenhum utilizador logado.'));
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      // ==================== PERFIL ====================
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 40.0,
                            backgroundColor: colors.secondary,
                            child: Text(
                              _getUserInitials(user.nome, user.apelido),
                              style: AppTextTheme.displaySmall(context)
                                  .copyWith(color: colors.onSecondary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getUserFullName(
                              user.nome,
                              user.apelido,
                              user.phone,
                            ),
                            style: AppTextTheme.bodyLarge(context)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            user.phone,
                            style: AppTextTheme.bodySmall(context),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: 180,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text(
                                'Editar perfil',
                                style: AppTextTheme.labelLarge(context),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const EditProfileScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.primary,
                                side: BorderSide(color: colors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // ==================== TEMAS ====================
                      Column(
                        children: [
                          Text(
                            'Temas',
                            style: AppTextTheme.headlineSmall(context),
                          ),
                          const SizedBox(height: 16),

                          _buildThemeOption(
                            context: context,
                            color: colors.primary,
                            label: 'Light-Mode',
                            isSelected: true,
                            onTap: () {},
                          ),

                          const SizedBox(height: 8),

                          _buildThemeOption(
                            context: context,
                            color: colors.primary,
                            label: 'Dark-Mode',
                            isSelected: true,
                            onTap: () {},
                          ),

                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // ==================== LINKS ====================
                      Column(
                        children: [
                          Text(
                            'Links',
                            style: AppTextTheme.headlineSmall(context),
                          ),
                          const SizedBox(height: 16),

                          _buildLinkItem(
                            context: context,
                            label: 'LinkedIn',
                            icon: 'assets/icons/linkedin.png',
                            onTap: () {},
                          ),

                          const SizedBox(height: 12),

                          _buildLinkItem(
                            context: context,
                            label: 'Facebook',
                            icon: 'assets/icons/facebook.png',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),

                          _buildLinkItem(
                            context: context,
                            label: 'Instagram',
                            icon: 'assets/icons/instagram.png',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                    ],
                  ),
                ),

                // ==================== LOG OUT ====================
                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar'),
                                content: const Text(
                                  'Tem certeza que deseja sair?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Sair',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref
                                  .read(authProvider.notifier)
                                  .logout();

                              if (context.mounted) {
                                Navigator.of(context)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const PhoneLogin(isLogin: true),
                                  ),
                                      (route) => false,
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: Text(
                            'Log out',
                            style: AppTextTheme.labelLarge(context),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.onSurface),
                            foregroundColor: colors.onSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== WIDGETS AUXILIARES ====================

  Widget _buildThemeOption({
    required BuildContext context,
    required Color color,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextTheme.bodyMedium(context).copyWith(
                    fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            Icon(
              label=='Light-Mode'
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: isSelected ? color : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLinkItem({
    required BuildContext context,
    required String label,
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextTheme.bodyMedium(context),
            ),
            Image.asset(
              icon,
              width: 28,
              height: 28,
            ),
          ],
        ),
      ),
    );
  }

}
