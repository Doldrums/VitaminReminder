import SwiftUI
struct ExampleView: View {
    @State var numberOfShakes: CGFloat = 0

    var body: some View {
        VStack {
            Text("Banana🍌🍌")
                .font(.largeTitle)
                .modifier(ShakeEffect(shakeNumber: numberOfShakes))
                .onAppear {
                    withAnimation(.easeIn(duration: 2.0)) {
                        numberOfShakes = 10
                    }
                }
        }
    }
}

struct ShakeEffect: AnimatableModifier {
    var shakeNumber: CGFloat = 0

    var animatableData: CGFloat {
        get {
            shakeNumber
        } set {
            shakeNumber = newValue
        }
    }

    func body(content: Content) -> some View {
        content
            .offset(x: sin(shakeNumber * .pi * 2) * 10)
    }
}


struct ExamplePreview: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}
