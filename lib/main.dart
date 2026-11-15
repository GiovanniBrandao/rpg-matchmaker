// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Importações dos Temas e Telas de Autenticação
import 'core/theme/app_theme.dart';
import 'features/welcome/view/welcome_view.dart';

// Importações das Abas Principais
import 'features/table_search/view/table_search_view.dart';
import 'features/swipe/view/swipe_view.dart';
import 'features/assistant/view/assistant_view.dart';
import 'features/marketplace/view/marketplace_view.dart';
import 'features/profile/view/profile_view.dart';
import 'features/dice/view/dice_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a conexão com o Firebase usando as credenciais geradas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPG Matchmaker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Define o AuthWrapper para gerenciar o login persistente
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto verifica se existe uma sessão ativa
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário já estiver autenticado no dispositivo
        if (snapshot.hasData && snapshot.data != null) {
          return const NavigationView();
        }

        // Se não estiver logado, redireciona para a WelcomeView / AuthView
        return const WelcomeView();
      },
    );
  }
} // Chave de fechamento do AuthWrapper ajustada

// Estrutura da barra de navegação com as 5 abas pós-login
class NavigationView extends StatefulWidget {
  final bool isGameMaster;

  const NavigationView({
    super.key,
    this.isGameMaster = false,
  });

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int _currentIndex = 2; // Começa na aba central de Match (no meio da navbar)
  final Set<int> _visitedTabs = {2};

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Instancia as telas passando os dados de contexto necessários
    _screens = [
      TableSearchView(isGameMaster: widget.isGameMaster),
      const AssistantView(),
      const SwipeView(),
      const MarketplaceView(),
      const ProfileView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (var i = 0; i < _screens.length; i++)
            _visitedTabs.contains(i) ? _screens[i] : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          if (_currentIndex == index) return;
          HapticFeedback.selectionClick();
          setState(() {
            _currentIndex = index;
            _visitedTabs.add(index);
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Mestre',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'Match',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Loja',
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
