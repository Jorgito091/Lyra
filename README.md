# Lyra

**Lyra** es un reproductor de música personal para macOS, desarrollado en SwiftUI, centrado en la organización y reproducción de tu propia biblioteca de canciones locales.

## Características principales

- **Importación sencilla de canciones**
  - Arrastra y suelta archivos de audio (MP3, M4A, WAV, AIFF, FLAC, AAC) para agregarlos a tu biblioteca.
  - Diálogos y overlays personalizados para importar y seleccionar qué canciones agregar.

- **Gestión de Biblioteca**
  - Visualiza y busca fácilmente todas tus canciones.
  - Elimina canciones de la biblioteca.
  - Edición de carátulas de álbum mediante selector de imágenes.

- **Soporte de Playlists**
  - Crea, nombra y personaliza playlists con imágenes propias.
  - Añade canciones a playlists mediante menú contextual.

- **Reproductor avanzado**
  - Controles de reproducción: play, pausa, siguiente, anterior.
  - Soporte para reproducción aleatoria (shuffle) y repetición.
  - Barra de progreso y tiempos de reproducción.
  - Visualización expandida ("Big Picture Mode") tipo pantalla completa.
  - Teclas rápidas del teclado para controlar la música (espaciadora, flechas, etc).

- **Persistencia local**
  - Guarda toda tu música y tus playlists de manera local usando archivos JSON.
  - Carpeta dedicada (`LyraSongs`) para el almacenamiento de canciones importadas.

- **Interfaz moderna**
  - Basado completamente en SwiftUI.
  - Soporte para temas claros/oscuro y efectos visuales modernos.

- **Pruebas**
  - Estructura de tests unitarios y de interfaz incluidos.

## Estructura del proyecto

```
/
├── .DS_Store
├── Lyra.xcodeproj                # Proyecto Xcode
├── Lyra/                         # Código fuente principal de la app
│   ├── BigPicturePlayerView.swift
│   ├── DropOverlayView.swift
│   ├── ImagePickerView.swift
│   ├── ImportSongsDialog.swift
│   ├── KeyboardHandler.swift
│   ├── LyraApp.swift
│   ├── MusicLibraryView.swift
│   ├── MusicLibraryViewModel.swift
│   ├── MusicPlayerView.swift
│   ├── PlayListCreatorView.swift
│   ├── SongsListView.swift
│   └── ... (otros archivos relacionados)
├── LyraTests/                    # Pruebas unitarias
│   └── LyraTests.swift
├── LyraUITests/                  # Pruebas de interfaz de usuario
│   ├── LyraUITests.swift
│   └── LyraUITestsLaunchTests.swift
```

Esta estructura incluye el proyecto Xcode, el código fuente de Lyra, y las carpetas para pruebas unitarias y de interfaz gráfica. Cada carpeta y archivo cumple una función específica dentro del reproductor de música.

## Instalación y uso

1. Clona el repositorio y ábrelo en Xcode.
2. Compila y ejecuta el proyecto en tu Mac.
3. Arrastra tus canciones favoritas y comienza a crear playlists.

## Formatos soportados

- MP3, M4A, WAV, AIFF, FLAC, AAC, ALAC

## Créditos

Desarrollado por [Jorgito091](https://github.com/Jorgito091).

---

¡Disfruta de tu música con Lyra!