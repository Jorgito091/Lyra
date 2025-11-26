# Lyra - Estructura de la Aplicación

## Arquitectura General

```
Lyra/
├── Models/                      # Modelos de datos
│   ├── Song.swift              # Modelo de canción con metadatos
│   └── Playlist.swift          # Modelo de lista de reproducción
│
├── Managers/                    # Gestores de lógica de negocio
│   ├── AudioPlayerManager.swift    # Reproductor de audio con soporte de fondo
│   └── MusicLibraryManager.swift   # Gestión de biblioteca y persistencia
│
├── Views/                       # Vistas de la interfaz
│   ├── MainTabView.swift       # Navegación principal con pestañas
│   │
│   ├── Library/                # Pestaña de biblioteca
│   │   └── LibraryView.swift  # Vista de biblioteca musical
│   │
│   ├── Playlists/              # Pestaña de listas de reproducción
│   │   ├── PlaylistsView.swift       # Vista de todas las playlists
│   │   └── PlaylistDetailView.swift  # Detalle de una playlist
│   │
│   ├── NowPlaying/             # Pestaña de reproducción actual
│   │   └── NowPlayingView.swift     # Controles de reproducción
│   │
│   └── Components/             # Componentes reutilizables
│       ├── SongRowView.swift           # Fila de canción
│       ├── PlaylistRowView.swift      # Fila de playlist
│       ├── MiniPlayerView.swift       # Reproductor mini
│       ├── EditSongView.swift         # Editar canción
│       ├── EditPlaylistView.swift     # Editar playlist
│       ├── CreatePlaylistView.swift   # Crear playlist
│       ├── AddSongsToPlaylistView.swift # Agregar canciones
│       └── DocumentPicker.swift       # Selector de archivos MP3
│
├── LyraApp.swift               # Punto de entrada de la app
└── ContentView.swift           # Vista raíz
```

## Flujo de Datos

```
Usuario
  ↓
MainTabView (Navegación)
  ↓
┌─────────────┬──────────────┬────────────────┐
│   Library   │  Playlists   │  Now Playing   │
└─────────────┴──────────────┴────────────────┘
      ↓              ↓                ↓
MusicLibraryManager ←→ AudioPlayerManager
      ↓                      ↓
  UserDefaults          AVAudioPlayer
  (Metadatos)        (Reproducción Audio)
      ↓                      ↓
  Documents             Background
  (Archivos MP3)        Audio Session
```

## Componentes Clave

### 1. AudioPlayerManager
**Responsabilidades:**
- Reproducción de audio
- Control de reproducción (play, pause, seek, skip)
- Modo de fondo
- Comandos remotos (pantalla de bloqueo)
- Gestión de cola de reproducción
- Información de "Now Playing"

**Características:**
- Singleton compartido
- ObservableObject para SwiftUI
- Delegado de AVAudioPlayer
- Comandos del Centro de Control

### 2. MusicLibraryManager
**Responsabilidades:**
- Gestión de canciones
- Gestión de playlists
- Persistencia de datos
- Importación de archivos MP3
- Actualización de metadatos

**Características:**
- Singleton compartido
- ObservableObject para SwiftUI
- Almacenamiento en UserDefaults
- Copia de archivos a Documents

### 3. Sistema de Vistas

#### MainTabView
- Navegación principal
- 3 pestañas: Library, Playlists, Now Playing
- Mini player flotante

#### LibraryView
- Lista de todas las canciones
- Búsqueda
- Importar MP3
- Editar/Eliminar canciones

#### PlaylistsView
- Lista de playlists
- Crear nuevas playlists
- Acceso a detalles

#### PlaylistDetailView
- Canciones en la playlist
- Carátula personalizada
- Agregar/remover canciones
- Reproducir playlist

#### NowPlayingView
- Carátula grande
- Información de la canción
- Controles de reproducción
- Barra de progreso

## Flujo de Usuario

### Importar Música
```
1. Usuario toca "+" en Library
   ↓
2. DocumentPicker se abre
   ↓
3. Usuario selecciona MP3(s)
   ↓
4. MusicLibraryManager copia archivos
   ↓
5. Extrae metadatos
   ↓
6. Guarda en UserDefaults
   ↓
7. Actualiza UI
```

### Personalizar Carátula
```
1. Usuario edita canción/playlist
   ↓
2. Toca "Choose Image"
   ↓
3. PhotosPicker se abre
   ↓
4. Usuario selecciona imagen
   ↓
5. Imagen se comprime (JPEG 80%)
   ↓
6. Se guarda en modelo
   ↓
7. MusicLibraryManager persiste datos
   ↓
8. UI se actualiza
```

### Reproducción
```
1. Usuario toca canción
   ↓
2. AudioPlayerManager recibe comando
   ↓
3. Carga archivo MP3
   ↓
4. Configura AVAudioPlayer
   ↓
5. Inicia reproducción
   ↓
6. Actualiza Now Playing Info
   ↓
7. UI refleja estado
   ↓
8. Continúa en background
```

## Características de iOS Utilizadas

### SwiftUI
- Declarativa
- Reactive (Combine)
- ObservableObject/@Published
- @StateObject/@State
- NavigationView
- TabView
- List
- Sheet modals

### AVFoundation
- AVAudioPlayer (reproducción)
- AVAudioSession (sesión de audio)
- AVAsset (metadatos)

### MediaPlayer
- MPRemoteCommandCenter (comandos remotos)
- MPNowPlayingInfoCenter (info pantalla bloqueo)
- MPMediaItemArtwork (carátula)

### PhotosUI
- PhotosPicker (selector de fotos)

### Foundation
- FileManager (gestión de archivos)
- UserDefaults (persistencia)
- URLSession (no usado aún)

## Patrones de Diseño

1. **Singleton**: AudioPlayerManager, MusicLibraryManager
2. **Observer**: ObservableObject/@Published para reactive UI
3. **Delegate**: AVAudioPlayerDelegate
4. **Coordinator**: DocumentPicker.Coordinator
5. **MVVM**: ViewModels (managers) + Views

## Seguridad y Permisos

- ✅ Audio en segundo plano (Background Modes)
- ✅ Acceso a biblioteca de fotos (PhotosPicker)
- ✅ Acceso a archivos (DocumentPicker)
- ✅ Security-scoped resources para archivos

## Persistencia

### UserDefaults
- Array de canciones (JSON)
- Array de playlists (JSON)

### FileManager
- Archivos MP3 en `Documents/Music/`
- Se copian desde ubicación original
- Se eliminan al borrar canción

### Datos en Memoria
- `@Published` properties para reactive updates
- Modelos `Codable` para serialización
