import 'package:flutter/material.dart';
import 'package:kwanga/custom_themes/blue_accent_theme.dart';
import 'package:kwanga/custom_themes/text_style.dart';
import 'package:kwanga/utils/current_user.dart';
import 'package:kwanga/screens/login_screens/login_screen.dart';
import '../main_screen.dart';

class ConfigurationsScreen extends StatefulWidget {
  const ConfigurationsScreen({super.key});

  @override
  State<ConfigurationsScreen> createState() => _ConfigurationsScreenState();
}

class _ConfigurationsScreenState extends State<ConfigurationsScreen> {

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(()=> isLoading = true);

    final id = await CurrentUser.getUserId();
    final email = await CurrentUser.getUserEmail();

    setState(() {
      userData = {
        'id' : id,
        'email' : email,
      };
      isLoading = false;

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cMainColor,
        foregroundColor: cWhiteColor,
        title: Row(
          spacing: 8.0,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              },
              child: const Icon(Icons.arrow_back),
            ),
            Text(
              'Configurações',
              style: tTitle.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // User Identification - Profile picture, name and e-mail
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.0,
              children: [
                Row(
                  spacing: 8.0,
                  children: [
                    CircleAvatar(
                      radius: 32.0,
                      backgroundColor: cSecondaryColor,
                      child: Text(userData != null ? userData!['email'].substring(0,2).toUpperCase() : 'KW', style: tTitle),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alberto Ubisse',
                          style: tSmallTitle.copyWith(color: cBlackColor),
                        ),
                        Text(userData?['email'] ?? 'Carregando...', style: tNormal),
                      ],
                    ),
                  ],
                ),
                const Divider(),

                // Theme handling
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          borderRadius: BorderRadius.circular(12.0)
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
                                      borderRadius: BorderRadius.circular(4.0)
                                  ),
                                ),
                                Text('Dark-Blue', style: tNormal),
                              ],
                            ),
                            Radio(value: context),
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
                                    borderRadius: BorderRadius.circular(4.0)
                                ),
                              ),
                              Text('Light-Blue', style: tNormal),
                            ],
                          ),
                          Radio(value: context),
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
                                    borderRadius: BorderRadius.circular(4.0)
                                ),
                              ),
                              Text('Red-Accent', style: tNormal),
                            ],
                          ),
                          Radio(value: context),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                ),

                // Version
                Column(
                  spacing: 8.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Versão',
                          style: tSmallTitle.copyWith(color: cBlackColor),
                        ),
                        Text('1.2   ', style: tNormal),
                      ],
                    ),
                    const Divider(),
                  ],
                ),

                // Links
                Column(
                  spacing: 24.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            child: Image.asset('assets/icons/linkedin.png', width: 24.0,),
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
                            child: Image.asset('assets/icons/facebook.png', width: 24.0,),
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
                            child: Image.asset('assets/icons/instagram.png', width: 24.0,),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ],
            ),
            // Log out Button
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const LoginScreen(),
                  ),
                );
              },
              child: GestureDetector(
                onTap: () async {

                  await CurrentUser.clear();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => const LoginScreen()));
                },
                child: Row(
                  spacing: 8.0,
                  children: [
                    Icon(Icons.person_off_outlined, color: cBlackColor),
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
          ],
        ),
      ),
    );
  }
}
