# Lyra - Aplicación de Música

Una aplicación completa de reproductor de música para iOS con reproducción en segundo plano, gestión de listas de reproducción y soporte para carátulas personalizadas.

## Características Principales

### 🎵 Biblioteca Musical
- Importa archivos MP3 desde la aplicación Archivos
- Visualiza toda tu música en una biblioteca limpia y organizada
- Busca canciones por título, artista o álbum
- Edita metadatos de canciones (título, artista, álbum)
- Añade carátulas personalizadas a las canciones
- Elimina canciones de la biblioteca

### 📝 Gestión de Listas de Reproducción
- Crea listas de reproducción personalizadas
- Añade carátulas personalizadas a las listas de reproducción (tipo Spotify)
- Agrega/elimina canciones de las listas de reproducción
- Edita nombres y carátulas de listas de reproducción
- Elimina listas de reproducción

### 🎧 Funciones de Reproducción
- Soporte completo para reproducción en segundo plano
- Controles en la pantalla de bloqueo con carátula del álbum
- Reproducir/pausar, saltar adelante/atrás
- Buscar dentro de las pistas
- Reproductor mini para controles rápidos
- Reproducción continua a través de listas de reproducción

### 🎨 Interfaz de Usuario
- Diseño moderno con SwiftUI
- Navegación basada en pestañas
- Hermosos fondos degradados
- Animaciones suaves
- Soporte para modo oscuro

## Cómo Usar

### 1. Agregar Música
1. Ve a la pestaña "Library" (Biblioteca)
2. Toca el botón "+" en la esquina superior derecha
3. Selecciona archivos MP3 desde tu dispositivo
4. Los archivos se importarán automáticamente

### 2. Personalizar Carátulas de Canciones
1. En la vista Library, desliza hacia la izquierda sobre una canción
2. Toca "Edit" (Editar)
3. Toca "Choose Image" (Elegir Imagen)
4. Selecciona una imagen de tu biblioteca de fotos
5. Toca "Save" (Guardar)

### 3. Crear Lista de Reproducción
1. Ve a la pestaña "Playlists"
2. Toca el botón "+"
3. Ingresa un nombre para la lista de reproducción
4. (Opcional) Toca "Choose Image" para añadir una carátula personalizada
5. Toca "Create" (Crear)

### 4. Personalizar Carátula de Lista de Reproducción
Al crear o editar una lista de reproducción:
1. Toca "Choose Image" bajo la vista previa de la carátula
2. Selecciona una imagen de tu biblioteca
3. La carátula se aplicará automáticamente

### 5. Agregar Canciones a una Lista de Reproducción
1. Abre una lista de reproducción
2. Toca el botón "+" en la parte superior
3. Selecciona las canciones que deseas agregar (toca para marcar)
4. Toca "Add" (Agregar) para confirmar

### 6. Reproducir Música
1. Toca cualquier canción para iniciar la reproducción
2. Usa los controles en la pestaña "Now Playing" (Reproduciendo Ahora)
3. El reproductor mini aparece en la parte inferior para control rápido
4. La música continúa reproduciéndose cuando bloqueas el dispositivo o cambias de aplicación

### 7. Controles de Reproducción

#### En la Aplicación:
- **Reproducir/Pausar**: Toca el botón grande circular
- **Siguiente**: Toca el botón de avance
- **Anterior**: Toca el botón de retroceso
- **Buscar**: Arrastra el control deslizante de progreso

#### Pantalla de Bloqueo:
- Todos los controles están disponibles en la pantalla de bloqueo
- La carátula del álbum se muestra automáticamente
- Usa los controles del Centro de Control

## Funciones Avanzadas

### Modo de Fondo
La aplicación está configurada para:
- Reproducir música continuamente en segundo plano
- Mantener la sesión de audio activa cuando cambias de aplicación
- Responder a comandos remotos (audífonos, CarPlay, etc.)
- Mostrar información en la pantalla de bloqueo

### Almacenamiento de Datos
- Los archivos MP3 se copian al directorio de documentos de la aplicación
- Los metadatos y listas de reproducción se guardan automáticamente
- Las carátulas se comprimen y almacenan eficientemente

### Edición de Metadatos
Puedes editar toda la información de las canciones:
- Título de la canción
- Nombre del artista
- Nombre del álbum
- Carátula personalizada

## Requisitos del Sistema
- iOS 17.0 o superior
- Espacio de almacenamiento para archivos de música
- Acceso a la biblioteca de fotos (para carátulas personalizadas)

## Consejos

1. **Organización**: Crea listas de reproducción temáticas para organizar tu música
2. **Carátulas**: Usa imágenes cuadradas para mejores resultados
3. **Búsqueda**: Usa la función de búsqueda en Library para encontrar canciones rápidamente
4. **Edición por Lotes**: Importa múltiples archivos MP3 a la vez

## Próximas Mejoras
- Sincronización con iCloud
- Ecualizador
- Soporte para letras
- Listas de reproducción inteligentes
- Modos aleatorio y repetición
- Gestión de cola de reproducción
- Compartir listas de reproducción

---

## Estructura Técnica

La aplicación está construida con:
- **SwiftUI** para la interfaz de usuario
- **AVFoundation** para la reproducción de audio
- **MediaPlayer** para controles remotos
- **UserDefaults** para persistencia de datos
- **PhotosPicker** para selección de imágenes

¡Disfruta tu música con Lyra! 🎵
