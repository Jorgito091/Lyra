import SwiftUI
import AppKit

struct DropDetectorView: NSViewRepresentable {
    @Binding var isDraggingOver: Bool
    
    class DropView: NSView {
        weak var coordinator: Coordinator?
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.registerForDraggedTypes([.fileURL])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
            coordinator?.parent.isDraggingOver = true
            return .copy
        }
        
        override func draggingExited(_ sender: NSDraggingInfo?) {
            coordinator?.parent.isDraggingOver = false
        }
        
        override func draggingEnded(_ sender: NSDraggingInfo) {
            coordinator?.parent.isDraggingOver = false
        }
        
        override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
            coordinator?.parent.isDraggingOver = false
            return true
        }
    }
    
    class Coordinator {
        var parent: DropDetectorView
        
        init(parent: DropDetectorView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeNSView(context: Context) -> DropView {
        let view = DropView()
        view.coordinator = context.coordinator
        return view
    }
    
    func updateNSView(_ nsView: DropView, context: Context) {
        nsView.coordinator = context.coordinator
    }
}
