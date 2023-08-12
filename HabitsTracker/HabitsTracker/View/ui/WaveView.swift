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
    // negative value to reduce the height of the wave
    
    
    let screen = UIScreen.main.bounds
    @State var isAnimated = false
    
    var body: some View {
        VStack {
            if upsideDown {
                getUpsideDownWavePath(interval: screen.width * 1.5, amplitude: amplitude ?? 130, base: base + screen.height / 2)
                    .foregroundColor(Color("oxfordBlue"))
                    .shadow(color: .black, radius: 10, x: 0.0, y: 0.0)
                    .offset(x: isAnimated ? -1 * screen.width * 1.5 : 0)
            } else {
                getWavePath(interval: screen.width * 1.5, amplitude: 130, base: base + screen.height / 2)
                    .foregroundColor(Color("oxfordBlue"))
                    .shadow(color: .black, radius: 10, x: 0.0, y: 0.0)
                    .offset(x: isAnimated ? -1 * screen.width * 1.5 : 0)
            }
        }
        .onAppear() {
            if repeatAnimation { // Replace with your boolean condition
                withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                    self.isAnimated = true
                }
            } else {
                withAnimation(Animation.linear(duration: 2)){
                    self.isAnimated = true
                }
            }
        }
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
            path.addLine(to: CGPoint(x: 2*interval, y: screen.height))
            path.addLine(to: CGPoint(x: 0, y: screen.height))
            
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
        WaveView(upsideDown: true, base: -200)
    }
}
