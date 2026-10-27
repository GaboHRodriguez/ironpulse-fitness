import '../models/fitness_models.dart';

class ExerciseCatalogSeed {
  static const List<String> muscleGroups = [
    'Todos',
    'Pecho',
    'Espalda',
    'Hombros',
    'Cuádriceps',
    'Isquios y Glúteos',
    'Bíceps',
    'Tríceps',
    'Abdomen y Core',
    'Pantorrillas y Antebrazos',
  ];

  static const List<String> equipmentTypes = [
    'Todos',
    'Barra',
    'Mancuernas',
    'Polea / Cable',
    'Máquina',
    'Multipower / Smith',
    'Barra EZ',
    'Peso Corporal',
    'Kettlebell / Disco',
  ];

  static final List<Exercise> initialExercises = [
    // =========================================================================
    // 1. PECHO (CHEST)
    // =========================================================================
    Exercise(
      name: 'Press de Banca Plano con Barra',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Tríceps, Deltoides Anterior',
      equipment: 'Barra',
      movementPattern: 'bench_press',
      difficulty: 'Intermedio',
      instructions:
          '1. Acuéstate en el banco plano con los ojos bajo la barra y los pies firmes en el suelo.\n'
          '2. Retrae las escápulas (junta los omóplatos hacia atrás y abajo) y mantén un ligero arco lumbar natural.\n'
          '3. Toma la barra con un agarre algo mayor al ancho de los hombros.\n'
          '4. Inhala y baja la barra de forma controlada hacia la línea media-baja del pecho (esternón) con los codos a 45°-60°.\n'
          '5. Exhala y empuja la barra con fuerza hacia arriba hasta extender los brazos sin bloquear bruscamente los codos.',
      commonMistakes:
          'Abrir los codos a 90° (riesgo para el manguito rotador), rebotar la barra en el pecho o despegar los glúteos del banco.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Bench-Press.gif',
    ),
    Exercise(
      name: 'Press de Banca Plano con Mancuernas',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Tríceps, Deltoides Anterior, Estabilizadores',
      equipment: 'Mancuernas',
      movementPattern: 'bench_press',
      difficulty: 'Principiante',
      instructions:
          '1. Siéntate en el borde del banco con las mancuernas apoyadas en los muslos y túmbate impulsándolas con las rodillas.\n'
          '2. Mantén las escápulas retraídas y las muñecas firmes alineadas sobre los codos.\n'
          '3. Baja las mancuernas a los lados del pecho logrando un estiramiento profundo y controlado.\n'
          '4. Empuja hacia arriba convergiendo ligeramente sin chocar las mancuernas arriba.',
      commonMistakes:
          'Chocar las mancuernas con fuerza en la cima perdiendo tensión en el pectoral o bajar con las muñecas dobladas.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Press.gif',
    ),
    Exercise(
      name: 'Press Inclinado con Barra',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Haz Clavicular (Pecho Superior), Deltoides Anterior, Tríceps',
      equipment: 'Barra',
      movementPattern: 'incline_press',
      difficulty: 'Intermedio',
      instructions:
          '1. Ajusta el banco a una inclinación entre 30° y 45°.\n'
          '2. Saca la barra del soporte y bájala de manera controlada hacia la parte superior del pecho (cerca de las clavículas).\n'
          '3. Mantén los antebrazos perpendiculares al suelo durante todo el recorrido.\n'
          '4. Empuja verticalmente exhalando al superar el punto de mayor dificultad.',
      commonMistakes:
          'Inclinación excesiva del banco (>60°) que transfiere todo el trabajo al hombro, o bajar la barra hacia el abdomen.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Incline-Barbell-Bench-Press.gif',
    ),
    Exercise(
      name: 'Press Inclinado con Mancuernas',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Pecho Superior, Deltoides Anterior, Tríceps',
      equipment: 'Mancuernas',
      movementPattern: 'incline_press',
      difficulty: 'Principiante',
      instructions:
          '1. Ajusta el respaldo del banco a 30° (ideal para aislar el haz clavicular del pectoral).\n'
          '2. Desciende las mancuernas con los codos a unos 45° del torso hasta que queden a la altura de las clavículas.\n'
          '3. Empuja con control sintiendo la contracción en la parte alta del pecho.',
      commonMistakes:
          'Despegar la espalda alta del respaldo al empujar o acortar el rango de descenso.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Incline-Dumbbell-Press.gif',
    ),
    Exercise(
      name: 'Press Declinado con Barra',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Pectoral Inferior, Tríceps',
      equipment: 'Barra',
      movementPattern: 'bench_press',
      difficulty: 'Intermedio',
      instructions:
          '1. Asegura los pies en los rodillos del banco declinado (-15° a -30°).\n'
          '2. Baja la barra hacia la parte inferior del esternón manteniendo los omóplatos juntos.\n'
          '3. Empuja de forma explosiva y controlada hacia la posición inicial.',
      commonMistakes:
          'Bajar la barra hacia el cuello (muy peligroso); siempre debe dirigirse a la línea baja del pecho.',
    ),
    Exercise(
      name: 'Press de Pecho en Máquina Convergente (Chest Press)',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Tríceps, Deltoides Anterior',
      equipment: 'Máquina',
      movementPattern: 'bench_press',
      difficulty: 'Principiante',
      instructions:
          '1. Ajusta el asiento para que los agarres queden a la altura media del pecho.\n'
          '2. Pega bien la espalda al respaldo y retrae las escápulas.\n'
          '3. Empuja las palancas hacia adelante exhalando y regresa lento sin que las placas choquen.',
      commonMistakes:
          'Adelantar los hombros al final del empuje quitando tensión al pectoral.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Chest-Press-Machine.gif',
    ),
    Exercise(
      name: 'Press Inclinado en Multipower (Máquina Smith)',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Pectoral Superior, Tríceps',
      equipment: 'Multipower / Smith',
      movementPattern: 'incline_press',
      difficulty: 'Principiante',
      instructions:
          '1. Coloca un banco inclinado (30°-45°) centrado bajo la barra guiada de la Multipower.\n'
          '2. Verifica que al bajar la barra llegue a la zona alta del pecho (dos dedos bajo la clavícula).\n'
          '3. Desbloquea los seguros girando las muñecas, baja lento en 2-3 segundos y empuja con firmeza.',
      commonMistakes:
          'Ubicar el banco demasiado adelante o atrás forzando la trayectoria del hombro.',
    ),
    Exercise(
      name: 'Aperturas con Mancuernas en Banco Plano',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Deltoides Anterior, Bíceps (estabilizador)',
      equipment: 'Mancuernas',
      movementPattern: 'fly',
      difficulty: 'Principiante',
      instructions:
          '1. Acuéstate en el banco con las mancuernas sobre el pecho y palmas enfrentadas.\n'
          '2. Mantén una ligera flexión fija en los codos (como si abrazaras un árbol ancho).\n'
          '3. Abre los brazos en un arco amplio hasta sentir el estiramiento pectoral a la altura del torso.\n'
          '4. Cierra el arco usando el pecho para volver arriba.',
      commonMistakes:
          'Convertir el ejercicio en un press doblando demasiado los codos o bajar más allá de la capacidad articular del hombro.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Fly.gif',
    ),
    Exercise(
      name: 'Cruce de Poleas Altas (Cable Crossover)',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Pectoral Inferior e Interno, Deltoides Anterior',
      equipment: 'Polea / Cable',
      movementPattern: 'fly',
      difficulty: 'Intermedio',
      instructions:
          '1. Coloca las poleas en la posición alta, toma los estribos y da un paso al frente para crear tensión.\n'
          '2. Inclina ligeramente el torso hacia adelante manteniendo el abdomen firme.\n'
          '3. Lleva las manos en arco hacia abajo y al centro hasta que se junten frente a la cadera, apretando 1 segundo.',
      commonMistakes:
          'Balancear el cuerpo para mover más peso o empujar con los tríceps en lugar de aducir los brazos.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Cable-Crossover.gif',
    ),
    Exercise(
      name: 'Cruce de Poleas Bajas (Ascendente para Pecho Superior)',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Haz Clavicular, Deltoides Anterior',
      equipment: 'Polea / Cable',
      movementPattern: 'fly',
      difficulty: 'Intermedio',
      instructions:
          '1. Fija las poleas en el punto más bajo y toma los agarres con las palmas mirando hacia adelante/arriba.\n'
          '2. Con los codos levemente flexionados, eleva los brazos en diagonal hacia el centro a la altura del mentón.\n'
          '3. Contrae el pecho superior y desciende con control.',
      commonMistakes:
          'Flexionar los codos como si fuera un curl de bíceps en lugar de mantener el brazo semirrígido.',
    ),
    Exercise(
      name: 'Aperturas en Máquina Contractora (Pec Deck / Mariposa)',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Deltoides Anterior',
      equipment: 'Máquina',
      movementPattern: 'fly',
      difficulty: 'Principiante',
      instructions:
          '1. Ajusta el asiento para que los brazos queden paralelos al suelo al tomar los manerales.\n'
          '2. Cierra los brazos hacia el centro concentrándote en juntar los codos, sostén 1 segundo la contracción máxima.\n'
          '3. Regresa despacio hasta sentir el estiramiento del pectoral.',
      commonMistakes:
          'Encoger los trapecios o despegar la espalda del respaldo.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Pec-Deck-Fly.gif',
    ),
    Exercise(
      name: 'Fondos en Paralelas para Pecho (Dips)',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Tríceps, Deltoides Anterior',
      equipment: 'Peso Corporal',
      movementPattern: 'bench_press',
      difficulty: 'Intermedio',
      instructions:
          '1. Sujétate en las barras paralelas e inclina el torso unos 30° hacia adelante.\n'
          '2. Baja doblando los codos ligeramente hacia afuera hasta que los hombros queden al nivel de los codos.\n'
          '3. Empuja con fuerza manteniendo la inclinación para enfatizar el pectoral inferior.',
      commonMistakes:
          'Mantener el torso totalmente vertical (enfatiza solo tríceps) o bajar con rebote brusco.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Chest-Dips.gif',
    ),
    Exercise(
      name: 'Flexiones de Brazos (Push-Ups)',
      muscleGroup: 'Pecho',
      secondaryMuscles: 'Tríceps, Deltoides Anterior, Core',
      equipment: 'Peso Corporal',
      movementPattern: 'bench_press',
      difficulty: 'Principiante',
      instructions:
          '1. Coloca las manos ligeramente más anchas que los hombros y el cuerpo en línea recta desde la cabeza a los talones.\n'
          '2. Baja el pecho hasta casi rozar el suelo con los codos a 45°.\n'
          '3. Empuja el suelo hasta extender los brazos manteniendo el abdomen y glúteos contraídos.',
      commonMistakes:
          'Dejar caer la cadera arqueando la zona lumbar o levantar demasiado los glúteos.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Push-Up.gif',
    ),

    // =========================================================================
    // 2. ESPALDA (BACK)
    // =========================================================================
    Exercise(
      name: 'Dominadas Pronas (Pull-Ups)',
      muscleGroup: 'Espalda',
      secondaryMuscles: 'Bíceps, Braquial, Romboides, Core',
      equipment: 'Peso Corporal',
      movementPattern: 'lat_pulldown',
      difficulty: 'Avanzado',
      instructions:
          '1. Cuelga de la barra fija con agarre prono (palmas hacia adelante) algo más ancho que los hombros.\n'
          '2. Inicia el movimiento deprimiendo las escápulas (hombros lejos de las orejas).\n'
          '3. Tira llevando los codos hacia abajo y al costado del torso hasta pasar la barbilla sobre la barra.\n'
          '4. Baja de forma controlada hasta extender los brazos por completo.',
      commonMistakes:
          'Balancear las piernas (kipping involuntario), acortar el recorrido a la mitad o encoger los hombros.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Pull-up.gif',
    ),
    Exercise(
      name: 'Jalón al Pecho en Polea Alta (Agarre Ancho)',
      muscleGroup: 'Espalda',
      secondaryMuscles: 'Bíceps, Redondo Mayor, Romboides',
      equipment: 'Polea / Cable',
      movementPattern: 'lat_pulldown',
      difficulty: 'Principiante',
      instructions:
          '1. Siéntate y ajusta las almohadillas sobre los muslos para no levantarte con el peso.\n'
          '2. Sujeta la barra larga en pronación más ancho que los hombros.\n'
          '3. Inclina el torso apenas 10°-15° atrás, saca pecho y lleva la barra hacia la parte superior del pecho tirando con los codos hacia el suelo.\n'
          '4. Controla la subida sintiendo cómo se estiran los dorsales.',
      commonMistakes:
          'Tirar de la barra tras la nuca (lesivo para cervicales y hombros) o columpiarse hacia atrás con la espalda baja.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Lat-Pulldown.gif',
    ),
    Exercise(
      name: 'Jalón al Pecho con Agarre Neutro / Triángulo (Close-Grip)',
      muscleGroup: 'Espalda',
      secondaryMuscles: 'Dorsal Ancho Inferior, Bíceps, Braquiorradial',
      equipment: 'Polea / Cable',
      movementPattern: 'lat_pulldown',
      difficulty: 'Principiante',
      instructions:
          '1. Coloca el maneral en V (triángulo) en la polea alta.\n'
          '2. Saca el pecho y tira del agarre hacia el esternón manteniendo los codos pegados al cuerpo.\n'
          '3. Aprieta los dorsales en la parte baja 1 segundo y retorna estirando por completo.',
      commonMistakes:
          'Encorvar los hombros hacia adelante al final del recorrido.',
    ),
    Exercise(
      name: 'Remo con Barra Inclinado (Agarre Prono o Supino)',
      muscleGroup: 'Espalda',
      secondaryMuscles: 'Romboides, Trapecio Medio, Deltoides Posterior, Erectores Espinales',
      equipment: 'Barra',
      movementPattern: 'row',
      difficulty: 'Intermedio',
      instructions:
          '1. De pie con rodillas semiflexionadas, inclina el torso hacia adelante (45° a 70°) manteniendo la espalda totalmente neutra.\n'
          '2. Sujeta la barra y tira de ella hacia la línea del ombligo/abdomen superior llevando los codos hacia atrás.\n'
          '3. Junta las escápulas arriba y baja la barra sin perder la postura lumbar.',
      commonMistakes:
          'Redondear la espalda baja o levantarse excesivamente convirtiéndolo en un encogimiento con impulso.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Bent-Over-Row.gif',
    ),
    Exercise(
      name: 'Remo Pendlay con Barra',
      muscleGroup: 'Espalda',
      secondaryMuscles: 'Dorsales, Trapecios, Lumbares, Glúteos',
      equipment: 'Barra',
      movementPattern: 'row',
      difficulty: 'Avanzado',
      instructions:
          '1. Coloca el torso paralelo al suelo (90°) con la barra reposando en el suelo en cada repetición.\n'
          '2. Tira de forma explosiva de la barra hacia la parte baja del pecho/abdomen alto sin levantar el torso.\n'
          '3. Apoya la barra por completo en el suelo antes de la siguiente repetición.',
      commonMistakes:
          'Elevar los hombros y la cadera para ayudar a despegar la barra.',
    ),
    Exercise(
      name: 'Remo Unilateral con Mancuerna (Serrucho)',
      muscleGroup: 'Espalda',
      secondaryMuscles: 'Dorsal Ancho, Redondo Mayor, Bíceps, Deltoides Posterior',
      equipment: 'Mancuernas',
      movementPattern: 'row',
      difficulty: 'Principiante',
      instructions:
          '1. Apoya una mano y rodilla en el banco o mantente en trípode con la espalda plana.\n'
          '2. Toma la mancuerna con el brazo libre y llévala en arco hacia el bolsillo de la cadera (no hacia el hombro).\n'
          '3. Desciende estirando el dorsal sin rotar excesivamente el tronco.',
      commonMistakes:
          'Tirar recto hacia el hombro trabajando solo el bíceps o girar violentamente el torso.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Row.gif',
    ),
    Exercise(
      name: 'Remo en Polea Baja Sentado (Gironda)',
      muscleGroup: 'Espalda',
      secondaryMuscles: 'Romboides, Trapecio Medio, Dorsal Ancho, Bíceps',
      equipment: 'Polea / Cable',
      movementPattern: 'row',
      difficulty: 'Principiante',
      instructions:
          '1. Siéntate con los pies en las plataformas, rodillas semiflexionadas y torso erguido.\n'
          '2. Tira del maneral hacia el abdomen juntando fuerte los omóplatos y sacando pecho.\n'
          '3. Extiende los brazos de regreso manteniendo la columna neutra.',
      commonMistakes:
          'Balancear el tronco adelante y atrás usando la inercia lumbar en cada repetición.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Seated-Cable-Row.gif',
    ),
    Exercise(
      name: 'Remo en Barra T o Máquina con Apoyo al Pecho',
      muscleGroup: 'Espalda',
      secondaryMuscles: 'Espalda Alta, Romboides, Dorsal Ancho',
      equipment: 'Máquina',
      movementPattern: 'row',
      difficulty: 'Intermedio',
      instructions:
          '1. Apoya el pecho en la almohadilla (o inclínate sobre la barra T con espalda recta).\n'
          '2. Tira de los agarres hacia atrás retrayendo al máximo las escápulas.\n'
          '3. Pausa medio segundo en la contracción y baja lento.',
      commonMistakes:
          'Despegar el pecho del soporte para tirar con impulso.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Lever-T-bar-Row.gif',
    ),
    Exercise(
      name: 'Pull-Over en Polea Alta con Brazos Rectos',
      muscleGroup: 'Espalda',
      secondaryMuscles: 'Dorsal Ancho (Aislamiento), Cabeza Larga del Tríceps, Serrato',
      equipment: 'Polea / Cable',
      movementPattern: 'lat_pulldown',
      difficulty: 'Principiante',
      instructions:
          '1. De pie frente a una polea alta con barra recta o soga, inclina el torso unos 30°.\n'
          '2. Con los brazos casi extendidos (ligera flexión fija en codos), baja la barra en arco hasta los muslos.\n'
          '3. Siente la contracción pura del dorsal sin involucrar los bíceps y sube con control.',
      commonMistakes:
          'Flexionar y extender los codos convirtiendo el ejercicio en una extensión de tríceps.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Cable-Straight-Arm-Pulldown.gif',
    ),
    Exercise(
      name: 'Encogimientos de Hombros con Mancuernas o Barra (Shrugs)',
      muscleGroup: 'Espalda',
      secondaryMuscles: 'Trapecio Superior, Elevador de la Escápula',
      equipment: 'Mancuernas',
      movementPattern: 'shrug',
      difficulty: 'Principiante',
      instructions:
          '1. De pie con mancuernas a los lados o barra al frente, brazos completamente extendidos.\n'
          '2. Eleva los hombros en línea recta hacia las orejas lo más alto posible y mantén 1-2 segundos.\n'
          '3. Baja lentamente dejando estirar el trapecio.',
      commonMistakes:
          'Hacer círculos con los hombros (no aporta beneficio y sobrecarga la articulación) o doblar los codos.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/04/Dumbbell-Shrug.gif',
    ),

    // =========================================================================
    // 3. HOMBROS (SHOULDERS)
    // =========================================================================
    Exercise(
      name: 'Press Militar con Barra de Pie o Sentado (Overhead Press)',
      muscleGroup: 'Hombros',
      secondaryMuscles: 'Deltoides Anterior y Lateral, Tríceps, Core, Pecho Superior',
      equipment: 'Barra',
      movementPattern: 'overhead_press',
      difficulty: 'Intermedio',
      instructions:
          '1. Coloca la barra sobre la parte alta del pecho/clavículas con agarre ligeramente mayor al ancho de hombros.\n'
          '2. Contrae abdomen y glúteos para proteger la zona lumbar.\n'
          '3. Empuja la barra verticalmente pasando cerca del rostro y mete ligeramente la cabeza bajo la barra al bloquear arriba.\n'
          '4. Baja con control hasta las clavículas.',
      commonMistakes:
          'Hiperextender la espalda baja como si fuera un press inclinado o dejar los codos abiertos hacia atrás.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Shoulder-Press.gif',
    ),
    Exercise(
      name: 'Press de Hombros Sentado con Mancuernas',
      muscleGroup: 'Hombros',
      secondaryMuscles: 'Deltoides Anterior y Medio, Tríceps',
      equipment: 'Mancuernas',
      movementPattern: 'overhead_press',
      difficulty: 'Principiante',
      instructions:
          '1. Siéntate en un banco con respaldo a 75°-85° y lleva las mancuernas a la altura de las orejas.\n'
          '2. Mantén los codos ligeramente adelantados respecto al plano del cuerpo (plano escapular, ~30°).\n'
          '3. Empuja las mancuernas hacia arriba hasta casi tocarse y baja de manera fluida.',
      commonMistakes:
          'Bajar solo hasta la mitad o chocar fuertemente las mancuernas arriba.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Shoulder-Press.gif',
    ),
    Exercise(
      name: 'Press Arnold con Mancuernas',
      muscleGroup: 'Hombros',
      secondaryMuscles: 'Las 3 cabezas del Deltoides, Tríceps',
      equipment: 'Mancuernas',
      movementPattern: 'overhead_press',
      difficulty: 'Intermedio',
      instructions:
          '1. Inicia sentado con las mancuernas frente al mentón y las palmas mirando hacia ti (supinación).\n'
          '2. Mientras empujas hacia arriba, abre los codos y gira las muñecas hasta que las palmas miren al frente en la cima.\n'
          '3. Invierte el giro suavemente al descender.',
      commonMistakes:
          'Hacer el giro de forma brusca abajo sin coordinarlo con el empuje vertical.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Arnold-Press.gif',
    ),
    Exercise(
      name: 'Press de Hombros en Máquina',
      muscleGroup: 'Hombros',
      secondaryMuscles: 'Tríceps, Deltoides Anterior',
      equipment: 'Máquina',
      movementPattern: 'overhead_press',
      difficulty: 'Principiante',
      instructions:
          '1. Ajusta el asiento para que los manerales queden a la altura de los hombros.\n'
          '2. Empuja hacia arriba sin despegar la espalda del respaldo y desciende controlando el peso.',
      commonMistakes:
          'Dejar caer el peso rápido en la fase excéntrica.',
    ),
    Exercise(
      name: 'Elevaciones Laterales con Mancuernas',
      muscleGroup: 'Hombros',
      secondaryMuscles: 'Deltoides Lateral (Medio), Supraespinoso',
      equipment: 'Mancuernas',
      movementPattern: 'lateral_raise',
      difficulty: 'Principiante',
      instructions:
          '1. De pie con el torso apenas inclinado hacia adelante y codos con ligera flexión fija.\n'
          '2. Eleva los brazos hacia los lados y ligeramente hacia adelante (plano escapular) pensando en alejar las mancuernas de ti.\n'
          '3. Sube hasta la línea de los hombros con los codos liderando el movimiento y baja lento.',
      commonMistakes:
          'Usar demasiado peso balanceando la espalda o encoger los trapecios hacia las orejas.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Lateral-Raise.gif',
    ),
    Exercise(
      name: 'Elevaciones Laterales en Polea Baja (Unilateral)',
      muscleGroup: 'Hombros',
      secondaryMuscles: 'Deltoides Lateral (Tensión Constante)',
      equipment: 'Polea / Cable',
      movementPattern: 'lateral_raise',
      difficulty: 'Intermedio',
      instructions:
          '1. Sitúate de lado a una polea baja (o con el cable pasando por detrás del cuerpo).\n'
          '2. Eleva el brazo lateralmente hasta la altura del hombro manteniendo tensión desde el primer centímetro.\n'
          '3. Haz una breve pausa arriba y desciende en 2-3 segundos.',
      commonMistakes:
          'Dejarse arrastrar por el cable en la bajada.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Cable-Lateral-Raise.gif',
    ),
    Exercise(
      name: 'Pájaros con Mancuernas (Elevaciones Posteriores Inclinado)',
      muscleGroup: 'Hombros',
      secondaryMuscles: 'Deltoides Posterior, Romboides, Trapecio Medio',
      equipment: 'Mancuernas',
      movementPattern: 'lateral_raise',
      difficulty: 'Intermedio',
      instructions:
          '1. Inclina el torso casi paralelo al suelo (o apoya el pecho en un banco inclinado).\n'
          '2. Eleva las mancuernas hacia afuera y atrás buscando trabajar la cara posterior del hombro.\n'
          '3. Evita juntar las escápulas en exceso para que el deltoides posterior lleve el protagonismo.',
      commonMistakes:
          'Levantar el tronco en cada repetición o tirar hacia las caderas como un remo.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Bent-Over-Lateral-Raise.gif',
    ),
    Exercise(
      name: 'Face Pull en Polea con Soga (Tirón a la Cara)',
      muscleGroup: 'Hombros',
      secondaryMuscles: 'Deltoides Posterior, Manguito Rotador, Trapecio Medio/Inferior',
      equipment: 'Polea / Cable',
      movementPattern: 'row',
      difficulty: 'Principiante',
      instructions:
          '1. Fija la cuerda en una polea a la altura del rostro o superior.\n'
          '2. Tira de los extremos de la cuerda hacia las orejas/frente separando las manos y haciendo rotación externa de hombros (terminar en pose de doble bíceps).\n'
          '3. Sostén 1 segundo atrás y regresa con control.',
      commonMistakes:
          'Cargar demasiado peso e inclinarse hacia atrás tirando hacia el pecho en lugar de hacia la cara.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Face-Pull.gif',
    ),
    Exercise(
      name: 'Elevaciones Frontales con Mancuernas o Barra',
      muscleGroup: 'Hombros',
      secondaryMuscles: 'Deltoides Anterior, Haz Clavicular',
      equipment: 'Mancuernas',
      movementPattern: 'lateral_raise',
      difficulty: 'Principiante',
      instructions:
          '1. De pie con las mancuernas frente a los muslos.\n'
          '2. Eleva los brazos al frente hasta la altura de los ojos manteniendo el abdomen firme.\n'
          '3. Desciende despacio sin columpiar la cadera.',
      commonMistakes:
          'Balancear el cuerpo hacia atrás para subir el peso.',
    ),

    // =========================================================================
    // 4. PIERNA - CUÁDRICEPS (QUADS)
    // =========================================================================
    Exercise(
      name: 'Sentadilla Libre con Barra (Back Squat)',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Glúteos, Aductores, Erectores Espinales, Core',
      equipment: 'Barra',
      movementPattern: 'squat',
      difficulty: 'Intermedio',
      instructions:
          '1. Apoya la barra sobre los trapecios (barra alta) o deltoides posteriores (barra baja).\n'
          '2. Separa los pies al ancho de los hombros con las puntas ligeramente hacia afuera (15°-30°).\n'
          '3. Toma aire profundo (maniobra de Valsalva / bracing abdominal) y flexiona rodillas y caderas en simultáneo.\n'
          '4. Baja hasta romper el paralelo (o según tu movilidad manteniendo espalda neutra) con las rodillas siguiendo la dirección de las puntas de los pies.\n'
          '5. Empuja el suelo con toda la planta del pie para subir.',
      commonMistakes:
          'Colapso de rodillas hacia adentro (valgo de rodilla), levantar los talones o redondear la zona lumbar abajo (butt wink excesivo).',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/BARBELL-SQUAT.gif',
    ),
    Exercise(
      name: 'Sentadilla Frontal con Barra (Front Squat)',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Core, Espalda Alta, Glúteos',
      equipment: 'Barra',
      movementPattern: 'squat',
      difficulty: 'Avanzado',
      instructions:
          '1. Apoya la barra sobre los deltoides anteriores usando agarre olímpico (codos altos) o cruzado.\n'
          '2. Mantén el pecho erguido y los codos apuntando al frente durante todo el descenso.\n'
          '3. Baja profundo enfatizando la flexión de rodilla y sube manteniendo la verticalidad del torso.',
      commonMistakes:
          'Dejar caer los codos haciendo que el tronco se venza hacia adelante.',
    ),
    Exercise(
      name: 'Sentadilla en Multipower (Máquina Smith)',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Glúteos',
      equipment: 'Multipower / Smith',
      movementPattern: 'squat',
      difficulty: 'Principiante',
      instructions:
          '1. Colócate bajo la barra guiada y adelanta ligeramente los pies respecto a la línea de la barra.\n'
          '2. Desbloquea la barra, baja con la espalda estable hasta 90° o más y sube sin bloquear bruscamente las rodillas.',
      commonMistakes:
          'Poner los pies demasiado atrás forzando la articulación de la rodilla sin estabilidad.',
    ),
    Exercise(
      name: 'Sentadilla Hack en Máquina (Hack Squat)',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Glúteos',
      equipment: 'Máquina',
      movementPattern: 'squat',
      difficulty: 'Intermedio',
      instructions:
          '1. Apoya toda la espalda y la cadera firmemente contra el respaldo de la máquina Hack.\n'
          '2. Coloca los pies en la parte media-baja de la plataforma para mayor énfasis en cuádriceps.\n'
          '3. Quita los seguros y desciende profundo de manera controlada sin despegar la zona lumbar.\n'
          '4. Empuja la plataforma hacia arriba.',
      commonMistakes:
          'Despegar los glúteos del respaldo en la parte baja o rebotar en el fondo.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Sled-Hack-Squat.gif',
    ),
    Exercise(
      name: 'Prensa de Piernas 45° (Leg Press)',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Glúteos, Isquiotibiales, Aductores',
      equipment: 'Máquina',
      movementPattern: 'squat',
      difficulty: 'Principiante',
      instructions:
          '1. Siéntate en la prensa apoyando bien el sacro y la espalda baja contra el respaldo.\n'
          '2. Ubica los pies al ancho de caderas en la plataforma y libera los topes.\n'
          '3. Baja el carro flexionando las rodillas hacia el pecho hasta donde tu cadera no se levante del asiento.\n'
          '4. Empuja con fuerza sin llegar a trabar por completo las rodillas (hiperextensión).',
      commonMistakes:
          'Bloquear las rodillas con cargas pesadas (muy peligroso) o empujar ayudándose con las manos en las rodillas.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Leg-Press.gif',
    ),
    Exercise(
      name: 'Sentadilla Búlgara con Mancuernas o Barra',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Glúteo Mayor y Medio, Isquiotibiales',
      equipment: 'Mancuernas',
      movementPattern: 'lunge',
      difficulty: 'Intermedio',
      instructions:
          '1. Apoya el empeine de un pie atrás sobre un banco plano y da un paso adelante con la pierna de trabajo.\n'
          '2. Para enfatizar cuádriceps mantén el torso más vertical; para enfatizar glúteo inclina ligeramente el torso hacia adelante.\n'
          '3. Baja hasta que la rodilla trasera quede cerca del suelo y empuja con la pierna delantera.',
      commonMistakes:
          'Hacer fuerza con la pierna trasera apoyada en el banco en vez de concentrar el 90% del peso en la delantera.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/05/Dumbbell-Bulgarian-Split-Squat.gif',
    ),
    Exercise(
      name: 'Zancadas / Estocadas con Mancuernas o Barra (Lunges)',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Glúteos, Isquiotibiales, Core',
      equipment: 'Mancuernas',
      movementPattern: 'lunge',
      difficulty: 'Principiante',
      instructions:
          '1. De pie con mancuernas a los lados, da un paso firme hacia adelante (o atrás).\n'
          '2. Desciende verticalmente hasta que ambas rodillas formen ángulos de ~90°.\n'
          '3. Impúlsate con el talón delantero para volver o avanzar al siguiente paso.',
      commonMistakes:
          'Caminar en línea recta como en una cuerda floja (pierdes equilibrio); mantén los pies al ancho de caderas.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Lunge.gif',
    ),
    Exercise(
      name: 'Extensiones de Cuádriceps en Máquina (Leg Extension)',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Recto Femoral, Vasto Lateral, Medial e Intermedio',
      equipment: 'Máquina',
      movementPattern: 'leg_extension',
      difficulty: 'Principiante',
      instructions:
          '1. Ajusta el respaldo para que la parte posterior de tus rodillas coincida con el eje de giro del asiento.\n'
          '2. Coloca el rodillo acolchado justo encima de los tobillos y sujeta los agarres laterales.\n'
          '3. Extiende las piernas por completo, sostén 1 segundo apretando los cuádriceps arriba y baja lento.',
      commonMistakes:
          'Patear el peso con impulso y levantar los glúteos del asiento.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/LEG-EXTENSION.gif',
    ),
    Exercise(
      name: 'Sentadilla Goblet con Mancuerna o Kettlebell',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Glúteos, Core, Espalda Alta',
      equipment: 'Kettlebell / Disco',
      movementPattern: 'squat',
      difficulty: 'Principiante',
      instructions:
          '1. Sujeta una mancuerna vertical o kettlebell pegada al pecho con ambas manos.\n'
          '2. Baja en sentadilla profunda manteniendo el pecho alto y los codos por dentro de las rodillas.\n'
          '3. Sube empujando el suelo con firmeza.',
      commonMistakes:
          'Alejar la pesa del pecho fatigando los brazos y la espalda baja.',
    ),
    Exercise(
      name: 'Sentadilla Isométrica en Pared (Wall Sit)',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Glúteos, Isquiotibiales, Core (Tensión Isométrica)',
      equipment: 'Peso Corporal',
      movementPattern: 'isometric_squat',
      difficulty: 'Principiante',
      instructions:
          '1. Apoya toda la espalda y la cabeza contra una pared firme.\n'
          '2. Deslízate hacia abajo y adelanta los pies hasta que las caderas y las rodillas formen un ángulo exacto de 90° (muslos paralelos al suelo).\n'
          '3. Mantén las manos a los costados o cruzadas en el pecho (sin apoyarte en los muslos) y sostén la contracción isométrica durante el tiempo objetivo.',
      commonMistakes:
          'Empujar los muslos con las manos quitando carga a los cuádriceps o dejar que las rodillas sobrepasen en exceso la punta de los pies.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/06/Wall-Sit.gif',
    ),
    Exercise(
      name: 'Sentadillas con Empuje (Thrusters con Mancuernas o Barra)',
      muscleGroup: 'Cuádriceps',
      secondaryMuscles: 'Hombros (Deltoides), Tríceps, Glúteos, Core',
      equipment: 'Mancuernas',
      movementPattern: 'thruster',
      difficulty: 'Intermedio',
      instructions:
          '1. Sostén las mancuernas o la barra a la altura de los hombros (posición de rack frontal) con los codos hacia adelante.\n'
          '2. Realiza una sentadilla profunda manteniendo el torso erguido y el abdomen firme.\n'
          '3. Sube de forma potente extendiendo rodillas y caderas y aprovecha ese mismo impulso para empujar el peso verticalmente sobre la cabeza en un solo movimiento fluido.\n'
          '4. Baja el peso a los hombros controladamente mientras encadenas la siguiente sentadilla.',
      commonMistakes:
          'Separar la sentadilla y el press militar en dos movimientos desconectados perdiendo la transferencia de potencia de las piernas.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Thruster.gif',
    ),

    // =========================================================================
    // 5. PIERNA - ISQUIOTIBIALES Y GLÚTEOS (HAMSTRINGS & GLUTES)
    // =========================================================================
    Exercise(
      name: 'Peso Muerto Convencional o Sumo con Barra',
      muscleGroup: 'Isquios y Glúteos',
      secondaryMuscles: 'Erectores Espinales, Dorsales, Trapecios, Cuádriceps, Antebrazos',
      equipment: 'Barra',
      movementPattern: 'deadlift',
      difficulty: 'Avanzado',
      instructions:
          '1. Acércate a la barra hasta que quede sobre la mitad de tus pies (a 2-3 cm de las tibias).\n'
          '2. Toma la barra fuera de las piernas (convencional) o por dentro con pies anchos (sumo).\n'
          '3. Baja la cadera hasta que las tibias toquen la barra, saca pecho, tensa los dorsales ("quita la holgura" de la barra) y mantén columna neutra.\n'
          '4. Empuja el suelo con las piernas mientras extiendes cadera y rodillas al unísono con la barra pegada al cuerpo.',
      commonMistakes:
          'Arquear la espalda baja ("perro asustado"), despegar la barra de las piernas o hiperextender la columna al final.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Deadlift.gif',
    ),
    Exercise(
      name: 'Peso Muerto Rumano con Barra (RDL)',
      muscleGroup: 'Isquios y Glúteos',
      secondaryMuscles: 'Glúteo Mayor, Erectores Espinales',
      equipment: 'Barra',
      movementPattern: 'deadlift',
      difficulty: 'Intermedio',
      instructions:
          '1. Inicia de pie sosteniendo la barra pegada a los muslos.\n'
          '2. Desbloquea las rodillas con una flexión mínima (15°-20°) que se mantendrá fija.\n'
          '3. Lleva la cadera hacia atrás (bisagra de cadera) deslizando la barra por los muslos y tibias hasta sentir el máximo estiramiento en los isquiotibiales (usualmente a mitad de tibia).\n'
          '4. Extiende la cadera contrayendo glúteos e isquios para volver arriba.',
      commonMistakes:
          'Bajar hasta el suelo doblando la espalda baja en lugar de detenerse cuando la cadera deja de ir hacia atrás.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Romanian-Deadlift.gif',
    ),
    Exercise(
      name: 'Peso Muerto Rumano con Mancuernas',
      muscleGroup: 'Isquios y Glúteos',
      secondaryMuscles: 'Glúteos, Zona Lumbar',
      equipment: 'Mancuernas',
      movementPattern: 'deadlift',
      difficulty: 'Principiante',
      instructions:
          '1. Sostén las mancuernas frente a los muslos con hombros retraídos.\n'
          '2. Empuja los glúteos hacia la pared de atrás manteniendo las mancuernas rozando las piernas.\n'
          '3. Sube extendiendo la cadera con fuerza.',
      commonMistakes:
          'Alejar las mancuernas hacia adelante sobrecargando los lumbares.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Romanian-Deadlift.gif',
    ),
    Exercise(
      name: 'Hip Thrust con Barra (Empuje de Cadera)',
      muscleGroup: 'Isquios y Glúteos',
      secondaryMuscles: 'Glúteo Mayor (Máxima Activación), Isquiotibiales, Cuádriceps',
      equipment: 'Barra',
      movementPattern: 'hip_thrust',
      difficulty: 'Intermedio',
      instructions:
          '1. Apoya la zona inferior de las escápulas en el borde de un banco estable y coloca la barra con almohadilla sobre la pelvis.\n'
          '2. Ubica los pies de forma que al subir las tibias queden completamente verticales (rodillas a 90°).\n'
          '3. Empuja con los talones elevando la cadera hasta quedar paralelo al suelo, mantén la mirada al frente (mentón recogido) y aprieta fuerte los glúteos 1-2 segundos.',
      commonMistakes:
          'Arquear la espalda baja mirando al techo en vez de hacer retroversión pélvica arriba.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Hip-Thrust.gif',
    ),
    Exercise(
      name: 'Camilla de Isquios / Curl Femoral Tumbado (Lying Leg Curl)',
      muscleGroup: 'Isquios y Glúteos',
      secondaryMuscles: 'Bíceps Femoral, Semitendinoso, Semimembranoso, Gemelos',
      equipment: 'Máquina',
      movementPattern: 'lying_leg_curl',
      difficulty: 'Principiante',
      instructions:
          '1. Acuéstate boca abajo en la camilla de isquios alineando las rodillas justo en el borde del tapizado con el eje de la máquina y coloca el rodillo sobre el tendón de Aquiles.\n'
          '2. Sujeta los agarres delanteros y mantén la pelvis presionada contra la camilla en todo momento.\n'
          '3. Flexiona las rodillas llevando el rodillo hacia los glúteos, aprieta 1 segundo arriba y baja controlado en 2-3 segundos.',
      commonMistakes:
          'Levantar la cadera de la camilla al subir el peso quitando tensión a los isquiotibiales y sobrecargando la zona lumbar.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Lying-Leg-Curl.gif',
    ),
    Exercise(
      name: 'Swing con Pesa Rusa o Mancuerna (Kettlebell Swing)',
      muscleGroup: 'Isquios y Glúteos',
      secondaryMuscles: 'Glúteo Mayor, Isquiotibiales, Erectores Espinales, Deltoides, Core',
      equipment: 'Kettlebell / Disco',
      movementPattern: 'kettlebell_swing',
      difficulty: 'Intermedio',
      instructions:
          '1. De pie con los pies algo más anchos que los hombros, toma la kettlebell o mancuerna con ambas manos.\n'
          '2. Realiza una bisagra de cadera llevando los glúteos hacia atrás (sin bajar en sentadilla) y pasa la pesa entre los muslos con la espalda totalmente recta.\n'
          '3. Extiende la cadera de forma explosiva apretando fuerte los glúteos y el abdomen; el impulso de la cadera proyectará la pesa hasta la altura del pecho con los brazos relajados.\n'
          '4. Deja que la pesa vuelva a bajar en péndulo y encadena la siguiente bisagra cuando tus antebrazos toquen la pelvis.',
      commonMistakes:
          'Hacer una sentadilla en lugar de una bisagra de cadera, o levantar la pesa haciendo fuerza con los hombros en vez de impulsarla con los glúteos.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Kettlebell-Swing.gif',
    ),
    Exercise(
      name: 'Curl Femoral Sentado en Máquina (Seated Leg Curl)',
      muscleGroup: 'Isquios y Glúteos',
      secondaryMuscles: 'Isquiotibiales (Mayor Estiramiento en Cadera)',
      equipment: 'Máquina',
      movementPattern: 'leg_curl',
      difficulty: 'Principiante',
      instructions:
          '1. Ajusta el respaldo y fija la almohadilla superior sobre los muslos para inmovilizar las piernas.\n'
          '2. Flexiona las rodillas tirando del rodillo inferior hacia abajo y atrás lo máximo posible.\n'
          '3. Retorna lentamente aprovechando el estiramiento completo.',
      commonMistakes:
          'No ajustar el tope de los muslos permitiendo que las piernas se levanten.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/08/Seated-Leg-Curl.gif',
    ),
    Exercise(
      name: 'Patada de Glúteo en Polea Baja (Cable Kickback)',
      muscleGroup: 'Isquios y Glúteos',
      secondaryMuscles: 'Glúteo Mayor y Medio',
      equipment: 'Polea / Cable',
      movementPattern: 'lunge',
      difficulty: 'Principiante',
      instructions:
          '1. Coloca la tobillera conectada a la polea baja e inclina ligeramente el torso sujetándote de la torre.\n'
          '2. Extiende la pierna hacia atrás (y levemente hacia afuera, ~15°) concentrándote en contraer el glúteo sin arquear la cintura.\n'
          '3. Regresa con control.',
      commonMistakes:
          'Patear demasiado alto doblando la columna lumbar.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Cable-Glute-Kickback.gif',
    ),
    Exercise(
      name: 'Abducción de Cadera en Máquina Sentado',
      muscleGroup: 'Isquios y Glúteos',
      secondaryMuscles: 'Glúteo Medio y Menor',
      equipment: 'Máquina',
      movementPattern: 'squat',
      difficulty: 'Principiante',
      instructions:
          '1. Siéntate con la parte externa de las rodillas apoyada contra las almohadillas.\n'
          '2. Abre las piernas hacia afuera empujando con las caderas, sostén 1 segundo y cierra despacio.',
      commonMistakes:
          'Hacer repeticiones cortas y rebotadas sin controlar el cierre.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/HiP-ABDUCTION-MACHINE.gif',
    ),

    // =========================================================================
    // 6. BÍCEPS (BICEPS)
    // =========================================================================
    Exercise(
      name: 'Curl de Bíceps con Barra Recta',
      muscleGroup: 'Bíceps',
      secondaryMuscles: 'Braquial, Antebrazos',
      equipment: 'Barra',
      movementPattern: 'bicep_curl',
      difficulty: 'Principiante',
      instructions:
          '1. De pie con los pies al ancho de caderas, toma la barra en supinación al ancho de los hombros.\n'
          '2. Pega los codos a los costados del torso y mantenlos fijos.\n'
          '3. Flexiona los codos subiendo la barra en arco hasta la altura del pecho, aprieta los bíceps y baja lento hasta estirar el brazo.',
      commonMistakes:
          'Balancear la espalda hacia atrás para impulsar la barra o adelantar exageradamente los codos.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Curl.gif',
    ),
    Exercise(
      name: 'Curl de Bíceps con Barra EZ (Barra W)',
      muscleGroup: 'Bíceps',
      secondaryMuscles: 'Braquial, Braquiorradial (Menor Estrés en Muñecas)',
      equipment: 'Barra EZ',
      movementPattern: 'bicep_curl',
      difficulty: 'Principiante',
      instructions:
          '1. Sujeta la barra EZ en los ángulos internos o externos según quieras enfatizar cabeza larga o corta.\n'
          '2. Sube la barra manteniendo el torso firme y los codos estables a los lados.\n'
          '3. Controla la bajada en 2-3 segundos.',
      commonMistakes:
          'Dejar caer la barra sin control en la fase excéntrica.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/EZ-Bar-Curl.gif',
    ),
    Exercise(
      name: 'Curl Alterno o Simultáneo con Mancuernas (Con Supinación)',
      muscleGroup: 'Bíceps',
      secondaryMuscles: 'Bíceps Braquial, Supinador Largo',
      equipment: 'Mancuernas',
      movementPattern: 'bicep_curl',
      difficulty: 'Principiante',
      instructions:
          '1. Comienza con las mancuernas a los lados en agarre neutro.\n'
          '2. Al subir el antebrazo, gira la muñeca hacia afuera (supinación máxima) llevando el meñique más alto que el pulgar.\n'
          '3. Baja controlando el giro de regreso.',
      commonMistakes:
          'Rotar el hombro y el tronco para subir una mancuerna tras otra.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Curl.gif',
    ),
    Exercise(
      name: 'Curl Martillo con Mancuernas (Hammer Curl)',
      muscleGroup: 'Bíceps',
      secondaryMuscles: 'Braquial Anterior, Braquiorradial (Antebrazo)',
      equipment: 'Mancuernas',
      movementPattern: 'bicep_curl',
      difficulty: 'Principiante',
      instructions:
          '1. Sujeta las mancuernas con agarre neutro (palmas enfrentadas entre sí todo el tiempo).\n'
          '2. Flexiona el codo subiendo la mancuerna en vertical sin girar la muñeca.\n'
          '3. Aprieta arriba y desciende de forma controlada.',
      commonMistakes:
          'Impulsarse con las rodillas o acortar la extensión abajo.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Hammer-Curl.gif',
    ),
    Exercise(
      name: 'Curl de Bíceps en Banco Inclinado con Mancuernas',
      muscleGroup: 'Bíceps',
      secondaryMuscles: 'Cabeza Larga del Bíceps (Máximo Estiramiento)',
      equipment: 'Mancuernas',
      movementPattern: 'bicep_curl',
      difficulty: 'Intermedio',
      instructions:
          '1. Ajusta el banco a 45°-60° y recuéstate dejando caer los brazos completamente perpendiculares al suelo detrás del torso.\n'
          '2. Sin adelantar los codos, flexiona los antebrazos sintiendo el estiramiento profundo desde abajo.\n'
          '3. Baja hasta extender el codo por completo.',
      commonMistakes:
          'Llevar los codos hacia adelante al iniciar la subida perdiendo la ventaja del banco inclinado.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Seated-Incline-Dumbbell-Curl.gif',
    ),
    Exercise(
      name: 'Curl Predicador en Banco Scott (Barra EZ o Máquina)',
      muscleGroup: 'Bíceps',
      secondaryMuscles: 'Cabeza Corta del Bíceps, Braquial',
      equipment: 'Barra EZ',
      movementPattern: 'bicep_curl',
      difficulty: 'Intermedio',
      instructions:
          '1. Apoya la parte posterior de los brazos (tríceps) firmemente sobre la almohadilla del banco Scott.\n'
          '2. Baja la barra EZ de forma muy controlada hasta casi extender el brazo.\n'
          '3. Sube sin despegar los codos del acolchado.',
      commonMistakes:
          'Levantar el cuerpo del asiento o soltar la tensión de golpe en la parte más baja.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Z-Bar-Preacher-Curl.gif',
    ),
    Exercise(
      name: 'Curl de Bíceps en Polea Baja (Barra o Cuerda)',
      muscleGroup: 'Bíceps',
      secondaryMuscles: 'Bíceps, Braquiorradial (Tensión Constante)',
      equipment: 'Polea / Cable',
      movementPattern: 'bicep_curl',
      difficulty: 'Principiante',
      instructions:
          '1. Conecta una barra corta o soga a la polea baja.\n'
          '2. Mantén los codos pegados a las costillas y sube el agarre hacia los hombros.\n'
          '3. Aprovecha la tensión continua del cable en todo el rango.',
      commonMistakes:
          'Pararse demasiado lejos de la polea o encorvar los hombros.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/cable-curl.gif',
    ),
    Exercise(
      name: 'Curl Bayesian en Polea (De Espaldas al Cable)',
      muscleGroup: 'Bíceps',
      secondaryMuscles: 'Cabeza Larga del Bíceps',
      equipment: 'Polea / Cable',
      movementPattern: 'bicep_curl',
      difficulty: 'Intermedio',
      instructions:
          '1.oma un estribo en la polea baja y da un paso adelante quedando de espaldas a la torre con el hombro en extensión (brazo detrás del torso).\n'
          '2. Manteniendo el codo atrás, realiza el curl hacia adelante y regresa lento al estiramiento.',
      commonMistakes:
          'Adelantar el hombro durante la subida.',
    ),

    // =========================================================================
    // 7. TRÍCEPS (TRICEPS)
    // =========================================================================
    Exercise(
      name: 'Extensión de Tríceps en Polea Alta con Cuerda (Soga)',
      muscleGroup: 'Tríceps',
      secondaryMuscles: 'Cabeza Lateral y Medial del Tríceps',
      equipment: 'Polea / Cable',
      movementPattern: 'tricep_pushdown',
      difficulty: 'Principiante',
      instructions:
          '1. Frente a la polea alta, sujeta la cuerda e inclina el torso apenas 15° adelante.\n'
          '2. Fija los codos pegados al torso y extiende los antebrazos hacia abajo.\n'
          '3. Al llegar al final del recorrido, separa las puntas de la cuerda hacia afuera apretando el tríceps 1 segundo.',
      commonMistakes:
          'Subir y bajar los codos usando el pecho y los dorsales para empujar la cuerda.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Pushdown.gif',
    ),
    Exercise(
      name: 'Extensión de Tríceps en Polea Alta con Barra Recta o V',
      muscleGroup: 'Tríceps',
      secondaryMuscles: 'Cabeza Lateral y Medial del Tríceps',
      equipment: 'Polea / Cable',
      movementPattern: 'tricep_pushdown',
      difficulty: 'Principiante',
      instructions:
          '1. Toma la barra corta o barra en V con agarre prono.\n'
          '2. Con los codos inmóviles a los costados, empuja la barra hasta bloquear los brazos abajo.\n'
          '3. Sube hasta que el antebrazo pase levemente los 90° sin que los codos se separen.',
      commonMistakes:
          'Echarse encima de la barra con los hombros.',
    ),
    Exercise(
      name: 'Press Francés / Rompecráneos con Barra EZ (Skullcrushers)',
      muscleGroup: 'Tríceps',
      secondaryMuscles: 'Cabeza Larga y Medial del Tríceps',
      equipment: 'Barra EZ',
      movementPattern: 'skullcrusher',
      difficulty: 'Intermedio',
      instructions:
          '1. Túmbate en un banco plano o ligeramente inclinado sosteniendo la barra EZ sobre los hombros.\n'
          '2. Inclina los brazos unos 15° hacia atrás (hacia la cabeza) para mantener tensión constante.\n'
          '3. Flexiona únicamente los codos bajando la barra hacia la frente o detrás de la cabeza.\n'
          '4. Extiende los codos volviendo a la posición inicial sin abrirlos hacia afuera.',
      commonMistakes:
          'Abrir los codos lateralmente o mover los brazos como un pull-over.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Triceps-Extension.gif',
    ),
    Exercise(
      name: 'Extensión de Tríceps Tras Nuca con Mancuerna o en Polea (Overhead)',
      muscleGroup: 'Tríceps',
      secondaryMuscles: 'Cabeza Larga del Tríceps (Máximo Estiramiento)',
      equipment: 'Mancuernas',
      movementPattern: 'overhead_press',
      difficulty: 'Principiante',
      instructions:
          '1. Sentado o de pie, eleva una mancuerna con ambas manos (o cuerda en polea) por encima de la cabeza.\n'
          '2. Mantén los codos apuntando arriba y cerca de las orejas.\n'
          '3. Baja el peso detrás de la nuca flexionando los codos al máximo y extiende hacia el techo.',
      commonMistakes:
          'Arquear en exceso la columna lumbar por falta de activación abdominal.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Triceps-Extension.gif',
    ),
    Exercise(
      name: 'Press de Banca con Agarre Cerrado (Close-Grip Bench Press)',
      muscleGroup: 'Tríceps',
      secondaryMuscles: 'Pectoral, Deltoides Anterior',
      equipment: 'Barra',
      movementPattern: 'bench_press',
      difficulty: 'Intermedio',
      instructions:
          '1. Acuéstate en el banco plano y toma la barra al ancho exacto de los hombros (no juntes las manos del todo para cuidar las muñecas).\n'
          '2. Baja la barra pegando los codos a las costillas hacia la parte baja del esternón.\n'
          '3. Empuja con fuerza concentrándote en extender los codos con los tríceps.',
      commonMistakes:
          'Juntar las manos a 5 cm dañando las muñecas o abrir los codos como un press convencional.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Close-Grip-Bench-Press.gif',
    ),
    Exercise(
      name: 'Fondos entre Bancos o en Máquina de Fondos Sentado (Dip Machine)',
      muscleGroup: 'Tríceps',
      secondaryMuscles: 'Deltoides Anterior, Pectoral Inferior',
      equipment: 'Máquina',
      movementPattern: 'tricep_pushdown',
      difficulty: 'Principiante',
      instructions:
          '1. Siéntate en la máquina de fondos (o apoya las manos en un banco tras la espalda) manteniendo el torso erguido.\n'
          '2. Empuja hacia abajo extendiendo los codos por completo y regresa despacio hasta 90°.',
      commonMistakes:
          'Encoger los hombros hacia las orejas en la subida.',
    ),

    // =========================================================================
    // 8. ABDOMEN Y CORE (ABS & CORE)
    // =========================================================================
    Exercise(
      name: 'Crunch Abdominal en Polea Alta (Cable Crunch)',
      muscleGroup: 'Abdomen y Core',
      secondaryMuscles: 'Recto Abdominal, Oblicuos',
      equipment: 'Polea / Cable',
      movementPattern: 'crunch',
      difficulty: 'Intermedio',
      instructions:
          '1. Arrodíllate frente a una polea alta sujetando la cuerda a los lados de la cabeza.\n'
          '2. Deja la cadera fija e inmóvil y flexiona la columna vertebral llevando el esternón hacia la pelvis (enrollando el tronco).\n'
          '3. Exhala todo el aire abajo apretando el abdomen y sube estirando vértebra por vértebra.',
      commonMistakes:
          'Sentarse sobre los talones moviendo la cadera con la espalda recta en vez de flexionar la columna.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Kneeling-Cable-Crunch.gif',
    ),
    Exercise(
      name: 'Elevación de Piernas Colgado en Barra o Silla Romana',
      muscleGroup: 'Abdomen y Core',
      secondaryMuscles: 'Recto Abdominal Inferior, Oblicuos, Flexores de Cadera',
      equipment: 'Peso Corporal',
      movementPattern: 'crunch',
      difficulty: 'Intermedio',
      instructions:
          '1. Cuelga de la barra o apóyate en los antebrazos de la silla romana.\n'
          '2. Sube las rodillas o piernas rectas asegurándote de enrollar la pelvis hacia arriba al final (retroversión pélvica).\n'
          '3. Baja lentamente evitando cualquier balanceo del cuerpo.',
      commonMistakes:
          'Subir las piernas solo hasta los 90° sin bascular la pelvis (trabaja solo el psoas ilíaco).',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Hanging-Leg-Raises.gif',
    ),
    Exercise(
      name: 'Plancha Isométrica (Plank Abdominal)',
      muscleGroup: 'Abdomen y Core',
      secondaryMuscles: 'Transverso Abdominal, Recto Abdominal, Glúteos, Serrato Anterior',
      equipment: 'Peso Corporal',
      movementPattern: 'plank',
      difficulty: 'Principiante',
      instructions:
          '1. Apoya los antebrazos y las puntas de los pies en el suelo con los codos alineados exactamente debajo de los hombros.\n'
          '2. Forma una línea recta desde la cabeza hasta los talones contrayendo con máxima fuerza los glúteos y el abdomen (retroversión pélvica).\n'
          '3. Mantén la postura isométrica sin mover la cadera mientras respiras de manera constante.',
      commonMistakes:
          'Dejar caer la zona lumbar arqueando la espalda o subir los glúteos formando una carpa.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/plank.gif',
    ),

    // =========================================================================
    // 9. PANTORRILLAS Y ANTEBRAZOS (CALVES & FOREARMS)
    // =========================================================================
    Exercise(
      name: 'Elevación de Talones de Pie en Máquina o Multipower (Gemelos)',
      muscleGroup: 'Pantorrillas y Antebrazos',
      secondaryMuscles: 'Gastrocnemio (Gemelo Interno y Externo), Sóleo',
      equipment: 'Máquina',
      movementPattern: 'calf_raise',
      difficulty: 'Principiante',
      instructions:
          '1. Apoya los metatarsos (punta de los pies) sobre el escalón con las rodillas extendidas (sin hiperextender).\n'
          '2. Baja los talones todo lo posible durante 2 segundos para estirar el tendón de Aquiles.\n'
          '3. Sube en puntas de pie al máximo y mantén 1-2 segundos arriba en cada repetición.',
      commonMistakes:
          'Rebotar rápido a mitad de recorrido; el tendón de Aquiles es elástico y requiere pausas arriba y abajo para estimular el músculo.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Standing-Calf-Raise.gif',
    ),
    Exercise(
      name: 'Elevación de Talones Sentado en Máquina (Sóleo)',
      muscleGroup: 'Pantorrillas y Antebrazos',
      secondaryMuscles: 'Sóleo (Trabaja con Rodilla a 90°)',
      equipment: 'Máquina',
      movementPattern: 'calf_raise',
      difficulty: 'Principiante',
      instructions:
          '1. Siéntate ajustando las almohadillas sobre el extremo inferior de los muslos.\n'
          '2. Desciende los talones al máximo para estirar el sóleo.\n'
          '3. Eleva los talones con pausa de 1 segundo en la contracción máxima.',
      commonMistakes:
          'Hacer repeticiones cortas y aceleradas.',
      externalMediaUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/06/Lever-Seated-Calf-Raise.gif',
    ),
    Exercise(
      name: 'Curl de Muñeca con Barra o Mancuernas (Antebrazos)',
      muscleGroup: 'Pantorrillas y Antebrazos',
      secondaryMuscles: 'Flexores y Extensores del Carpo',
      equipment: 'Barra',
      movementPattern: 'bicep_curl',
      difficulty: 'Principiante',
      instructions:
          '1. Apoya los antebrazos sobre tus muslos o un banco dejando las muñecas libres en el borde.\n'
          '2. Deja bajar la barra abriendo ligeramente los dedos y luego flexiona las muñecas hacia arriba apretando fuerte.',
      commonMistakes:
          'Levantar todo el antebrazo del banco ayudándose con el bíceps.',
    ),
  ];

  /// Plantillas prearmadas listas para importar en 1 clic
  static List<Map<String, dynamic>> getPresetRoutineTemplates() {
    return [
      {
        'name': 'Push / Pull / Legs (Empuje - Tirón - Pierna)',
        'days_per_week': 3,
        'description':
            'División científica de 3 días (escalable a 6 días) que agrupa músculos por patrón biomecánico: Día 1 Empuje (Pecho, Hombro, Tríceps), Día 2 Tirón (Espalda, Bíceps) y Día 3 Piernas completas.',
        'days': [
          {
            'day_number': 1,
            'day_name': 'Día 1: Push (Pecho, Hombros y Tríceps)',
            'exercises': [
              {'name': 'Press de Banca Plano con Barra', 'sets': 4, 'reps': '6-8'},
              {'name': 'Press Inclinado con Mancuernas', 'sets': 3, 'reps': '8-10'},
              {'name': 'Cruce de Poleas Altas (Cable Crossover)', 'sets': 3, 'reps': '12-15'},
              {'name': 'Press Militar con Barra de Pie o Sentado (Overhead Press)', 'sets': 3, 'reps': '8-10'},
              {'name': 'Elevaciones Laterales con Mancuernas', 'sets': 4, 'reps': '12-15'},
              {'name': 'Extensión de Tríceps en Polea Alta con Cuerda (Soga)', 'sets': 3, 'reps': '10-12'},
            ],
          },
          {
            'day_number': 2,
            'day_name': 'Día 2: Pull (Espalda, Deltoides Post. y Bíceps)',
            'exercises': [
              {'name': 'Jalón al Pecho en Polea Alta (Agarre Ancho)', 'sets': 4, 'reps': '8-10'},
              {'name': 'Remo con Barra Inclinado (Agarre Prono o Supino)', 'sets': 4, 'reps': '8-10'},
              {'name': 'Remo en Polea Baja Sentado (Gironda)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Face Pull en Polea con Soga (Tirón a la Cara)', 'sets': 3, 'reps': '12-15'},
              {'name': 'Curl de Bíceps con Barra EZ (Barra W)', 'sets': 3, 'reps': '8-12'},
              {'name': 'Curl Martillo con Mancuernas (Hammer Curl)', 'sets': 3, 'reps': '10-12'},
            ],
          },
          {
            'day_number': 3,
            'day_name': 'Día 3: Legs (Cuádriceps, Isquios, Glúteo y Gemelo)',
            'exercises': [
              {'name': 'Sentadilla Libre con Barra (Back Squat)', 'sets': 4, 'reps': '6-8'},
              {'name': 'Peso Muerto Rumano con Barra (RDL)', 'sets': 4, 'reps': '8-10'},
              {'name': 'Prensa de Piernas 45° (Leg Press)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Curl Femoral Tumbado en Máquina (Lying Leg Curl)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Extensiones de Cuádriceps en Máquina (Leg Extension)', 'sets': 3, 'reps': '12-15'},
              {'name': 'Elevación de Talones de Pie en Máquina o Multipower (Gemelos)', 'sets': 4, 'reps': '12-15'},
            ],
          },
        ],
      },
      {
        'name': 'Torso / Pierna (Upper / Lower - 4 Días)',
        'days_per_week': 4,
        'description':
            'Frecuencia 2 por grupo muscular ideal para hipertrofia y fuerza. Alterna 2 sesiones de tren superior y 2 sesiones de tren inferior por semana.',
        'days': [
          {
            'day_number': 1,
            'day_name': 'Día 1: Torso A (Énfasis Fuerza Horizontal)',
            'exercises': [
              {'name': 'Press de Banca Plano con Barra', 'sets': 4, 'reps': '6-8'},
              {'name': 'Remo con Barra Inclinado (Agarre Prono o Supino)', 'sets': 4, 'reps': '6-8'},
              {'name': 'Press Inclinado con Mancuernas', 'sets': 3, 'reps': '8-10'},
              {'name': 'Jalón al Pecho en Polea Alta (Agarre Ancho)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Elevaciones Laterales con Mancuernas', 'sets': 3, 'reps': '12-15'},
              {'name': 'Press Francés / Rompecráneos con Barra EZ (Skullcrushers)', 'sets': 3, 'reps': '10-12'},
            ],
          },
          {
            'day_number': 2,
            'day_name': 'Día 2: Pierna A (Énfasis Cuádriceps)',
            'exercises': [
              {'name': 'Sentadilla Libre con Barra (Back Squat)', 'sets': 4, 'reps': '6-8'},
              {'name': 'Peso Muerto Rumano con Mancuernas', 'sets': 3, 'reps': '8-10'},
              {'name': 'Prensa de Piernas 45° (Leg Press)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Extensiones de Cuádriceps en Máquina (Leg Extension)', 'sets': 3, 'reps': '12-15'},
              {'name': 'Elevación de Talones de Pie en Máquina o Multipower (Gemelos)', 'sets': 4, 'reps': '12-15'},
              {'name': 'Crunch Abdominal en Polea Alta (Cable Crunch)', 'sets': 3, 'reps': '12-15'},
            ],
          },
          {
            'day_number': 3,
            'day_name': 'Día 3: Torso B (Énfasis Hipertrofia y Vertical)',
            'exercises': [
              {'name': 'Press Militar con Barra de Pie o Sentado (Overhead Press)', 'sets': 4, 'reps': '6-8'},
              {'name': 'Dominadas Pronas (Pull-Ups)', 'sets': 4, 'reps': '6-10'},
              {'name': 'Press de Banca Plano con Mancuernas', 'sets': 3, 'reps': '8-12'},
              {'name': 'Remo Unilateral con Mancuerna (Serrucho)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Aperturas en Máquina Contractora (Pec Deck / Mariposa)', 'sets': 3, 'reps': '12-15'},
              {'name': 'Curl Alterno o Simultáneo con Mancuernas (Con Supinación)', 'sets': 3, 'reps': '10-12'},
            ],
          },
          {
            'day_number': 4,
            'day_name': 'Día 4: Pierna B (Énfasis Cadena Posterior y Glúteo)',
            'exercises': [
              {'name': 'Peso Muerto Convencional o Sumo con Barra', 'sets': 4, 'reps': '5-6'},
              {'name': 'Hip Thrust con Barra (Empuje de Cadera)', 'sets': 4, 'reps': '8-10'},
              {'name': 'Sentadilla Búlgara con Mancuernas o Barra', 'sets': 3, 'reps': '10-12'},
              {'name': 'Curl Femoral Sentado en Máquina (Seated Leg Curl)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Elevación de Talones Sentado en Máquina (Sóleo)', 'sets': 4, 'reps': '12-15'},
              {'name': 'Elevación de Piernas Colgado en Barra o Silla Romana', 'sets': 3, 'reps': '12-15'},
            ],
          },
        ],
      },
      {
        'name': 'Full Body (Cuerpo Completo - 3 Días)',
        'days_per_week': 3,
        'description':
            'Entrena todos los grandes grupos musculares en cada sesión con alta eficiencia (Lunes, Miércoles y Viernes). Excelente para principiantes e intermedios.',
        'days': [
          {
            'day_number': 1,
            'day_name': 'Día 1: Full Body A',
            'exercises': [
              {'name': 'Sentadilla Libre con Barra (Back Squat)', 'sets': 4, 'reps': '6-8'},
              {'name': 'Press de Banca Plano con Barra', 'sets': 4, 'reps': '6-8'},
              {'name': 'Remo en Polea Baja Sentado (Gironda)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Elevaciones Laterales con Mancuernas', 'sets': 3, 'reps': '12-15'},
              {'name': 'Curl de Bíceps con Barra EZ (Barra W)', 'sets': 3, 'reps': '10-12'},
            ],
          },
          {
            'day_number': 2,
            'day_name': 'Día 2: Full Body B',
            'exercises': [
              {'name': 'Peso Muerto Rumano con Barra (RDL)', 'sets': 4, 'reps': '8-10'},
              {'name': 'Press de Hombros Sentado con Mancuernas', 'sets': 4, 'reps': '8-10'},
              {'name': 'Jalón al Pecho en Polea Alta (Agarre Ancho)', 'sets': 4, 'reps': '8-12'},
              {'name': 'Prensa de Piernas 45° (Leg Press)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Extensión de Tríceps en Polea Alta con Cuerda (Soga)', 'sets': 3, 'reps': '10-12'},
            ],
          },
          {
            'day_number': 3,
            'day_name': 'Día 3: Full Body C',
            'exercises': [
              {'name': 'Hip Thrust con Barra (Empuje de Cadera)', 'sets': 4, 'reps': '8-10'},
              {'name': 'Press Inclinado con Mancuernas', 'sets': 4, 'reps': '8-10'},
              {'name': 'Remo Unilateral con Mancuerna (Serrucho)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Extensiones de Cuádriceps en Máquina (Leg Extension)', 'sets': 3, 'reps': '12-15'},
              {'name': 'Face Pull en Polea con Soga (Tirón a la Cara)', 'sets': 3, 'reps': '12-15'},
            ],
          },
        ],
      },
      {
        'name': 'División Clásica Culturista Weider (5 Días)',
        'days_per_week': 5,
        'description':
            'Alto volumen localizado por grupo muscular en 5 sesiones semanales dedicadas.',
        'days': [
          {
            'day_number': 1,
            'day_name': 'Día 1: Pecho y Abdomen',
            'exercises': [
              {'name': 'Press de Banca Plano con Barra', 'sets': 4, 'reps': '6-8'},
              {'name': 'Press Inclinado con Mancuernas', 'sets': 4, 'reps': '8-10'},
              {'name': 'Fondos en Paralelas para Pecho (Dips)', 'sets': 3, 'reps': '8-12'},
              {'name': 'Cruce de Poleas Altas (Cable Crossover)', 'sets': 3, 'reps': '12-15'},
              {'name': 'Crunch Abdominal en Polea Alta (Cable Crunch)', 'sets': 4, 'reps': '12-15'},
            ],
          },
          {
            'day_number': 2,
            'day_name': 'Día 2: Espalda y Trapecios',
            'exercises': [
              {'name': 'Dominadas Pronas (Pull-Ups)', 'sets': 4, 'reps': '6-10'},
              {'name': 'Remo con Barra Inclinado (Agarre Prono o Supino)', 'sets': 4, 'reps': '8-10'},
              {'name': 'Jalón al Pecho con Agarre Neutro / Triángulo (Close-Grip)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Pull-Over en Polea Alta con Brazos Rectos', 'sets': 3, 'reps': '12-15'},
              {'name': 'Encogimientos de Hombros con Mancuernas o Barra (Shrugs)', 'sets': 4, 'reps': '12-15'},
            ],
          },
          {
            'day_number': 3,
            'day_name': 'Día 3: Hombros y Pantorrillas',
            'exercises': [
              {'name': 'Press Militar con Barra de Pie o Sentado (Overhead Press)', 'sets': 4, 'reps': '6-8'},
              {'name': 'Press Arnold con Mancuernas', 'sets': 3, 'reps': '8-10'},
              {'name': 'Elevaciones Laterales con Mancuernas', 'sets': 4, 'reps': '12-15'},
              {'name': 'Pájaros con Mancuernas (Elevaciones Posteriores Inclinado)', 'sets': 4, 'reps': '12-15'},
              {'name': 'Elevación de Talones de Pie en Máquina o Multipower (Gemelos)', 'sets': 4, 'reps': '12-15'},
            ],
          },
          {
            'day_number': 4,
            'day_name': 'Día 4: Piernas Completas',
            'exercises': [
              {'name': 'Sentadilla Libre con Barra (Back Squat)', 'sets': 4, 'reps': '6-8'},
              {'name': 'Prensa de Piernas 45° (Leg Press)', 'sets': 4, 'reps': '10-12'},
              {'name': 'Peso Muerto Rumano con Barra (RDL)', 'sets': 4, 'reps': '8-10'},
              {'name': 'Extensiones de Cuádriceps en Máquina (Leg Extension)', 'sets': 3, 'reps': '12-15'},
              {'name': 'Curl Femoral Tumbado en Máquina (Lying Leg Curl)', 'sets': 3, 'reps': '10-12'},
            ],
          },
          {
            'day_number': 5,
            'day_name': 'Día 5: Brazos (Bíceps, Tríceps y Antebrazo)',
            'exercises': [
              {'name': 'Press de Banca con Agarre Cerrado (Close-Grip Bench Press)', 'sets': 4, 'reps': '8-10'},
              {'name': 'Curl de Bíceps con Barra Recta', 'sets': 4, 'reps': '8-10'},
              {'name': 'Press Francés / Rompecráneos con Barra EZ (Skullcrushers)', 'sets': 3, 'reps': '10-12'},
              {'name': 'Curl de Bíceps en Banco Inclinado con Mancuernas', 'sets': 3, 'reps': '10-12'},
              {'name': 'Extensión de Tríceps en Polea Alta con Cuerda (Soga)', 'sets': 3, 'reps': '12-15'},
              {'name': 'Curl Martillo con Mancuernas (Hammer Curl)', 'sets': 3, 'reps': '10-12'},
            ],
          },
        ],
      },
    ];
  }
}
