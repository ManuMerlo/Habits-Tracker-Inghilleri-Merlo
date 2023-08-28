import SwiftUI

struct IntroView: View {
    @State private var selectedPage = 0
    @ObservedObject var healthViewModel: HealthViewModel
    @ObservedObject var authenticationViewModel: AuthenticationViewModel
    @ObservedObject var firestoreViewModel: FirestoreViewModel
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    
    //Responsiveness
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var isLandscape: Bool = true
    @State private var device: Device = UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    @State var height = UIScreen.main.bounds.height
    @State var width = UIScreen.main.bounds.width
    
    
    // Constants and Configurations
    enum PageColor {
        static let blue = Color.blue
        static let purple = Color.purple
        static let red = Color.red
    }
    
    enum PageFilename {
        static let notes = "notes"
        static let share = "share"
        static let planActivities = "plan_activities"
        
    }
    
    var body: some View {
        NavigationStack {
            RadialGradient(gradient: Gradient(colors: [Color("delftBlue"), Color("oxfordBlue")]), center: .center, startRadius: 5, endRadius: 500)
                .edgesIgnoringSafeArea(.all)
                .overlay {
                    if orientationInfo.orientation == .landscape {
                        LandscapeView()
                    } else {
                        PortraitView()
                    }
                }
        }
        .foregroundColor(.white)
        .onAppear(){
            isLandscape = orientationInfo.orientation == .landscape
            height =  UIScreen.main.bounds.height
            width = UIScreen.main.bounds.width
        }
        .onChange(of: orientationInfo.orientation) { orientation in
            isLandscape = orientation == .landscape
            height =  UIScreen.main.bounds.height
            width = UIScreen.main.bounds.width
        }
    }
    
    @ViewBuilder
    func PortraitView() -> some View {
        VStack {
            Spacer()
            UpperImage(background: getColorForSelectedPage(selectedPage))
            Spacer()
            TabViewBuilder()
            Spacer()
        }
    }
    
    @ViewBuilder
    func LandscapeView() -> some View {
        HStack {
            Spacer()
            UpperImage(background: getColorForSelectedPage(selectedPage))
            Spacer()
            TabViewBuilder()
            Spacer()
        }.frame(width: width)
    }
    
    @ViewBuilder
    func TabViewBuilder() -> some View {
        VStack(alignment: .center) {
            Spacer()
            
            TabView(selection: $selectedPage)
            {
                DescriptionCard(card: data[selectedPage])
                    .padding()
                    .tag(selectedPage)
                    .frame(height: !isLandscape ? height/2 : width/2)
                    .padding(.horizontal, isLandscape ? 40 : 0)
                    .padding(.vertical, isLandscape ? 40 : 0)
            }
            .onAppear() {
                UIPageControl.appearance().currentPageIndicatorTintColor = .black
                UIPageControl.appearance().pageIndicatorTintColor = .gray
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onReceive(timer) { time in
                selectedPage = (selectedPage + 1) % 3
            }
            
            Spacer()
            
            NavigationLink {
                SigninView(authenticationViewModel: authenticationViewModel, firestoreViewModel: firestoreViewModel)
            } label: {
                Text("Skip")
                    .font(.system(size: 22))
                    .fontWeight(.semibold)
                    .frame(width: 150, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }.frame(height: !isLandscape ? height/3 : width/3)
    }
    
    @ViewBuilder
    func DescriptionCard(card: Card) -> some View {
        VStack(alignment: .center, spacing: 17.0) {
            Text(card.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(card.description)
                .font(.system(size: 24))
                .fontWeight(.light)
                .multilineTextAlignment(.center)
                .frame(width: 300)
        }
    }
    
    @ViewBuilder
    func UpperImage(background : Color) -> some View {
        let fraction = device == .iPad ? 1.5 : 1
        VStack{
            ZStack {
                if device == .iPhone{
                    iPhoneUpperImageLayout(background: background)
                }
                else {
                    iPadUpperImageLayout(background: background)
                }
            }
        }.frame(
            width: !isLandscape ? width/fraction : height/fraction,
            height: !isLandscape ? height/3 : width/3)
    }
    
    @ViewBuilder
    func iPhoneUpperImageLayout(background: Color) -> some View {
        Circle()
            .frame(width:!isLandscape ? height + 50 : width + 50,
                   height: !isLandscape ? height + 50 : width + 50 )
            .foregroundColor(background)
            .offset(y: !isLandscape ? -height/3.5 : 0)
            .offset(x: isLandscape ? -width/3 : 0)
        
        Circle()
            .frame(width: !isLandscape ? height : width,
                   height: !isLandscape ? height : width)
            .foregroundColor(.white)
            .offset(y: !isLandscape ? -height/3.5 : 0)
            .offset(x: isLandscape ? -width/3 : 0)
        
        if selectedPage == 0 {
            
            LottieView(filename: PageFilename.notes)
                .frame(width: !isLandscape ? height/2.5 : width/2.5, height: !isLandscape ? height/2 : width/2.5)
                .shadow(color: .orange, radius: 1, x: 0, y: 0)
                .padding(.trailing, isLandscape ? 120 : 0)
                .padding(.bottom, !isLandscape ? 20 : 0)
        } else if selectedPage == 1 {
            
            LottieView(filename: PageFilename.share)
                .frame(width: !isLandscape ? height/2.5 : width/2.5, height: !isLandscape ? height/2 : width/2.5)
                .shadow(color: .orange, radius: 1, x: 0, y: 0)
                .padding(.trailing, isLandscape ? 120 : 0)
                .padding(.bottom, !isLandscape ? 20 : 0)
            
        } else {
            
            LottieView(filename: PageFilename.planActivities)
                .frame(width: !isLandscape ? height/2.5 : width/2.5, height: !isLandscape ? height/2 : width/2.5)
                .shadow(color: .orange, radius: 1, x: 0, y: 0)
                .padding(.trailing, isLandscape ? 120 : 0)
                .padding(.bottom, !isLandscape ? 20 : 0)
        }
    }
    
    @ViewBuilder
    func iPadUpperImageLayout(background: Color) -> some View {
        Circle()
            .frame(width:!isLandscape ? height + 50 : width + 50,
                   height: !isLandscape ? height + 50 : width + 50 )
            .foregroundColor(background)
            .offset(y: !isLandscape ? -height/4 : 0)
            .offset(x: isLandscape ? -width/4 : 0)
        
        Circle()
            .frame(width: !isLandscape ? height : width,
                   height: !isLandscape ? height : width)
            .foregroundColor(.white)
            .offset(y: !isLandscape ? -height/4 : 0)
            .offset(x: isLandscape ? -width/4 : 0)
        
        if selectedPage == 0 {
            LottieView(filename: PageFilename.notes)
                .frame(width: !isLandscape ? height/2 : width/2.5, height: !isLandscape ? height/2 : width/2.5)
                .shadow(color: .orange, radius: 1, x: 0, y: 0)
                .padding(.bottom, !isLandscape ? 60 : 0)
            
        } else if selectedPage == 1 {
            LottieView(filename: PageFilename.share)
                .frame(width: !isLandscape ? height/2 : width/2.5, height: !isLandscape ? height/2 : width/2.5)
                .shadow(color: .orange, radius: 1, x: 0, y: 0)
                .padding(.bottom, !isLandscape ? 60 : 0)
            
        } else {
            LottieView(filename: PageFilename.planActivities)
                .frame(width: !isLandscape ? height/2 : width/2.5, height: !isLandscape ? height/2 : width/2.5)
                .shadow(color: .orange, radius: 1, x: 0, y: 0)
                .padding(.bottom, !isLandscape ? 60 : 0)
        }
    }
    
    
    // Helper Functions
    func getColorForSelectedPage(_ page: Int) -> Color {
        switch page {
        case 0: return PageColor.blue
        case 1: return PageColor.purple
        case 2: return PageColor.red
        default: return PageColor.blue
        }
    }
    
    func getFilenameForSelectedPage(_ page: Int) -> String {
        switch page {
        case 0: return PageFilename.notes
        case 1: return PageFilename.share
        case 2: return PageFilename.planActivities
        default: return ""
        }
    }
    
}

enum Device {
    case iPhone
    case iPad
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView(healthViewModel: HealthViewModel(), authenticationViewModel: AuthenticationViewModel(), firestoreViewModel: FirestoreViewModel())
            .environmentObject(OrientationInfo())
    }
}
