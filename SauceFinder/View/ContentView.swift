//
//  ContentView.swift
//  SauceFinder
//
//  Created by Caleb Wheeler on 11/30/20.
//

import SwiftUI
import RealmSwift
import MLKit



enum sheetPicker:Identifiable{
    var id: Int{
        hashValue
    }
    
    case addDoujin
    case imagePick
    case imageSauce
}

struct ContentView: View {
    
    @ObservedObject var doujin = DoujinAPI()
    @StateObject var viewRouter = ViewRouter()
    var sauceAPI = SauceNaoAPI()
    
    @State var showing:Bool = false
    
    @State var sheetPicker: sheetPicker? = .none
    @State private var InputImage: UIImage?
    @State var changeSheet = false
    
    var body: some View {
        GeometryReader {geo in
            
            ZStack {
                switch viewRouter.currentPage {
                case .sauce:
                    DoujinView()
                        .padding(.bottom, 50)
                case .hentai:
                    Text("HentaiView my guy")
                }
                
                if doujin.loadingCirclePresent == true{
                    LoadingCircle(Degrees: 0.0, TheAPI: doujin)
                }
                
                VStack {
                    
                    Spacer()
                    
                    //Where we actually code the tab bar into play
                    HStack{
                        TabBarIcon(currentPage: $viewRouter.currentPage, width: 30, height: 30, systemIconName: "book", tabName: "Sauce", assignedPage: .sauce)
                            .padding(.trailing, 10)
                            .offset(y:-10)
                        
                        TabBarCircle(length: 50, showingViews: $showing, sheetPicker: $sheetPicker )
                            .offset(y: -40)
                        
                        TabBarIcon(currentPage: $viewRouter.currentPage, width: 30, height: 30, systemIconName: "plus", tabName: "Hentai", assignedPage: .hentai)
                            .padding(.leading, 10)
                            .offset(y:-10)
                    }
                    .padding(.bottom, 10)
                    .frame(width: geo.size.width, height: geo.size.height/8)
                    .background(Color("TabBarColor").shadow(radius:2))
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                
                .sheet(item: $sheetPicker){item in
                    switch item{
                    
                    case .addDoujin:
                        AddSauceView(DoujinApi: doujin, isPresented: $showing, changeSheet: $changeSheet)
                            //                        AnotherAddDoujin(DoujinApi: doujin, isPresented: $showing, changeSheet: $changeSheet)
                            .onDisappear(perform: {
                                sheet()
                            })
                        
                    case .imagePick:
                        ImagePicker(image: self.$InputImage)
                            .onDisappear(perform: {
                                LoadImage()
                            })
                        
                    case .imageSauce:
                        //                        Text("Swag")
                        ImagePicker(image: self.$InputImage)
                            .onDisappear(perform: {
                                textRecog()
                            })
                        
                    }
                }
            }
        }
    }
    func LoadImage(){
        guard let InputImage = InputImage else {return}
        
        print("yeth")
        print(convertImageToBase64(InputImage))
        
        
        
        self.InputImage = nil
    }
    
    
    func sheet(){
        if changeSheet == true{
            sheetPicker = .imageSauce
        }
    }
    func convertImageToBase64(_ image: UIImage) {
        let imageData:NSData = image.jpegData(compressionQuality: 0.4)! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        print("Damn")
        sauceAPI.FindDoujin(imageString: strBase64)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
extension ContentView {
    func textRecog(){
        guard let InputImage = InputImage else {return}
        
        let image = VisionImage(image: InputImage)
        var sauceFound = [String]()
        
        let textRecognizer = TextRecognizer.textRecognizer()
        textRecognizer.process(image){ result, error in
            guard error == nil, let result = result else{
                print("error: \(String(describing: error))")
                return
            }
            
            for block in result.blocks{
                for line in block.lines{
                    for element in line.elements{
                        let elementText = element.text
                        if (Int(elementText) != nil) {
                            print(elementText)
                            sauceFound.append(elementText)
                        }
                    }
                }
            }
            print("running")
            
            
            doujin.bookInfo(Sauces: sauceFound)
            changeSheet = false
        }
        
        
    }
}


struct TabBarIcon: View {
    @Binding var currentPage: Page
    
    let width, height: CGFloat
    let systemIconName, tabName: String
    
    let assignedPage: Page
    
    var body: some View {
        
        Button(action: {
            currentPage = assignedPage
        }) {
            VStack{
                Image(systemName: systemIconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .padding(.top, 10)
                    .foregroundColor(Color("TabNames"))
                
                
                Text(tabName)
                    .font(.footnote)
                    .foregroundColor(Color("TabNames"))
            }
        }
    }
}
