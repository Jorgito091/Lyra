import SwiftUI
import AppKit

struct KeyboardEventHandler: NSViewRepresentable {
    weak var viewModel: MusicLibraryViewModel?
    
    class KeyView: NSView {
        weak var viewModel: MusicLibraryViewModel?
        
        override var acceptsFirstResponder: Bool { return true }
        
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            DispatchQueue.main.async {
                self.window?.makeFirstResponder(self)
            }
        }
        
        override func keyDown(with event: NSEvent) {
            guard let viewModel = viewModel else {
                super.keyDown(with: event)
                return
            }
            
            switch event.keyCode {
            case 49: // Barra espaciadora - Play/Pause
                viewModel.togglePlayback()
            case 123: // Flecha izquierda - Retroceder 15 segundos
                viewModel.seekBackward(by: 15)
            case 124: // Flecha derecha - Avanzar 15 segundos
                viewModel.seekForward(by: 15)
            case 126: // Flecha arriba - Subir volumen
                viewModel.setVolume(min(viewModel.volume + 0.1, 1.0))
            case 125: // Flecha abajo - Bajar volumen
                viewModel.setVolume(max(viewModel.volume - 0.1, 0.0))
            default:
                super.keyDown(with: event)
            }
        }
    }
    
    func makeNSView(context: Context) -> KeyView {
        let view = KeyView()
        view.viewModel = viewModel
        return view
    }
    
    func updateNSView(_ nsView: KeyView, context: Context) {
        nsView.viewModel = viewModel
    }
}
