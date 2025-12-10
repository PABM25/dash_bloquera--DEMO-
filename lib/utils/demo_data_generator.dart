// UBICACIÓN: lib/utils/demo_data_generator.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class DemoDataGenerator {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> generarDatos() async {
    print("Iniciando generación de datos falsos...");
    final random = Random();
    
    // 1. Asegurar Usuario Demo en Firestore (para roles)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'email': user.email,
        'nombre': 'Visitante Portafolio',
        'role': 'admin', // Damos admin para que pueda ver todo
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // 2. GENERAR PRODUCTOS
    // Borramos colección actual (opcional, para no duplicar infinitamente)
    // Nota: Borrar colecciones enteras desde cliente no es simple, así que solo agregamos.
    
    List<Map<String, dynamic>> productos = [
      {'nombre': 'Bloque 10x20x40', 'precio': 450, 'stock': 1500},
      {'nombre': 'Bloque 15x20x40', 'precio': 550, 'stock': 800},
      {'nombre': 'Adoquín Rectangular', 'precio': 200, 'stock': 5000},
      {'nombre': 'Solera Tipo A', 'precio': 3500, 'stock': 200},
      {'nombre': 'Cemento Especial', 'precio': 4200, 'stock': 50},
    ];

    for (var p in productos) {
      await _db.collection('productos').add({
        ...p,
        'descripcion': 'Producto Demo Generado',
        'categoria': 'Concreto',
      });
    }

    // 3. GENERAR VENTAS (Últimos 3 meses)
    for (int i = 0; i < 20; i++) {
      DateTime fecha = DateTime.now().subtract(Duration(days: random.nextInt(90)));
      double total = (random.nextInt(30) + 5) * 10000.0; // Entre 50k y 350k
      
      await _db.collection('ventas').add({
        'cliente_nombre': 'Cliente Empresa ${random.nextInt(100)}',
        'fecha': Timestamp.fromDate(fecha),
        'total': total,
        'estado': 'pagado',
        'metodo_pago': 'transferencia',
        'items': [
            {'producto': 'Bloque Demo', 'cantidad': 100, 'precio': 150} 
        ]
      });
    }

    // 4. GENERAR TRABAJADORES
    List<String> cargos = ['Maestro', 'Ayudante', 'Chofer', 'Vendedor'];
    for (int i = 0; i < 6; i++) {
      await _db.collection('trabajadores').add({
        'nombre': 'Empleado Demo ${i+1}',
        'rut': '${10+i}.xxx.xxx-k',
        'cargo': cargos[random.nextInt(cargos.length)],
        'tipo_proyecto': random.nextBool() ? 'BLOQUERA' : 'CONSTRUCTORA',
        'salario_por_dia': (random.nextInt(10) + 20) * 1000, 
        'telefono': '+56900000000',
        'email': 'trabajador$i@demo.com'
      });
    }
    
    // 5. GENERAR GASTOS
    for (int i = 0; i < 10; i++) {
      DateTime fecha = DateTime.now().subtract(Duration(days: random.nextInt(60)));
      await _db.collection('gastos').add({
        'titulo': 'Insumos Varios #${i+1}',
        'monto': (random.nextInt(15) + 1) * 15000.0,
        'fecha': Timestamp.fromDate(fecha),
        'categoria': 'Materia Prima',
        'descripcion': 'Gasto simulado',
      });
    }

    print("¡Datos falsos generados exitosamente!");
  }
}