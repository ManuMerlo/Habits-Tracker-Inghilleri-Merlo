import SwiftUI

struct ModifyProfileView: View {
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    @State var modify: Bool = false
    @State var isListEnabled: Bool = true
    
    @State var showSheet: Bool = false
    @State var showDatePicker: Bool = false
    @State var showHeightPicker: Bool = false
    @State var showWeightPicker: Bool = false
    @State var showSexPicker: Bool = false
    
    @State var selectedDate: Date = Date()
    @State var selectedHeight: Int = 150
    @State var selectedWeight: Int = 60
    @State var selectedSex: Sex = Sex.Unspecified
    
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
                            Text(settingsViewModel.dateToString(selectedDate))
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
                            Text("\((selectedSex).rawValue )")
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
                            Text("\(selectedHeight)")
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
                            Text("\(selectedWeight)")
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
                                uid: firestoreViewModel.firestoreUser!.id,
                                field: "birthDate",
                                value: settingsViewModel.dateToString(selectedDate))
                            //firestoreViewModel.firestoreUser?.birthDate = settingsViewModel.dateToString(selectedDate)
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
                
                if(showSexPicker) {
                    VStack {
                        Button {
                            firestoreViewModel.modifyUser(
                                uid: firestoreViewModel.firestoreUser!.id,
                                field: "sex",
                                value: selectedSex.rawValue)
                            //firestoreViewModel.firestoreUser?.sex = selectedSex
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
                    PickerView(
                        firestoreViewModel:firestoreViewModel,
                        userId: firestoreViewModel.firestoreUser!.id, // FIXME: firestoreUser!
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
                        userId: firestoreViewModel.firestoreUser!.id,
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
            
        }.onAppear() {
            // TODO: check if there is a better way for this and for the picker (inconsistencies)
            selectedDate = settingsViewModel.stringToDate((firestoreViewModel.firestoreUser?.birthDate)) ?? Date()
            selectedHeight = firestoreViewModel.firestoreUser?.height ?? 150
            selectedWeight = firestoreViewModel.firestoreUser?.weight ?? 60
            selectedSex = firestoreViewModel.firestoreUser?.sex ?? Sex.Unspecified
        }
        .foregroundColor(.white)
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
                settingsViewModel.persistimageToStorage { result in
                    switch result {
                    case .success(let path):
                        firestoreViewModel.modifyUser(
                            uid:  firestoreViewModel.firestoreUser!.id,
                            field: "image",
                            value: path
                        )
                        //firestoreViewModel.firestoreUser?.image = path
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                        //TODO: handle message on screen
                    }
                }
            }) {
                SettingsViewModel.ImagePicker(selectedImage: $settingsViewModel.image)
            }
            .onAppear() {
                
            }
    }
}

struct PickerView: View {
    @State var firestoreViewModel: FirestoreViewModel
    var userId: String
    var property: String
    @Binding var selectedItem: Int
    @Binding var booleanValuePicker: Bool
    @Binding var booleanValueList: Bool
    var rangeMin: Int
    var rangeMax: Int
    var unitaryMeasure: String
    
    var body: some View{
        VStack {
            Button {
                if (property == "height"){
                    firestoreViewModel.modifyUser(uid: userId, field: "height", value: selectedItem)
                    //firestoreViewModel.firestoreUser?.height = selectedItem
                } else {
                    firestoreViewModel.modifyUser(uid: userId, field: "weight", value: selectedItem)
                    //firestoreViewModel.firestoreUser?.weight = selectedItem

                }
                booleanValuePicker.toggle()
                booleanValueList.toggle()
            }label: {
                Text("Done")
            }
            
            Picker(selection: $selectedItem, label: Text("Select your \(property)" )) {
                ForEach(rangeMin..<rangeMax, id: \.self) { number in
                    Text("\(number) \(unitaryMeasure)")
                        .foregroundColor(.white)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }
    }
}

struct ModifyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ModifyProfileView(firestoreViewModel: FirestoreViewModel(), settingsViewModel: SettingsViewModel())
    }
}
