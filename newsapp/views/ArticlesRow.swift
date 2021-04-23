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
    @StateObject var articleRetriever = ArticleRetriever()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(category.uppercased())
                .font(.headline)
                .padding(.top, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 25) {
                        ForEach(articleRetriever.response) {response in
                            NavigationLink(destination: Article(articleUrl: response.articleUrl)) {
                                ArticlePreview(articleTitle: response.articleTitle, articleImage: response.articleImage)
                    
                            }
                        }
                    }
                    .onAppear {
                        articleRetriever.get(category: category.lowercased())
                    }
            }
            .frame(height: 275)
        }
    }
}

struct ResponseStructure: Identifiable {
    var id: String
    var articleTitle: String
    var articleUrl: String
    var articleImage: String
}

class ArticleRetriever: ObservableObject {
    @Published var response = [ResponseStructure]()
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
    
    func get(category: String) {
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
                    self.response.append(ResponseStructure(id: articleId, articleTitle: articleTitle, articleUrl: articleUrl, articleImage: articleImage))
                    
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
