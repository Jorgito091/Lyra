import SwiftUI
import AppKit

struct ImagePickerView: View {
    var onPick: (NSImage?) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Seleccionar Portada del Álbum")
                .font(.headline)
                .padding()
            
            Button("Seleccionar Imagen") {
                selectImage()
            }
            .padding()
            
            Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .frame(width: 300, height: 200)
    }
    
    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["png", "jpg", "jpeg", "tiff", "bmp", "gif"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        let response = panel.runModal()
        
        if response == .OK, let url = panel.url {
            if let image = NSImage(contentsOf: url) {
                onPick(image)
            } else {
                onPick(nil)
            }
        } else {
            onPick(nil)
        }
        
        // Cerrar la ventana después de seleccionar
        presentationMode.wrappedValue.dismiss()
    }
}

// Versión alternativa si prefieres el approach con NSViewControllerRepresentable
struct LegacyImagePickerView: NSViewControllerRepresentable {
    var onPick: (NSImage?) -> Void
    
    func makeNSViewController(context: Context) -> NSViewController {
        let controller = NSViewController()
        
        // Usar DispatchQueue para evitar problemas de timing
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.allowedFileTypes = ["png", "jpg", "jpeg", "tiff", "bmp", "gif"]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            
            panel.begin { response in
                if response == .OK, let url = panel.url {
                    if let image = NSImage(contentsOf: url) {
                        onPick(image)
                    } else {
                        onPick(nil)
                    }
                } else {
                    onPick(nil)
                }
            }
        }
        
        return controller
    }
    
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
}
