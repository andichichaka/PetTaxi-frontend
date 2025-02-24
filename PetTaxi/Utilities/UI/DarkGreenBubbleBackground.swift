import SwiftUI

struct DarkGreenBubbleBackground: View {
    @State private var bubbleOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color(red: 0, green: 100/255, blue: 0, opacity: 0.8)
                .edgesIgnoringSafeArea(.all)

            ForEach(0..<20) { _ in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: CGFloat.random(in: 50..<120), height: CGFloat.random(in: 50..<120))
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
