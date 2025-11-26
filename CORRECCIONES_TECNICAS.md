# Correcciones Técnicas - Audio en Segundo Plano y Edición

## Problemas Reportados

1. **La música se detiene cuando se apaga el teléfono**
2. **La edición de canciones/playlists a veces falla**

## Soluciones Implementadas

### 1. Audio en Segundo Plano

#### Problema
La sesión de audio se configuraba solo una vez al inicializar el AudioPlayerManager, pero no se reactivaba al iniciar la reproducción. Esto causaba que iOS desactivara la sesión de audio cuando el dispositivo se bloqueaba.

#### Solución
```swift
func play() {
    // Reactivar la sesión de audio antes de reproducir
    do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setActive(true)
    } catch {
        print("Failed to activate audio session: \(error.localizedDescription)")
    }
    
    player?.play()
    isPlaying = true
    startTimer()
    updateNowPlayingInfo()
}
```

#### Manejo de Interrupciones
También se agregó manejo de interrupciones de audio (llamadas telefónicas, alarmas, etc.):

```swift
private func setupNotifications() {
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleInterruption),
        name: AVAudioSession.interruptionNotification,
        object: AVAudioSession.sharedInstance()
    )
}

@objc private func handleInterruption(notification: Notification) {
    // Pausar cuando comienza una interrupción
    // Reanudar automáticamente si iOS lo indica
}
```

#### Resultado
- ✅ La música continúa reproduciéndose cuando bloqueas el dispositivo
- ✅ La reproducción se pausa durante llamadas telefónicas
- ✅ La reproducción se reanuda automáticamente después de interrupciones cuando es apropiado
- ✅ Los controles de la pantalla de bloqueo funcionan correctamente

### 2. Confiabilidad de Edición

#### Problema 1: Estado de UI no se actualizaba
SwiftUI a veces no detectaba cambios en arrays de estructuras, incluso con `@Published`.

#### Solución
Agregar notificaciones explícitas de cambios antes de modificar los arrays:

```swift
func updateSong(_ song: Song) {
    if let index = songs.firstIndex(where: { $0.id == song.id }) {
        objectWillChange.send()  // ← Notificación explícita
        songs[index] = song
        saveData()
    }
}

func updatePlaylist(_ playlist: Playlist) {
    if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
        objectWillChange.send()  // ← Notificación explícita
        var updatedPlaylist = playlist
        updatedPlaylist.dateModified = Date()
        playlists[index] = updatedPlaylist
        saveData()
    }
}
```

#### Problema 2: Estado de selección no se limpiaba
Cuando el usuario cerraba la hoja de edición deslizando hacia abajo, el estado `selectedSong` no se reseteaba, causando problemas en ediciones posteriores.

#### Solución
Agregar el callback `onDismiss` para limpiar el estado:

```swift
.sheet(isPresented: $showingEditSheet) {
    if let song = selectedSong {
        EditSongView(song: song)
    }
} onDismiss: {
    selectedSong = nil  // ← Resetear estado
}
```

#### Resultado
- ✅ Los cambios en canciones/playlists se reflejan inmediatamente en la UI
- ✅ La edición funciona consistentemente sin importar cómo se cierre la ventana
- ✅ No hay problemas de estado al editar múltiples elementos seguidos

## Pruebas Recomendadas

### Probar Audio en Segundo Plano
1. Reproduce una canción
2. Bloquea el dispositivo (botón de encendido)
3. ✅ La música debe continuar reproduciéndose
4. Desbloquea el dispositivo
5. ✅ Los controles deben mostrar el estado correcto
6. Haz una llamada mientras reproduce
7. ✅ La música debe pausarse durante la llamada
8. Finaliza la llamada
9. ✅ La música puede reanudarse manualmente

### Probar Edición de Canciones
1. Ve a Library
2. Desliza sobre una canción → "Edit"
3. Cambia el título, artista, álbum
4. Selecciona una carátula nueva
5. Toca "Save"
6. ✅ Los cambios deben aparecer inmediatamente
7. Edita la misma canción nuevamente
8. ✅ Debe mostrar los valores actualizados
9. Toca "Cancel"
10. ✅ No debe haber cambios
11. Edita otra canción diferente
12. ✅ Debe funcionar correctamente

### Probar Edición de Playlists
1. Ve a Playlists
2. Abre una playlist
3. Toca "Edit"
4. Cambia el nombre
5. Selecciona una carátula nueva
6. Toca "Save"
7. ✅ Los cambios deben aparecer inmediatamente en la lista
8. ✅ Los cambios deben aparecer en el detalle de la playlist

## Detalles Técnicos

### AVAudioSession
- **Categoría**: `.playback` - Permite reproducción en segundo plano
- **Modo**: `.default` - Modo estándar de reproducción
- **Reactivación**: Se llama `setActive(true)` cada vez que se inicia la reproducción

### Notificaciones del Sistema
- `AVAudioSession.interruptionNotification` - Maneja interrupciones de audio
- Se observa en el `init()` del AudioPlayerManager
- El observer se mantiene durante toda la vida de la app

### Estado de SwiftUI
- `@Published` arrays se actualizan automáticamente
- `objectWillChange.send()` garantiza que SwiftUI detecte los cambios
- `.onDismiss` callback limpia el estado cuando se cierra una sheet

### Background Modes
- Configurado en `INFOPLIST_KEY_UIBackgroundModes = audio`
- Permite que la app continúe ejecutándose para reproducir audio
- iOS puede suspender otras operaciones pero mantiene el audio activo

## Archivos Modificados

- `Lyra/Managers/AudioPlayerManager.swift` - Audio en segundo plano y manejo de interrupciones
- `Lyra/Managers/MusicLibraryManager.swift` - Notificaciones explícitas de cambios
- `Lyra/Views/Library/LibraryView.swift` - Reseteo de estado en `onDismiss`

## Referencias

- [AVAudioSession - Apple Documentation](https://developer.apple.com/documentation/avfoundation/avaudiosession)
- [Background Modes - Apple Documentation](https://developer.apple.com/documentation/avfoundation/media_playback/configuring_your_app_for_media_playback)
- [Handling Audio Interruptions](https://developer.apple.com/documentation/avfoundation/avaudiosession/responding_to_audio_session_interruptions)
