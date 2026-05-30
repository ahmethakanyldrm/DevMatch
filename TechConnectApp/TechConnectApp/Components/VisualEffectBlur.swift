import SwiftUI
import UIKit

// Visual Effect Blur Helper for Glassmorphic effect on iOS
struct VisualEffectBlur: UIViewRepresentable {
    var material: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: material))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: material)
    }
}
