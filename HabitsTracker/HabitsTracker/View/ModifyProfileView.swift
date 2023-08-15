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
    
    var body: some View {

        VStack{
            
            ZStack{
                
                WaveView(upsideDown: true,repeatAnimation: false, base: -140, amplitude: 70)
                    .edgesIgnoringSafeArea(.top)
                
                VStack{
                    Button{
                        showSheet.toggle()
                    }label:{
                        VStack {
                            ProfileImageView(
                                path: firestoreViewModel.firestoreUser?.image,
                                systemName: "person.circle.fill",
                                size: 90,
                                color: Color("platinum").opacity(0.8))
                            
                            Text("Change photo")
                                .font(.body)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 20)
                        }
                        
                    }.padding(5)
                    
                    Text("Customise your profile")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                }.frame(height: UIScreen.main.bounds.height*0.2)
                
            }.padding(.bottom)
            
            VStack{
                
                List {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text("\( firestoreViewModel.firestoreUser?.username ?? "User")")
                    } .listRowBackground(Color("oxfordBlue"))
                        .listRowSeparatorTint(.white.opacity(0.9))
                        .foregroundColor(.white)
                    Button {
                        showDatePicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        HStack {
                            Text("Birthdate")
                            Spacer()
                            Text(settingViewModel.dateToString(selectedDate))
                        }
                    }.disabled(!modify)
                        .foregroundColor(!modify ? Color("platinum").opacity(0.8): .white)
                        .listRowBackground(Color("oxfordBlue"))
                        .listRowSeparatorTint(.white.opacity(0.9))
                    
                    Button {
                        showSexPicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        HStack {
                            Text("Sex")
                            Spacer()
                            Text("\((firestoreViewModel.firestoreUser?.sex ?? Sex.Unspecified).rawValue )")
                        }
                    }.disabled(!modify)
                        .foregroundColor(!modify ? Color("platinum").opacity(0.8): .white)
                        .listRowBackground(Color("oxfordBlue"))
                        .listRowSeparatorTint(.white.opacity(0.9))
                    
                    
                    Button {
                        showHeightPicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        HStack {
                            Text("Height")
                            Spacer()
                            Text("\( firestoreViewModel.firestoreUser?.height ?? 0 )")
                        }
                    }.disabled(!modify)
                        .foregroundColor(!modify ? Color("platinum").opacity(0.8): .white)
                        .listRowBackground(Color("oxfordBlue"))
                        .listRowSeparatorTint(.white.opacity(0.9))
                    
                    
                    Button {
                        showWeightPicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        HStack {
                            Text("Weight")
                            Spacer()
                            Text("\( firestoreViewModel.firestoreUser?.weight ?? 0 )")
                        }
                    }.disabled(!modify)
                        .foregroundColor(!modify ? Color("platinum").opacity(0.8): .white)
                        .listRowBackground(Color("oxfordBlue"))
                        .listRowSeparatorTint(.white.opacity(0.9))
                    
                }
                .padding(.top,30)
                .disabled(!isListEnabled)
                .scrollContentBackground(.hidden)
                
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
                                .padding(.vertical, 8)
                        }
                        
                        HStack{
                            Spacer()
                            DatePicker(selection: $selectedDate, displayedComponents: .date) {}
                                .colorScheme(.dark)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                            
                            Spacer()
                            }
                    }
                    .background(Color("oxfordBlue"))

                    
                    
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
                        }
                        Picker(selection: $selectedSex, label: Text("Select your sex" )) {
                            ForEach(Sex.allCases, id: \.self) { item in
                                Text("\(item.rawValue)")
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                    }
                }
                
                if (showHeightPicker) {
                    SettingsViewModel.PickerView(
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
                    SettingsViewModel.PickerView(
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
            .frame(height: UIScreen.main.bounds.height*0.65)
            
        }.foregroundColor(.white)
            .background(RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500).ignoresSafeArea())
            
            .navigationBarBackButtonHidden(!isListEnabled || modify)
            .toolbar {
                Button {
                    modify.toggle()
                } label: {
                    Text(modify ? "Done" : "Edit")
                }.disabled(!isListEnabled)
                
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
}

struct ModifyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ModifyProfileView(firestoreViewModel: FirestoreViewModel(), settingViewModel: SettingsViewModel())
    }
}
