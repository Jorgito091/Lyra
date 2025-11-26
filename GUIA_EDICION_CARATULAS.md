# Guía de Edición de Carátulas - Lyra

## ✅ Funcionalidad Ya Implementada

La aplicación **ya tiene completa** la funcionalidad para editar carátulas de canciones y playlists. Esta guía explica cómo usarla.

## 📝 Cómo Editar Canciones

### Paso 1: Acceder al Editor
1. Abre la app Lyra
2. Ve a la pestaña **"Library"** (Biblioteca)
3. Encuentra la canción que deseas editar
4. **Desliza hacia la izquierda** sobre la canción
5. Aparecerán dos botones: "Delete" (rojo) y "Edit" (azul)
6. Toca el botón **"Edit"** (azul)

### Paso 2: Editar la Información
Una vez en el editor, podrás:
- **Cambiar la carátula**: Toca "Choose Image" y selecciona una foto de tu galería
- **Cambiar el título**: Edita el campo "Title"
- **Cambiar el artista**: Edita el campo "Artist"
- **Cambiar el álbum**: Edita el campo "Album"

### Paso 3: Guardar Cambios
- Toca **"Save"** para guardar los cambios
- Toca **"Cancel"** para cancelar sin guardar

## 🎵 Cómo Editar Playlists

### Paso 1: Acceder al Editor
1. Abre la app Lyra
2. Ve a la pestaña **"Playlists"**
3. Toca sobre la playlist que deseas editar
4. Una vez dentro de la playlist, toca el botón **"Edit"** en el encabezado (junto al botón "Play")

### Paso 2: Editar la Información
Una vez en el editor, podrás:
- **Cambiar la carátula**: Toca "Choose Image" y selecciona una foto de tu galería
- **Cambiar el nombre**: Edita el campo "Playlist Name"

### Paso 3: Guardar Cambios
- Toca **"Save"** para guardar los cambios
- Toca **"Cancel"** para cancelar sin guardar

## 🎨 Consejos para las Carátulas

1. **Usa imágenes cuadradas** para mejores resultados (ej: 500x500, 1000x1000)
2. Las carátulas se comprimen automáticamente para ahorrar espacio
3. Puedes usar cualquier imagen de tu galería de fotos
4. Las carátulas aparecerán en:
   - La lista de canciones/playlists
   - La pantalla "Now Playing"
   - La pantalla de bloqueo cuando reproduces música
   - Los controles del Centro de Control

## 🔊 Sobre la Reproducción en Segundo Plano

La música **sigue reproduciéndose cuando bloqueas el dispositivo** - esto es el comportamiento correcto y esperado para una app de música profesional.

### ¿Por qué sucede esto?
- Todas las apps de música (Spotify, Apple Music, YouTube Music, etc.) funcionan así
- Fue parte de los requisitos originales del proyecto
- Te permite escuchar música mientras haces otras cosas

### Cómo controlar la reproducción:
- **Pausar desde la pantalla de bloqueo**: Usa los controles que aparecen en la pantalla bloqueada
- **Pausar desde el Centro de Control**: Desliza hacia abajo y usa los controles
- **Pausar antes de bloquear**: Simplemente pausa la música antes de presionar el botón de bloqueo

### Si NO quieres que la música siga reproduciéndose:
1. Pausa la música manualmente antes de bloquear el dispositivo
2. O usa los controles de la pantalla de bloqueo para pausar

## ❓ Problemas Comunes

### "No veo el botón Edit en las canciones"
- Asegúrate de **deslizar hacia la izquierda** sobre la canción
- El botón "Edit" está en azul, a la derecha del botón "Delete" rojo

### "No puedo cambiar la carátula"
- Asegúrate de que la app tiene permiso para acceder a tu galería de fotos
- iOS te pedirá permiso la primera vez que intentes seleccionar una imagen
- Ve a Configuración > Lyra > Fotos y asegúrate de que esté habilitado

### "Los cambios no se guardan"
- Asegúrate de tocar el botón "Save" en la esquina superior derecha
- Si tocas "Cancel" o cierras la pantalla sin guardar, los cambios se perderán

## 📸 Ejemplos de Uso

### Ejemplo 1: Personalizar una Canción Importada
```
1. Importas "cancion.mp3" → aparece como "cancion" sin carátula
2. Deslizas hacia la izquierda sobre "cancion"
3. Tocas "Edit"
4. Cambias el título a "Mi Canción Favorita"
5. Cambias el artista a "Artista Desconocido"
6. Tocas "Choose Image" y seleccionas una foto
7. Tocas "Save"
8. ¡Listo! Tu canción ahora tiene carátula y metadatos correctos
```

### Ejemplo 2: Personalizar una Playlist
```
1. Creas una playlist llamada "Workout"
2. Agregas varias canciones
3. Abres la playlist
4. Tocas el botón "Edit" en el encabezado
5. Tocas "Choose Image" y seleccionas una foto de ejercicio
6. Tocas "Save"
7. ¡Listo! Tu playlist ahora tiene una carátula personalizada
```

## ✨ Resumen

**Todo está implementado y funcionando:**
- ✅ Editar canciones (título, artista, álbum, carátula)
- ✅ Editar playlists (nombre, carátula)
- ✅ PhotosPicker para seleccionar imágenes
- ✅ Guardar y cargar carátulas automáticamente
- ✅ Mostrar carátulas en toda la app
- ✅ Reproducción en segundo plano (comportamiento correcto)

Solo necesitas usar la funcionalidad que ya existe en la aplicación.
