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
        VStack {
            VStack(spacing: 0) {
                
                Button{
                    showSheet.toggle()
                }label:{
                    VStack {
                        ProfileImageView(
                            path: firestoreViewModel.firestoreUser?.image,
                            systemName: "person.circle.fill",
                            size: 90,
                            color: .gray)
                        
                        Text("Change photo")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                    
                }.padding(5)
                
                Text("Customise your profile")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Spacer() // Spazio vuoto sopra per spingere il contenuto in alto
                
                List {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text("\( firestoreViewModel.firestoreUser?.username ?? "User")")
                    }
                    
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
                        .foregroundColor(!modify ? .gray: .black)
                    
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
                        .foregroundColor(!modify ? .gray: .black)
                    
                    
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
                        .foregroundColor(!modify ? .gray: .black)
                    
                    
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
                        .foregroundColor(!modify ? .gray: .black)
                    
                }
                
            }.disabled(!isListEnabled)
            
            Spacer()
            
            if showDatePicker {
                VStack {
                    Button {
                        firestoreViewModel.modifyUser(
                            uid:  firestoreViewModel.firestoreUser!.id!,
                            field: "birthdate",
                            value: settingViewModel.dateToString(selectedDate),
                            type: "String")
                        
                        showDatePicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        Text("Done")
                    }
                    DatePicker(selection: $selectedDate, displayedComponents: .date) {}
                        .datePickerStyle(WheelDatePickerStyle())
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.8))
            }
            
            if(showSexPicker){
                VStack {
                    Button {
                        firestoreViewModel.modifyUser(
                            uid:  firestoreViewModel.firestoreUser!.id!,
                            field: "sex",
                            value: selectedSex.rawValue,
                            type: "String")
                        
                        showSexPicker.toggle()
                        isListEnabled.toggle()
                    }label: {
                        Text("Done")
                    }
                    Picker(selection: $selectedSex, label: Text("Select your sex" )) {
                        ForEach(Sex.allCases, id: \.self) { item in
                            Text("\(item.rawValue)")
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
        .navigationBarBackButtonHidden(!isListEnabled || modify)
        .toolbar {
            Button {
                //if(modify){
                //    firestoreViewModel.addNewUser(user: authenticationViewModel.user!)
                //}
                modify.toggle()
            } label: {
                Text(modify ? "Done" : "Modify")
            }.disabled(!isListEnabled)
            
        }
        .fullScreenCover(isPresented: $showSheet, onDismiss: {
            settingViewModel.persistimageToStorage { result in
                switch result {
                case .success(let path):
                    firestoreViewModel.modifyUser(
                        uid:  firestoreViewModel.firestoreUser!.id!,
                        field: "image",
                        value: path,
                        type:"String")
                    
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
