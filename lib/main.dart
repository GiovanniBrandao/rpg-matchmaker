// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Importações dos Temas e Telas de Autenticação
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
  int _currentIndex = 2; // Começa na aba central (Swipe/Encontrar)

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Instancia as telas passando os dados de contexto necessários
    _screens = [
      const DiceRollView(),
      TableSearchView(isGameMaster: widget.isGameMaster),
      const SwipeView(),
      const AssistantView(),
      const ProfileView(),
    ];
  }

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