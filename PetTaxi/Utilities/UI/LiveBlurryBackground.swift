import SwiftUI

struct LiveBlurryBackground: View {
    @State private var bubbleOffset: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.color3.opacity(0.8), Color.color.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            ForEach(0..<20) { _ in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: CGFloat.random(in: 50..<150), height: CGFloat.random(in: 50..<150))
                    .position(
                        x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                    )
                    .offset(x: bubbleOffset, y: 0)
                    .animation(
                        Animation.easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: bubbleOffset
                    )
            }
        }
        .blur(radius: 10)
        .onAppear {
            bubbleOffset = 20
        }
    }
}
