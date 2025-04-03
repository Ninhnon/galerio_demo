import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'config.dart';
import 'screens/login_screen.dart';
import 'screens/webview_screen.dart';
import 'services/auth_service.dart';
import 'env.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables
    await Env.init();
    Env.validateConfig();

    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (AppConfig.enableFirebaseLogging) {
        print('Firebase initialized successfully');
      }
    }
  } catch (e) {
    print('Initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Galerio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late AuthService _authService;
  bool _initialized = false;
  Map<String, String>? _tokens;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authService = AuthService(prefs);
      final storedTokens = _authService.getStoredTokens();
      print(
        'Auth initialized with tokens: ${storedTokens['token'] != null ? 'exists' : 'null'}',
      );

      if (mounted) {
        setState(() {
          _tokens = storedTokens['token'] != null
              ? {
                  'token': storedTokens['token']!,
                  'accessToken':
                      storedTokens['accessToken'] ?? storedTokens['token']!,
                }
              : null;
          _initialized = true;
          _error = null;
        });
      }
    } catch (e) {
      print('Error in auth initialization: $e');
      if (mounted) {
        setState(() {
          _initialized = true;
          _error = e.toString();
        });
      }
    }
  }

  void _handleLoginSuccess(String? token, [String? accessToken]) {
    print(token != null ? 'Login success with tokens' : 'Logout requested');
    if (mounted) {
      setState(() {
        if (token != null) {
          _tokens = {
            'token': token,
            'accessToken': accessToken ?? token, // Fallback for email login
          };
        } else {
          _tokens = null;
        }
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Error Initializing App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeAuth,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_tokens == null) {
      return LoginScreen(onLoginSuccess: _handleLoginSuccess);
    }

    // Make sure both tokens exist before proceeding
    final idToken = _tokens!['token'];
    final accessToken = _tokens!['accessToken'];

    if (idToken == null || accessToken == null) {
      // If either token is missing, clear tokens and return to login
      setState(() => _tokens = null);
      return LoginScreen(onLoginSuccess: _handleLoginSuccess);
    }

    return WebViewScreen(
      url: AppConfig.webAppUrl,
      token: idToken,
      accessToken: accessToken,
      onLogin: _handleLoginSuccess,
    );
  }
}
