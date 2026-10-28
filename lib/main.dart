import 'package:flutter/material.dart';

void main() {
  runApp(const FocusTrackApp());
}

/// Widget raiz inmutable que configura el tema visual de la aplicacion
class FocusTrackApp extends StatelessWidget {
  const FocusTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusTrack Móvil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Azul Índigo Universitario
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const PantallaPrincipalMetas(),
    );
  }
}

/// Niveles de prioridad de la sesion (Reto 1)
enum NivelPrioridad {
  baja('Baja', Color(0xFF607D8B), Icons.arrow_downward),
  media('Media', Color(0xFFFF8F00), Icons.drag_handle),
  alta('Alta', Color(0xFFB71C1C), Icons.priority_high);

  const NivelPrioridad(this.etiqueta, this.color, this.icono);

  final String etiqueta;
  final Color color;
  final IconData icono;
}

/// Pantalla con estado reactivo para registrar metas y productividad
class PantallaPrincipalMetas extends StatefulWidget {
  const PantallaPrincipalMetas({super.key});

  @override
  State<PantallaPrincipalMetas> createState() =>
      _PantallaPrincipalMetasState();
}

class _PantallaPrincipalMetasState extends State<PantallaPrincipalMetas> {
  /// Limite maximo de metas diarias permitido (Reto 2)
  static const int _limiteMaximoMetas = 10;

  int _metasCompletadas = 0;
  final int _metaObjetivo = 5;
  String _nivelProductividad = 'Inicial';
  NivelPrioridad _prioridad = NivelPrioridad.media;

  void _actualizarNivel() {
    if (_metasCompletadas == 0) {
      _nivelProductividad = 'Inicial';
    } else if (_metasCompletadas < _metaObjetivo) {
      _nivelProductividad = 'En Progreso';
    } else if (_metasCompletadas == _metaObjetivo) {
      _nivelProductividad = '¡Objetivo Alcanzado!';
    } else {
      _nivelProductividad =
          '¡Sobresaliente (+${_metasCompletadas - _metaObjetivo})!';
    }
  }

  void _incrementarMeta() {
    // Bloqueo seguro: no se permite superar el limite diario
    if (_metasCompletadas >= _limiteMaximoMetas) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Ha alcanzado el límite máximo diario de metas '
              '($_limiteMaximoMetas/$_limiteMaximoMetas). ¡Excelente jornada!',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      return;
    }

    setState(() {
      _metasCompletadas++;
      _actualizarNivel();
    });
  }

  void _decrementarMeta() {
    setState(() {
      if (_metasCompletadas > 0) {
        _metasCompletadas--;
        _actualizarNivel();
      }
    });
  }

  void _cambiarPrioridad(Set<NivelPrioridad> seleccion) {
    setState(() {
      _prioridad = seleccion.first;
    });
  }

  void _reiniciarContadores() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar Reinicio'),
          content: const Text(
            '¿Desea restablecer todas las metas completadas a cero?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _metasCompletadas = 0;
                  _actualizarNivel();
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Metas restablecidas exitosamente.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final porcentaje = (_metasCompletadas / _metaObjetivo).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusTrack Móvil'),
        backgroundColor: colores.primaryContainer,
        foregroundColor: colores.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reiniciar sesión de metas',
            onPressed: _reiniciarContadores,
          ),
        ],
      ),
      // SafeArea garantiza visualizacion correcta fuera del notch
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 96.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarjeta de Resumen Ejecutivo
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.track_changes,
                        size: 52.0,
                        color: colores.primary,
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Progreso del Día',
                        style: tema.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '$_metasCompletadas / $_metaObjetivo',
                        style: tema.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colores.primary,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: LinearProgressIndicator(
                          value: porcentaje,
                          minHeight: 10.0,
                          backgroundColor: colores.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _metasCompletadas >= _metaObjetivo
                                ? Colors.teal
                                : colores.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Chip(
                        avatar: Icon(
                          _metasCompletadas >= _metaObjetivo
                              ? Icons.emoji_events
                              : Icons.bolt,
                          color: colores.onSecondaryContainer,
                        ),
                        label: Text(
                          _nivelProductividad,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colores.onSecondaryContainer,
                          ),
                        ),
                        backgroundColor: colores.secondaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Selector de Estado de Prioridad (Reto 1)
              Text(
                'Prioridad de la sesión',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              SegmentedButton<NivelPrioridad>(
                segments: [
                  for (final nivel in NivelPrioridad.values)
                    ButtonSegment<NivelPrioridad>(
                      value: nivel,
                      label: Text(nivel.etiqueta),
                      icon: Icon(nivel.icono),
                    ),
                ],
                selected: {_prioridad},
                onSelectionChanged: _cambiarPrioridad,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor:
                      _prioridad.color.withValues(alpha: 0.18),
                  selectedForegroundColor: _prioridad.color,
                ),
              ),
              const SizedBox(height: 24.0),

              // Panel de Informacion Tecnica (refleja la prioridad elegida)
              Card(
                elevation: 1.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                    color: _prioridad.color,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  leading: Icon(Icons.info_outline, color: _prioridad.color),
                  title: const Text('Sesión Móvil Activa'),
                  subtitle: Text(
                    'Prioridad ${_prioridad.etiqueta} · '
                    'Renderizado nativo impulsado por el motor Impeller '
                    'y gestionado con Hot Reload.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Botones Flotantes de Accion
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn_decrementar',
            onPressed: _decrementarMeta,
            tooltip: 'Restar meta completada',
            backgroundColor: colores.surfaceContainerHighest,
            foregroundColor: colores.onSurfaceVariant,
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 14.0),
          FloatingActionButton.extended(
            heroTag: 'btn_incrementar',
            onPressed: _incrementarMeta,
            tooltip: 'Completar meta',
            backgroundColor: colores.primary,
            foregroundColor: colores.onPrimary,
            icon: const Icon(Icons.check),
            label: const Text('Completar Meta'),
          ),
        ],
      ),
    );
  }
}
