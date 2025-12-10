// UBICACIÓN: lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/demo_data_generator.dart'; // <--- Importamos el generador

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  // Lógica normal de Login (la ocultaremos o dejaremos opcional)
  void _submit() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    final error = await Provider.of<AuthProvider>(context, listen: false)
        .login(email: _emailCtrl.text.trim(), password: _passCtrl.text.trim());
    setState(() => _isLoading = false);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  // --- LÓGICA ESPECIAL DEMO ---
  void _loginDemo() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 1. Intentar entrar
    String? error = await authProvider.login(
      email: "demo@portfolio.com", 
      password: "demo12345"
    );

    // 2. Si el usuario no existe, lo creamos automáticamente
    if (error == 'user-not-found' || (error != null && error.contains('found'))) {
       // Intentamos registrarlo
       error = await authProvider.register(
         email: "demo@portfolio.com",
         password: "demo12345",
         nombre: "Visitante Demo"
       );
       
       if (error == null) {
         // Si se registró bien, generamos datos base inmediatamente
         await DemoDataGenerator.generarDatos();
       }
    }

    setState(() => _isLoading = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Error Demo: $error"), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo e intro
              Image.asset('assets/images/Logo.png', height: 100),
              const SizedBox(height: 20),
              const Text(
                "Dash Bloquera",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const Text("VERSIÓN DEMO - PORTAFOLIO", style: TextStyle(color: Colors.grey, letterSpacing: 1.5)),
              const SizedBox(height: 40),

              // --- BOTÓN PRINCIPAL DEMO ---
              if (_isLoading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _loginDemo,
                    icon: const Icon(Icons.rocket_launch, size: 28),
                    label: const Text("ACCESO DEMO (RECLUTADORES)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                  ),
                ),
              
              const SizedBox(height: 10),
              const Text(
                "Un solo clic para probar la app completa con datos de muestra.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 40),
              const Divider(thickness: 1),
              const SizedBox(height: 20),
              
              // Acceso Tradicional (Opcional, lo dejamos pequeño)
              const Text("Acceso Manual", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder(), isDense: true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder(), isDense: true),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], foregroundColor: Colors.white),
                  child: const Text("INGRESAR"),
                ),
              ),

              const SizedBox(height: 30),
              // Botón Oculto para Resetear Datos (Util si quieres limpiar la demo)
              TextButton.icon(
                onPressed: _isLoading ? null : () async {
                   setState(() => _isLoading = true);
                   await DemoDataGenerator.generarDatos();
                   setState(() => _isLoading = false);
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Datos Demo Regenerados!")),
                   );
                },
                icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
                label: const Text("Resetear Datos (Admin)", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}