import SwiftUI
import UIKit

struct _StrokeText: UIViewRepresentable {
    var text: String
    var strokeColor: Color
    var strokeWidth: CGFloat
    var fontSize: CGFloat
    
    init(_ text: String, _ strokeColor: Color, _ strokeWidth: CGFloat, _ fontSize: CGFloat) {
        self.text = text
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.fontSize = fontSize
    }
    
    private func makeAttributedString() -> NSAttributedString {
        let attributedStringParagraphStyle = NSMutableParagraphStyle()
        attributedStringParagraphStyle.alignment = NSTextAlignment.center
        
        return NSAttributedString(
            string: text,
            attributes:[
                NSAttributedString.Key.paragraphStyle: attributedStringParagraphStyle,
                NSAttributedString.Key.strokeWidth: strokeWidth,
                NSAttributedString.Key.strokeColor: UIColor(strokeColor),
                NSAttributedString.Key.font:
                    UIFont.systemFont(ofSize: fontSize, weight: .bold)
            ]
        )
    }
    
    func makeUIView(context: Context) -> UILabel {
        let strokeLabel = UILabel(frame: CGRect.zero)
        strokeLabel.attributedText = makeAttributedString()
        strokeLabel.sizeToFit()
        strokeLabel.center = CGPoint.init(x: 0.0, y: 0.0)
        
        strokeLabel.setContentHuggingPriority(.required, for: .horizontal)
        strokeLabel.setContentHuggingPriority(.required, for: .vertical)
        
        return strokeLabel
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = makeAttributedString()
        uiView.sizeToFit()
    }
}

struct StrokeText: View {
    let lemonYellow = Color(hue: 0.1639, saturation: 1, brightness: 1)
    var text: String
    var strokeColor: Color
    var strokeWidth: CGFloat
    var fontSize: CGFloat
    var foregroundColor: Color
    
    init(_ text: String, strokeColor: Color = .black, strokeWidth: CGFloat = 3.0, fontSize: CGFloat = 72, foregroundColor: Color) {
        self.text = text
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.fontSize = fontSize
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        _StrokeText(text, strokeColor, strokeWidth, fontSize).overlay {
            Text(text)
                .foregroundColor(foregroundColor)
                .font(.system(size: fontSize, weight: .bold))
        }
    }
}
