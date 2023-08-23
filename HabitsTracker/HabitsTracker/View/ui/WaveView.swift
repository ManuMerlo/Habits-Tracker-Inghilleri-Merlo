//
//  WaveView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 11/08/23.
//

import SwiftUI

struct WaveView: View {
    
    var upsideDown: Bool
    var repeatAnimation: Bool = false
    var base : CGFloat
    var amplitude : CGFloat?
    let screen = UIScreen.main.bounds
    
    @State var isAnimated = false
    
    var body: some View {
        GeometryReader { geometry in
                    VStack {
                        if upsideDown {
                            getUpsideDownWavePath(interval: geometry.size.width * 1.8, amplitude: amplitude ?? 130, base: base)
                                .foregroundColor(Color("oxfordBlue"))
                                .shadow(color: .black, radius: 10, x: 0.0, y: 0.0)
                                .offset(x: isAnimated ? -1 * geometry.size.width * 1.8 : 0)
                        } else {
                            getWavePath(interval: geometry.size.width * 1.8, amplitude: 130, base: base)
                                .foregroundColor(Color("oxfordBlue"))
                                .shadow(color: .black, radius: 4, x: 0.0, y: -3)
                                .offset(x: isAnimated ? -1 * geometry.size.width * 1.8 : 0)
                        }
                    }
                    .onAppear() {
                        if repeatAnimation {
                            withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                                self.isAnimated = true
                            }
                        }
                    }
        }.frame(height: 100)
            
    }

    //Wave Function Produces Sine Wave
    func getWavePath(interval: CGFloat, amplitude: CGFloat = 100, base: CGFloat = UIScreen.main.bounds.height/2) -> Path {
        Path {
            path in
            path.move(to: CGPoint(x: 0, y: base))
            path.addCurve(
                to: CGPoint(x: 1*interval , y: base),
                control1: CGPoint(x: interval * (0.35), y: amplitude + base ),
                control2: CGPoint(x: interval * (0.65), y: -amplitude + base)
            )
            path.addCurve(
                to: CGPoint(x: 2*interval , y: base),
                control1: CGPoint(x: interval * (1.35), y: amplitude + base ),
                control2: CGPoint(x: interval * (1.65), y: -amplitude + base)
            )
            path.addLine(to: CGPoint(x: 2*interval, y: 150))
            path.addLine(to: CGPoint(x: 0, y: 150))
            
        }
    }
    
    func getUpsideDownWavePath(interval: CGFloat, amplitude: CGFloat = 100, base: CGFloat = UIScreen.main.bounds.height/2) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: base))
            path.addCurve(
                to: CGPoint(x: 1*interval , y: base),
                control1: CGPoint(x: interval * (0.35), y: -amplitude + base), // Invert the amplitude
                control2: CGPoint(x: interval * (0.65), y: amplitude + base) // Invert the amplitude
            )
            path.addCurve(
                to: CGPoint(x: 2*interval , y: base),
                control1: CGPoint(x: interval * (1.35), y: -amplitude + base), // Invert the amplitude
                control2: CGPoint(x: interval * (1.65), y: amplitude + base) // Invert the amplitude
            )
            path.addLine(to: CGPoint(x: 2*interval, y: 0)) // Change the y-coordinate to 0
            path.addLine(to: CGPoint(x: 0, y: 0)) // Change the y-coordinate to 0
        }
    }

}

struct WaveView_Preview: PreviewProvider {
    static var previews: some View {
        WaveView(upsideDown: false, repeatAnimation: false, base: 100)
    }
}
