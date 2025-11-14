import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/screens/login_screens/login_screen.dart';
import 'package:kwanga/utils/secure_storage.dart';
import 'package:kwanga/widgets/custom_drawer.dart';
import 'package:kwanga/providers/auth_provider.dart';

class ConfigurationsScreen extends ConsumerWidget {
  const ConfigurationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Text(
          'Configurações',
          style: tTitle.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      drawer: const CustomDrawer(),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Nenhum utilizador logado.'));
          }

          return Padding(
            padding: defaultPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User Identification - Profile picture, name and e-mail
                Expanded(
                  child: ListView(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8.0,
                        children: [
                          CircleAvatar(
                            radius: 32.0,
                            backgroundColor: cSecondaryColor,
                            child: Text(
                              user.email!.substring(0, 2).toUpperCase(),
                              style: tTitle,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.email!,
                                style: tNormal,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      // Theme handling
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Temas',
                              style: tSmallTitle.copyWith(color: cBlackColor),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: cMainColor.withAlpha(24),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 8.0,
                                    children: [
                                      Container(
                                        width: 16.0,
                                        height: 16.0,
                                        decoration: BoxDecoration(
                                          color: cMainColor,
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      Text('Dark-Blue', style: tNormal),
                                    ],
                                  ),
                                  Radio(value: context, groupValue: null, onChanged: (_) {}),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  spacing: 8.0,
                                  children: [
                                    Container(
                                      width: 16.0,
                                      height: 16.0,
                                      decoration: BoxDecoration(
                                        color: cSecondaryColor,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    Text('Light-Blue', style: tNormal),
                                  ],
                                ),
                                Radio(value: context, groupValue: null, onChanged: (_) {}),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  spacing: 8.0,
                                  children: [
                                    Container(
                                      width: 16.0,
                                      height: 16.0,
                                      decoration: BoxDecoration(
                                        color: cTertiaryColor,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    Text('Red-Accent', style: tNormal),
                                  ],
                                ),
                                Radio(value: context, groupValue: null, onChanged: (_) {}),
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                      ),

                      // Links
                      Column(
                        spacing: 24.0,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Links',
                            style: tSmallTitle.copyWith(color: cBlackColor),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('LinkedIn', style: tNormal),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Image.asset(
                                    'assets/icons/linkedin.png',
                                    width: 24.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Facebook', style: tNormal),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Image.asset(
                                    'assets/icons/facebook.png',
                                    width: 24.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Instagram', style: tNormal),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Image.asset(
                                    'assets/icons/instagram.png',
                                    width: 24.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ],
                  ),
                ),

                // Log out Button
                SizedBox(
                  height: 48,
                  child: GestureDetector(
                    onTap: () async {
                      await SecureStorage.clearAll();
                      ref.invalidate(authProvider);

                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: cBlackColor)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          spacing: 8.0,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_off_outlined, color: cBlackColor),
                            Text(
                              'Log out',
                              style: tNormal.copyWith(
                                color: cBlackColor,
                                fontWeight: FontWeight.w600,
                              ),
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
