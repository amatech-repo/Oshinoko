//
//  HoldAnimationView.swift
//  Oshinoko
//
//  Created by 神山颯太 on 2024/12/07.
//

import SwiftUI
import Lottie

struct HoldAnimationView: UIViewRepresentable {
    var lottieFile : String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 0.8
    
    func makeUIView(context: UIViewRepresentableContext<HoldAnimationView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
            // 表示したいアニメーションのファイル名
            animationView.animation = Animation.named(name)
            // 比率
            animationView.contentMode = .scaleAspectFit
            // ループモード
            animationView.loopMode = loopMode
            animationView.play()
        
            animationView.animationSpeed = speed
        
            animationView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(animationView)
            NSLayoutConstraint.activate([
                animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
                animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
            return view
        }
        func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<HoldAnimationView>) {
        }
}
