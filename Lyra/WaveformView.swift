import SwiftUI

struct WaveformView: View {
    var waveform: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let midY = height / 2
            let step = width / CGFloat(max(waveform.count - 1, 1))
            Path { path in
                path.move(to: CGPoint(x: 0, y: midY))
                for (i, amp) in waveform.enumerated() {
                    let x = CGFloat(i) * step
                    let y = midY - CGFloat(amp) * midY
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.accentColor, lineWidth: 2)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .frame(height: 50)
    }
}
