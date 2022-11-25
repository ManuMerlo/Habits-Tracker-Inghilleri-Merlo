//
//  LottieView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 25/11/22.
//

import Foundation
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
typealias UIViewType = UIView
var filename : String

func makeUIView(context:
    UIViewRepresentableContext<LottieView>)-> UIView {
         let view = UIView(frame: .zero)
         let animationView = LottieAnimationView()
         let animation = Animation.named (filename)
         animationView.animation = animation
         animationView.contentMode =  .scaleAspectFit
         animationView.play()
         animationView.play(fromProgress: 0, //Start
                            toProgress: 1, //End
                            loopMode: LottieLoopMode.repeat(15),//Number of Times
                            completion: { finished in
                             if finished {
                                 print("Animation Complete")
                               } else {
                              print("Animation cancelled")
                              }
                           })
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([animationView.widthAnchor.constraint(equalTo:view.widthAnchor),
        animationView.heightAnchor.constraint(equalTo:view.heightAnchor)])

        return view
      }

    func updateUIView( _ uiView: UIView, context:
    UIViewRepresentableContext<LottieView>){
            }
      }

