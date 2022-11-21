//
//  PlanningView.swift
//  HabitsTracker
//
//  Created by Riccardo Inghilleri on 21/11/22.
//

import SwiftUI

struct PlanningView: View {
    @State var currentDate: Date = Date()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                //Custom Data Picker
                CustomDataPicker(currentDate: $currentDate)
            }
            .padding(.vertical)
        }
        // Safe Area View
        /*.safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    
                } label: {
                    Text("Add Activity")
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange, in: Capsule())
                }
                Button {
                    
                } label: {
                    Text("Add Reminder")
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color.purple, in: Capsule())
                }

            }
            .padding(.horizontal)
            .padding(.top, 10)
            .foregroundColor(.white)
            .background(.ultraThinMaterial)
        }*/
    }
}

struct PlanningView_Previews: PreviewProvider {
    static var previews: some View {
        PlanningView()
    }
}
