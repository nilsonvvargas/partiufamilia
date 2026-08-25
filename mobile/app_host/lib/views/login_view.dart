import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

class LoginView extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginView({super.key, required this.onLoginSuccess});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final BffClient _bff = ServiceLocator.instance.get<BffClient>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Preencha o e-mail e a senha');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _bff.post('/api/v1/auth/login', {
        'email': email,
        'password': password,
      });

      if (response is Map<String, dynamic> &&
          response['success'] == true &&
          response['data'] != null) {
        final userData = response['data']['user'];
        TripContext.instance.currentUser = UserModel.fromJson(userData);
        widget.onLoginSuccess();
      } else {
        final msg = response is Map ? response['message'] : null;
        setState(() => _errorMessage = msg?.toString() ?? 'Credenciais inválidas');
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _errorMessage = msg.isNotEmpty ? msg : 'Falha ao conectar. Verifique suas credenciais.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Preencha o e-mail e a senha');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'A senha deve ter no mínimo 6 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _bff.post('/api/v1/auth/signup', {
        'email': email,
        'password': password,
        'name': name.isNotEmpty ? name : null,
      });

      if (response['success'] == true) {
        setState(() {
          _isSignUp = false;
          _errorMessage = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta criada! Faça login para continuar.'),
              backgroundColor: MaceioColors.success,
            ),
          );
        }
      } else {
        setState(() => _errorMessage = response['message'] ?? 'Erro ao criar conta');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Falha ao criar conta. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaceioColors.oceanDeep,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & Branding
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('✈️', style: TextStyle(fontSize: 52)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Família Partiu!',
                  style: MaceioTypography.display.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Planeje, organize e viva cada viagem em família',
                  textAlign: TextAlign.center,
                  style: MaceioTypography.bodyMedium.copyWith(color: Colors.white70),
                ),

                const SizedBox(height: 32),

                // Login / SignUp Card
                MaceioCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSignUp ? 'Criar sua conta' : 'Entrar na sua conta',
                        style: MaceioTypography.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSignUp
                            ? 'Cadastre-se para começar a planejar suas viagens'
                            : 'Use seu e-mail e senha para acessar',
                        style: MaceioTypography.bodyMedium,
                      ),
                      const SizedBox(height: 20),

                      // Name field (sign up only)
                      if (_isSignUp) ...[
                        TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Seu nome',
                            hintText: 'Ex: Nilson',
                            prefixIcon: const Icon(Icons.person_outline, color: MaceioColors.turquoisePrimary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: MaceioColors.turquoisePrimary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          hintText: 'seu@email.com',
                          prefixIcon: const Icon(Icons.email_outlined, color: MaceioColors.turquoisePrimary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: MaceioColors.turquoisePrimary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _isSignUp ? _handleSignUp() : _handleLogin(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          hintText: _isSignUp ? 'Mínimo 6 caracteres' : '••••••',
                          prefixIcon: const Icon(Icons.lock_outline, color: MaceioColors.turquoisePrimary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: MaceioColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: MaceioColors.turquoisePrimary, width: 2),
                          ),
                        ),
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: MaceioColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, size: 18, color: MaceioColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: MaceioTypography.bodyMedium.copyWith(color: MaceioColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: MaceioButton(
                          label: _isSignUp ? 'Criar Conta' : 'Entrar',
                          icon: _isSignUp ? Icons.person_add : Icons.flight_takeoff,
                          isLoading: _isLoading,
                          onPressed: _isSignUp ? _handleSignUp : _handleLogin,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Toggle Login / SignUp
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _errorMessage = null;
                            });
                          },
                          child: Text.rich(
                            TextSpan(
                              text: _isSignUp ? 'Já tem conta? ' : 'Não tem conta? ',
                              style: MaceioTypography.bodyMedium,
                              children: [
                                TextSpan(
                                  text: _isSignUp ? 'Faça login' : 'Cadastre-se',
                                  style: MaceioTypography.titleMedium.copyWith(
                                    color: MaceioColors.turquoisePrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Autenticação segura via Supabase',
                  style: MaceioTypography.caption.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
