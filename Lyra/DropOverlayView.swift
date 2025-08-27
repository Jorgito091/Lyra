import SwiftUI

struct DropOverlayView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentColor.opacity(0.15))
                .stroke(Color.accentColor.opacity(0.8), style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
                .padding(20)
            
            VStack(spacing: 20) {
                Image(systemName: "arrow.down.to.line.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.accentColor)
                    .symbolEffect(.bounce, value: true)
                
                VStack(spacing: 8) {
                    Text("Suelta para importar canciones")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Archivos MP3, M4A, WAV, AIFF, FLAC, AAC")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: true)
    }
}
