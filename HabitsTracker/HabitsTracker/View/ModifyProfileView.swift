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
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = false
    @State private var device : Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State var width = UIScreen.main.bounds.width
    
    var body: some View {
        
        VStack(spacing: 15){
            ScrollView{
                VStack(alignment: .center, spacing: 15){
                    ZStack(alignment: .top){
                        
                        WaveView(upsideDown: true,repeatAnimation: false, base: 250, amplitude: 70)
                        
                        VStack{
                            
                            Button{
                                showSheet.toggle()
                            } label: {
                                VStack(spacing: 10){
                                    ProfileImageView(
                                        path: firestoreViewModel.firestoreUser?.image,
                                        systemName: "person.circle.fill",
                                        size: 90,
                                        color: .gray)
                                    Text("Change photo")
                                        .foregroundColor(.blue)
                                }
                            }.padding(.bottom,1)
                            
                            
                            Text("\( firestoreViewModel.firestoreUser?.username ?? "User")")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            
                            Text("\( firestoreViewModel.firestoreUser?.email ?? "")")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .accentColor(.white)
                            
                        }.padding(.top,15)
                    }
                    
                    List {
                        UserDetailRow(title: "Username", value: firestoreViewModel.firestoreUser?.username ?? "User")
                        UserDetailRow(title: "Birthdate", value: settingsViewModel.dateToString(selectedDate), isEnabled: modify, action: toggleDatePicker)
                        UserDetailRow(title: "Sex", value: selectedSex.rawValue, isEnabled: modify, action: toggleSexPicker)
                        UserDetailRow(title: "Height", value: "\(selectedHeight) cm", isEnabled: modify, action: toggleHeightPicker)
                        UserDetailRow(title: "Weight", value: "\(selectedWeight) kg", isEnabled: modify, action: toggleWeightPicker)
                        
                    }
                    .frame(width: isLandscape ? width/1.5 : width/1.1, height: 300)
                    .frame(height: nil)
                    .scrollDisabled(true)
                    .padding(.top,20)
                    .disabled(!isListEnabled)
                    .scrollContentBackground(.hidden)
                }
                
                
            }
            .accessibilityIdentifier("ModifyProfileScrollView")
            
            if showDatePicker {
                VStack(alignment:.center){
                    Button {
                        firestoreViewModel.modifyUser(
                            uid: firestoreViewModel.firestoreUser!.id,
                            field: "birthDate",
                            value: settingsViewModel.dateToString(selectedDate)
                        )
                        
                        showDatePicker.toggle()
                        isListEnabled.toggle()
                    } label: {
                        Text("Done")
                            .foregroundColor(.white)
                            .padding(.vertical,10)
                            .frame(maxWidth: .infinity) // Makes the button full width
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
                VStack(alignment:.center){
                    Button {
                        firestoreViewModel.modifyUser(
                            uid:  firestoreViewModel.firestoreUser!.id,
                            field: "sex",
                            value: selectedSex.rawValue)
                        
                        showSexPicker.toggle()
                        isListEnabled.toggle()
                    }label: {
                        Text("Done")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
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
                    userId: firestoreViewModel.firestoreUser!.id,
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
            selectedDate = settingsViewModel.stringToDate((firestoreViewModel.firestoreUser?.birthDate)) ?? Date()
            selectedHeight = firestoreViewModel.firestoreUser?.height ?? 150
            selectedWeight = firestoreViewModel.firestoreUser?.weight ?? 60
            selectedSex = firestoreViewModel.firestoreUser?.sex ?? Sex.Unspecified
            
            isLandscape = orientationInfo.orientation == .landscape
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            width = UIScreen.main.bounds.width
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
                    
                case .failure(let error):
                    print("\(error.localizedDescription)")
                    //TODO: handle message on screen
                }
            }
        }) {
            ImagePicker(selectedImage: $settingsViewModel.image)
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
        .accessibilityIdentifier(title)
        .disabled(!isEnabled)
        .foregroundColor(isEnabled ? .white : Color("platinum").opacity(0.8))
        .listRowBackground(Color("oxfordBlue"))
        .listRowSeparatorTint(.white.opacity(0.9))
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
        VStack(alignment: .center) {
            Button {
                if ( property == "height"){
                    firestoreViewModel.modifyUser(uid: userId, field: "height", value: selectedItem)
                } else {
                    firestoreViewModel.modifyUser(uid: userId, field: "weight", value: selectedItem)
                }
                booleanValuePicker.toggle()
                booleanValueList.toggle()
            }label: {
                Text("Done")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity) // Makes the button full width
                            .padding(.vertical, 10)
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

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
    }
}

struct ModifyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ModifyProfileView(firestoreViewModel: FirestoreViewModel(), settingsViewModel: SettingsViewModel())
            .environmentObject(OrientationInfo())
    }
}
