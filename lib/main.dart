import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Importações dos Temas e Telas de Auth
import 'core/theme/app_theme.dart';
import 'features/welcome/view/welcome_view.dart';

// Importações das Abas Principais
import 'features/dice/view/dice_view.dart';
import 'features/table_search/view/table_search_view.dart';
import 'features/swipe/view/swipe_view.dart';
import 'features/assistant/view/assistant_view.dart';
import 'features/profile/view/profile_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a conexão com o Firebase usando as credenciais geradas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// Configuração global do App (Tema e Tela de Entrada)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App RPG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Alterne para ThemeMode.dark ou ThemeMode.system quando desejar
      
      // Define a WelcomeView (Boas-vindas/Login) como a porta de entrada do aplicativo
      home: const WelcomeView(),
    );
  }
}

// Estrutura da barra de navegação com as 5 abas pós-login
class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int _currentIndex = 2; // Começa na aba central (Swipe)

  final List<Widget> _screens = const [
    DiceRollView(),
    TablesSearchView(),
    SwipeView(),
    AssistantView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino),
            label: 'Dados',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Mesas',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'Encontrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Assistente',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}