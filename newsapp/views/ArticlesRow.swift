//
//  ArticlesRow.swift
//  newsapp
//
//  Created by AJ Natzic on 4/3/21.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI

struct ArticlesRow: View {
    var category: String
    var isFavorites: Bool
    @StateObject var articleRetriever = ArticleRetriever()
    @State var likeButton: LikeButton?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(category.uppercased())
                .font(.headline)
                .padding(.top, 5)
            if(isFavorites == true) {
                ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 25) {
                            ForEach(articleRetriever.response) {favorites in
                                NavigationLink(destination: Article(articleUrl: favorites.articleUrl)) {
                                    ArticlePreview(articleTitle: favorites.articleTitle, articleImage: favorites.articleImage)
                                }
                                LikeButton(articleLiked: favorites, articleRetriever: articleRetriever)
    //                                .padding(.bottom, 30)
                                
                            }
                        }
                        .onAppear {
                            articleRetriever.get(category: category.lowercased(), type: "favorites")
                        }
                }
                .frame(height: 275)
            }
            else {
                ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 25) {
                            ForEach(articleRetriever.response) {response in
                                
                                NavigationLink(destination: Article(articleUrl: response.articleUrl)) {
                                    ArticlePreview(articleTitle: response.articleTitle, articleImage: response.articleImage)
                                }
                                LikeButton(articleLiked: response, articleRetriever: articleRetriever)
    //                                .padding(.bottom, 30)
                                
                            }
                        }
                        .onAppear {
                            articleRetriever.get(category: category.lowercased(), type: "notfavorites")
                        }
                }
                .frame(height: 275)
            }
            
        }
    }
}

struct ResponseStructure: Identifiable {
    var id: String
    var articleTitle: String
    var articleUrl: String
    var articleImage: String
    var isFavorite: Bool
}

class ArticleRetriever: ObservableObject {
    @Published var response = [ResponseStructure]()
    @Published var favorites = [ResponseStructure]()
    
    func addFavorite(article: ResponseStructure) {
        self.favorites.append(article)
    }
    
    func removeFavorite(article: ResponseStructure) {
        self.favorites.remove(at: self.favorites.firstIndex(where: {$0.articleUrl == article.articleUrl}) ?? -1)
    }
    
    private var apiKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "BingNews-Info", ofType: "plist") else {
                fatalError("Couldn't find file 'BingNews-Info.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "API_KEY") as? String else {
                fatalError("Couldn't find key 'API_KEY' in BingNews-Info.plist'.")
            }
            return value
        }
    }
    
    func get(category: String, type: String) {
        let source = "https://bing-news-search1.p.rapidapi.com/news?textFormat=Raw&safeSearch=Moderate&category=\(category)"
        let url = URL(string: source)
        var request = URLRequest(url: url!)
        request.setValue("true", forHTTPHeaderField: "x-bingapis-sdk")
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("bing-news-search1.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            
            let json = try! JSON(data: data!)
            for dataType in json["value"] {
                let articleId = dataType.1["datePublished"].stringValue
                let articleUrl = dataType.1["url"].stringValue
                let articleImage = dataType.1["image"]["thumbnail"]["contentUrl"].stringValue
                let articleTitle = dataType.1["name"].stringValue
                DispatchQueue.main.async {
                    if(type == "favorites") {
                        print("FAVORITES SHOULD PRINT HERE", self.favorites)
//                        if(self.favorites.contains(where: {$0.articleUrl == articleUrl})) {
//                            self.response.append(ResponseStructure(id: articleId, articleTitle: articleTitle, articleUrl: articleUrl, articleImage: articleImage, isFavorite: false))
//                        }
                    }
                    else {
                        self.response.append(ResponseStructure(id: articleId, articleTitle: articleTitle, articleUrl: articleUrl, articleImage: articleImage, isFavorite: false))
                    }
                    
                    
                }
            
                    
            }
        }.resume()

//
//            let json = try! JSON(data: data!)
//            for dataType in json {
//                print(dataType)
//                let title = dataType.1["title"].stringValue
//                let content = dataType.1["content"].stringValue
//                let url = dataType.1["url"].stringValue
//                var image = dataType.1["urlToImage"].stringValue
//                if (dataType.1["urlToImage"].stringValue.isEmpty){
//                    image  = //"https://static.thenounproject.com/png/58934-200.png"
//                }
//                let id = dataType.1["publishedAt"].stringValue
//                DispatchQueue.main.async {
//                    self.response.append(ResponseStructure(id: id, title: title, content: content, url: url, image: image))
//                }
//            }
//        }.resume()
    }
    
}
