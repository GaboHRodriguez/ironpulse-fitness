# IronPulse Fitness - Asistente de Entrenamiento de Musculación (Android & Windows)

Aplicación nativa multiplataforma desarrollada en **Flutter (Dart) + SQLite local** que funciona en **Android (APK sin navegador)** y **Windows Desktop (.exe)** con persistencia relacional escalable.

---

## Características Principales Implementadas

1. **Bienvenida e Interacción Personalizada Sin Registro**:
   - Solicita únicamente tu nombre o apodo y unidad preferida (`kg` o `lb`) sin cuentas ni contraseñas.
   - Saluda y responde de forma interactiva en cada pantalla (*Dashboard*, *Rutinas*, *Sesión de Entrenamiento* y *Récords*).

2. **Gestor Completo de Rutinas Semanales (Crear, Modificar, Eliminar) + Plantillas Prearmadas**:
   - Configura de **1 a 7 días por semana**.
   - Asigna ejercicios a cada día indicando **cantidad de series** y **rango de repeticiones**.
   - Incluye **4 Plantillas Profesionales Prearmadas** listas para importar en 1 clic:
     - *Push / Pull / Legs (Empuje - Tirón - Pierna - 3 Días)*
     - *Torso / Pierna (Upper / Lower - 4 Días)*
     - *Full Body (Cuerpo Completo - 3 Días)*
     - *División Clásica Culturista Weider (5 Días)*

3. **Enciclopedia de Musculación + Sistema Dual de Animación Técnica**:
   - Base de datos SQLite precargada con una amplia variedad de ejercicios clasificados por **Grupo Muscular** y por **Modalidad / Equipamiento**:
     - `Barra`, `Mancuernas`, `Polea / Cable`, `Máquina`, `Multipower / Smith`, `Barra EZ`, `Peso Corporal`, `Kettlebell / Disco`.
   - **Animación Técnica Dual**:
     1. **Motor Biomecánico Vectorial 100% Offline (`CustomPainter`)**: Muestra el movimiento articular en tiempo real, el equipamiento, los músculos activos iluminados, fase concéntrica/excéntrica y cámara lenta `0.5x`.
     2. **Soporte de GIFs y Videos Externos**: Permite alternar a GIF demostrativo o abrir búsqueda de video técnico.
   - Permite además **crear nuevos ejercicios personalizados** en la base de datos.

4. **Registro Diario de Pesos Serie por Serie con Memoria Inteligente**:
   - Al iniciar el entrenamiento de un día, el sistema consulta la base de datos y muestra en cada ejercicio y en cada serie:
     - **Cuánto peso levantaste la última vez** en esa serie exacta (`Última vez comenzaste la Serie 1 con X kg`).
     - **Autocompletado inteligente** del peso anterior para que sepas de inmediato con cuánto peso comenzar hoy.

5. **Gráficos de Progreso y Récords Personales (1RM)**:
   - Curva de evolución de **Peso Máximo** y **1RM Estimado (Fórmula de Epley)** por ejercicio y bitácora histórica completa.

---

## Estructura del Proyecto

- `lib/main.dart`: Punto de entrada, tema visual *Dark Gym Neon* y arranque automático.
- `lib/models/fitness_models.dart`: Modelos de datos (`UserProfile`, `Exercise`, `Routine`, `RoutineDay`, `RoutineExerciseItem`, `WorkoutSession`, `WorkoutSetLog`).
- `lib/services/database_service.dart`: Motor SQLite relacional multiplataforma (`sqflite` en Android + `sqflite_common_ffi` en Windows).
- `lib/data/exercise_catalog_seed.dart`: Catálogo detallado de ejercicios de musculación por modalidad y plantillas de rutinas.
- `lib/widgets/exercise_technique_animation.dart`: Motor de animación biomecánica vectorial offline + visor GIF/video.
- `lib/screens/`:
  - `welcome_username_screen.dart`: Ingreso de nombre interactivo sin registro.
  - `home_shell_screen.dart`: Panel principal y navegación.
  - `routines_screen.dart`: Creación, edición, eliminación e importación de rutinas semanales.
  - `workout_session_screen.dart`: Modo de entrenamiento diario con registro de pesos por serie y memoria de la sesión anterior.
  - `exercises_catalog_screen.dart`: Enciclopedia filtrable por músculo y equipamiento (barras, mancuernas, poleas, máquinas).
  - `progress_history_screen.dart`: Gráficos de progreso, 1RM y bitácora.

---

## Cómo Ejecutar y Compilar en Windows y Android

Puedes usar el asistente automático incluido haciendo doble clic o ejecutando en consola [`setup_and_build.bat`](file:///c:/Users/gaboh/Proyectos%20Antigravity/ironpulse_fitness/setup_and_build.bat), o correr los comandos de Flutter manualmente:

```powershell
# 1. Inicializar carpetas de plataforma (solo la primera vez tras instalar Flutter)
flutter create --platforms=android,windows --project-name ironpulse_fitness .

# 2. Instalar dependencias SQLite
flutter pub get

# 3. Ejecutar como aplicación nativa en Windows Desktop
flutter run -d windows

# 4. Compilar APK instalable para Android (sin navegador)
flutter build apk --release
```
