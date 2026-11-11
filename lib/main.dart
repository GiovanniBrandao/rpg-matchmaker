import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Importações dos Temas e Telas de Auth
import 'core/theme/app_theme.dart';
import 'features/welcome/view/welcome_view.dart';

// Importações das Abas Principais
import 'features/table_search/view/table_search_view.dart';
import 'features/swipe/view/swipe_view.dart';
import 'features/assistant/view/assistant_view.dart';
import 'features/marketplace/view/marketplace_view.dart';
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
      themeMode: ThemeMode.system,
      home: const WelcomeView(),
    );
  }
}

/// Barra de navegação limpa com 5 abas principais (Padrão Material 3 / Lei de Hick).
/// "Match" fica centralizado no meio da barra (índice 2) e a aba "Mestre" reúne
/// o guia narrativo, dicas de mesa e a Mesa de Dados.
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
