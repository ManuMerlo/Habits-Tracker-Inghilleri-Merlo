//
//  ModifyProfileView.swift
//  HabitsTracker
//
//  Created by Manuela Merlo on 06/08/23.
//

import SwiftUI

struct ModifyProfileView: View {
    @ObservedObject var firestoreViewModel : FirestoreViewModel
    @ObservedObject var settingViewModel : SettingsViewModel
    
    @State var modify: Bool = false
    @State var isListEnabled: Bool = true
    
    @State var showSheet: Bool = false
    @State var showDatePicker : Bool = false
    @State var showHeightPicker : Bool = false
    @State var showWeightPicker : Bool = false
    @State var showSexPicker : Bool = false
    
    @State var selectedDate: Date = Date()
    @State var selectedHeight : Int = 150
    @State var selectedWeight : Int = 60
    @State var selectedSex : Sex = Sex.Unspecified
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State private var device : Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State var width = UIScreen.main.bounds.width
    
    var body: some View {
        
        VStack{
            ScrollView{
                VStack(alignment: .center, spacing: 0){
                    ZStack(alignment: .top){
                        WaveView(upsideDown: true,repeatAnimation: false, base: 270, amplitude: 70)
                        
                        VStack{
                            ProfileImageView(
                                path: firestoreViewModel.firestoreUser?.image,
                                systemName: "person.circle.fill",
                                size: 50,
                                color: .gray)
                            .padding(.top, 20)
                            .padding(.bottom,5)
                            
                            Text("\( firestoreViewModel.firestoreUser?.username ?? "User")")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            
                            Text("\( firestoreViewModel.firestoreUser?.email ?? "")")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .accentColor(.white)
                                .padding(.bottom,30)
                        }
                        
                    }
                    
                    List {
                        UserDetailRow(title: "Username", value: firestoreViewModel.firestoreUser?.username ?? "User")
                        UserDetailRow(title: "Birthdate", value: settingViewModel.dateToString(selectedDate), isEnabled: modify, action: toggleDatePicker)
                        UserDetailRow(title: "Sex", value: firestoreViewModel.firestoreUser?.sex?.rawValue ?? "Unspecified", isEnabled: modify, action: toggleSexPicker)
                        UserDetailRow(title: "Height", value: "\(firestoreViewModel.firestoreUser?.height ?? 0) cm", isEnabled: modify, action: toggleHeightPicker)
                        UserDetailRow(title: "Weight", value: "\(firestoreViewModel.firestoreUser?.weight ?? 0) kg", isEnabled: modify, action: toggleWeightPicker)
                        
                    }
                    .frame(width: isLandscape ? width/1.5 : width/1.1, height: 300)
                    .frame(height: nil)
                    .scrollDisabled(true)
                    .padding(.top,50)
                    .disabled(!isListEnabled)
                    .scrollContentBackground(.hidden)
                }
                
                
            }
            
            if showDatePicker {
                VStack() {
                    Button {
                        firestoreViewModel.modifyUser(
                            uid: firestoreViewModel.firestoreUser!.id!,
                            field: "birthdate",
                            value: settingViewModel.dateToString(selectedDate)
                        )
                        
                        showDatePicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        Text("Done")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity) // Makes the button full width
                            .padding(.vertical, 8)
                    }
                    .background(Color("oxfordBlue"))
                    
                    HStack{
                        Spacer()
                        DatePicker(selection: $selectedDate, displayedComponents: .date) {}
                            .colorScheme(.dark)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                        
                        Spacer()
                    }
                }
                .background(Color.clear)
                
            }
            
            if(showSexPicker){
                VStack {
                    Button {
                        firestoreViewModel.modifyUser(
                            uid:  firestoreViewModel.firestoreUser!.id!,
                            field: "sex",
                            value: selectedSex.rawValue)
                        
                        showSexPicker.toggle()
                        isListEnabled.toggle()
                    }label: {
                        Text("Done")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity) // Makes the button full width
                                    .padding(.vertical, 8)
                            }
                            .background(Color("oxfordBlue"))
                    
                    Picker(selection: $selectedSex, label: Text("Select your sex" )) {
                        ForEach(Sex.allCases, id: \.self) { item in
                            Text("\(item.rawValue)")
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                }
                .frame(minHeight: 200)
            }
            
            if (showHeightPicker) {
                PickerView(
                    firestoreViewModel:firestoreViewModel,
                    user: $firestoreViewModel.firestoreUser,
                    property: "height",
                    selectedItem: $selectedHeight,
                    booleanValuePicker: $showHeightPicker,
                    booleanValueList: $isListEnabled,
                    rangeMin: 50,
                    rangeMax: 300,
                    unitaryMeasure: "cm")
            }
            
            if (showWeightPicker){
                PickerView(
                    firestoreViewModel:firestoreViewModel,
                    user: $firestoreViewModel.firestoreUser,
                    property: "weight",
                    selectedItem: $selectedWeight,
                    booleanValuePicker: $showWeightPicker,
                    booleanValueList: $isListEnabled,
                    rangeMin: 30,
                    rangeMax: 180,
                    unitaryMeasure: "kg")
            }
        }
        .accentColor(Color("oxfordBlue"))
        .edgesIgnoringSafeArea(.horizontal)
        .background(RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500).ignoresSafeArea())
        .navigationBarBackButtonHidden(!isListEnabled || modify)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(
            Color("oxfordBlue"),
            for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            Button {
                modify.toggle()
            } label: {
                Text(modify ? "Done" : "Edit")
            }.disabled(!isListEnabled)
            
        }
        .onAppear(){
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .fullScreenCover(isPresented: $showSheet, onDismiss: {
            settingViewModel.persistimageToStorage { result in
                switch result {
                case .success(let path):
                    firestoreViewModel.modifyUser(
                        uid:  firestoreViewModel.firestoreUser!.id!,
                        field: "image",
                        value: path
                    )
                    
                case .failure(let error):
                    print("\(error.localizedDescription)")
                    //TODO: handle message on screen
                }
            }
        }) {
            SettingsViewModel.ImagePicker(selectedImage: $settingViewModel.image)
        }
    }
    
    
    private func toggleDatePicker() {
        showDatePicker.toggle()
        isListEnabled.toggle()
    }
    
    private func toggleSexPicker() {
        showSexPicker.toggle()
        isListEnabled.toggle()
    }
    
    private func toggleHeightPicker() {
        showHeightPicker.toggle()
        isListEnabled.toggle()
    }
    
    private func toggleWeightPicker() {
        showWeightPicker.toggle()
        isListEnabled.toggle()
    }
    
}

struct UserDetailRow: View {
    var title: String
    var value: String
    var isEnabled: Bool = true
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Text(value)
            }
        }
        .disabled(!isEnabled)
        .foregroundColor(isEnabled ? .white : Color("platinum").opacity(0.8))
        .listRowBackground(Color("oxfordBlue"))
        .listRowSeparatorTint(.white.opacity(0.9))
    }
}


struct PickerView: View {
    @State var firestoreViewModel: FirestoreViewModel
    @Binding var user : User?
    var property : String
    @Binding var selectedItem : Int
    @Binding var booleanValuePicker : Bool
    @Binding var booleanValueList : Bool
    var rangeMin : Int
    var rangeMax : Int
    var unitaryMeasure : String
    
    var body: some View{
        VStack(alignment: .center) {
            Button {
                if ( property == "height"){
                    firestoreViewModel.modifyUser(uid: user!.id!, field: "height", value: selectedItem)
                } else {
                    firestoreViewModel.modifyUser(uid: user!.id!, field: "weight", value: selectedItem)
                }
                booleanValuePicker.toggle()
                booleanValueList.toggle()
            }label: {
                Text("Done")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity) // Makes the button full width
                            .padding(.vertical, 8)
                    }
            .background(Color("oxfordBlue"))
            
            Picker(selection: $selectedItem, label: Text("Select your \(property)" )) {
                ForEach(rangeMin..<rangeMax, id: \.self) { number in
                    Text("\(number) \(unitaryMeasure)")
                        .foregroundColor(.white)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }.frame(minHeight: 200)
    }
}


struct ModifyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ModifyProfileView(firestoreViewModel: FirestoreViewModel(), settingViewModel: SettingsViewModel())
            .environmentObject(OrientationInfo())
    }
}
