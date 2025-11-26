# Configuración Requerida para Lyra

## Permisos Necesarios

Para que la aplicación funcione correctamente, necesita ciertos permisos en el proyecto de Xcode.

### 1. Background Modes (Modos de Fondo)

La aplicación necesita el modo de audio en segundo plano habilitado:

1. Abre el proyecto en Xcode
2. Selecciona el target "Lyra"
3. Ve a la pestaña "Signing & Capabilities"
4. Haz clic en "+ Capability"
5. Agrega "Background Modes"
6. Marca la opción "Audio, AirPlay, and Picture in Picture"

### 2. Acceso a Archivos

Para importar archivos MP3:

En el archivo `Info.plist` o en la configuración del proyecto, asegúrate de que:
- El app puede acceder a archivos del usuario
- Soporta Document Types para MP3

### 3. Acceso a Fotos

Para personalizar carátulas:

La aplicación ya usa `PhotosPicker` que maneja los permisos automáticamente en iOS 14+.

## Configuración Automática del Proyecto

La mayoría de la configuración se hace automáticamente a través del código:

```swift
// En AudioPlayerManager.swift
private func setupAudioSession() {
    do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default, options: [])
        try audioSession.setActive(true)
    } catch {
        print("Failed to setup audio session: \(error)")
    }
}
```

## Verificación

Para verificar que todo está configurado correctamente:

1. Compila el proyecto sin errores
2. Ejecuta en un simulador o dispositivo
3. Intenta importar un archivo MP3
4. Verifica que la música siga reproduciéndose al bloquear el dispositivo
5. Verifica que los controles aparezcan en la pantalla de bloqueo

## Resolución de Problemas

### La música no se reproduce en segundo plano
- Verifica que "Background Modes" esté habilitado
- Verifica que "Audio, AirPlay, and Picture in Picture" esté marcado

### No puedo importar archivos MP3
- Verifica que el DocumentPicker tenga acceso a tipos de archivo de audio
- Asegúrate de que el archivo sea un MP3 válido

### Las carátulas no se guardan
- Verifica que PhotosPicker esté funcionando
- Verifica que haya espacio de almacenamiento disponible

## Notas Adicionales

- Los archivos MP3 se copian al directorio de documentos de la app
- Las carátulas se comprimen al 80% de calidad para ahorrar espacio
- Los metadatos se guardan en UserDefaults
- La app limpia automáticamente archivos cuando se eliminan canciones
