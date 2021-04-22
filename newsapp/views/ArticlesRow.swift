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
                            NavigationLink(destination: Article(articleUrl: response.url)) {
                                ArticlePreview(articleTitle: response.title, articleImage: response.image).accentColor(Color.black)
                    
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
    var title: String
    var content: String
    var url: String
    var image: String
}

class ArticleRetriever: ObservableObject {
    @Published var response = [ResponseStructure]()
    
    func get(category: String) {
        let source = "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&apiKey=2965253d7ca64c63a58435403b289f9b"
        let url = URL(string: source)!
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { (data, _,err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            let json = try! JSON(data: data!)
            for dataType in json["articles"] {
                let title = dataType.1["title"].stringValue
                let content = dataType.1["content"].stringValue
                let url = dataType.1["url"].stringValue
                var image = dataType.1["urlToImage"].stringValue
                if (dataType.1["urlToImage"].stringValue.isEmpty){
                    image  = "https://static.thenounproject.com/png/58934-200.png"
                }
                let id = dataType.1["publishedAt"].stringValue
                DispatchQueue.main.async {
                    self.response.append(ResponseStructure(id: id, title: title, content: content, url: url, image: image))
                }
            }
        }.resume()
    }
}
