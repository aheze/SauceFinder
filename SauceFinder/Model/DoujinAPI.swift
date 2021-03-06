//
//  DoujinAPI.swift
//  SauceFinder
//
//  Created by Caleb Wheeler on 12/1/20.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON
import RealmSwift
import SwiftUI


class DoujinAPI:ObservableObject {
    //Similar to @state, vars taht will help update views
    @Published var removing:Bool = false
    @Published var loadingCircle:Bool = false
    @Published var progress:String = ""
    
    @Published var showAlert:Bool = false
    @Published var activeAlert:ActiveAlert? = .none
    
    //The Doujin model
    var doujinModel = DoujinInfoViewModel()
    //Function that gets all the detils of the doujin
    func bookInfo(Sauces: [String]) {
        var theCount = 0
        
        progress = "\(theCount)/\(Sauces.count)"

        
        let headers: HTTPHeaders = [.accept("application/json")]
        
        for SauceNum in Sauces {
            sleep(2)
            AF.request("https://nhentai.net/api/gallery/\(SauceNum)", method: .get, headers: headers).responseJSON { response in
                print("Working")
                
                if let Data = response.data {
                        let json = try! JSON(data: Data)
                    
                    let NewDoujin = DoujinInfo()
                    
                    guard let Name = json["title"]["pretty"].string else {self.showAlert.toggle();self.activeAlert = .error;return}
                    guard let Pages = json["num_pages"].int else {self.showAlert.toggle();self.activeAlert = .error;return}
                    guard let MediaID = json["media_id"].string else {self.showAlert.toggle();self.activeAlert = .error;return}
                    
                    
                    var count = 0
                    let TagJson = json["tags"]
                    
                    for _ in TagJson {
                        let TheTags = DoujinTags()
                        TheTags.Name = json["tags"][count]["name"].string!
                        NewDoujin.Tags.append(TheTags)
                        count += 1
                    }
                    self.getPitcture(Media: MediaID) { [self](newstring) in
                        NewDoujin.Name = Name
                        NewDoujin.Id = SauceNum
                        print(SauceNum)
                        NewDoujin.MediaID = MediaID
                        NewDoujin.NumPages = Pages
                        NewDoujin.PictureString = newstring
                        NewDoujin.UniqueID = UUID().uuidString
                        NewDoujin.similarity = 100
                        
                        self.doujinModel.addDoujin(theDoujin: NewDoujin)
                        theCount += 1
                        self.progress = "\(theCount)/\(Sauces.count)"

                    }
                }
            }
        }
        sleep(1)
    }
    
    func bookInfoWithName(with theName: String,the similarity: String){
//        DoujinAPI.loadingCirclePresent = true
        let headers: HTTPHeaders = [.accept("application/json")]
        progress = "0/1"

        sleep(2)

        AF.request("https://nhentai.net/api/galleries/search?query=\(theName)&page=PAGE=1&sort=SORT=recent", method: .get, headers: headers).responseJSON {response in
            if let Data = response.data{
                let json = try! JSON(data: Data)
                
                let NewDoujin = DoujinInfo()
                
                guard let Name = json["result"][0]["title"]["pretty"].string else {self.showAlert.toggle();self.activeAlert = .error;return}
                guard let Pages = json["result"][0]["num_pages"].int else {self.showAlert.toggle();self.activeAlert = .error;return}
                guard let MediaID = json["result"][0]["media_id"].string else {self.showAlert.toggle();self.activeAlert = .error;return}
                guard let SauceNum = json["result"][0]["id"].int else {self.showAlert.toggle();self.activeAlert = .error;return}
                
                
                var count = 0
                let TagJson = json["result"][0]["tags"]
                
                for _ in TagJson {
                    let TheTags = DoujinTags()
                    TheTags.Name = json["result"][0]["tags"][count]["name"].string!
                    NewDoujin.Tags.append(TheTags)
                    count += 1
                }
                self.getPitcture(Media: MediaID) {(newstring) in
                    NewDoujin.Name = Name
                    NewDoujin.Id = "\(SauceNum)"
                    NewDoujin.MediaID = MediaID
                    NewDoujin.NumPages = Pages
                    NewDoujin.PictureString = newstring
                    NewDoujin.UniqueID = UUID().uuidString
                    NewDoujin.similarity = Double(similarity)!
                    
                    self.doujinModel.addDoujin(theDoujin: NewDoujin)
                    self.progress = "1çççç/1"

                    print("Saved")
                }
            }
        }
        sleep(1)
    }
}

