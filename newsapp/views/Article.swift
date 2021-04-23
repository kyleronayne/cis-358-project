//
//  Article.swift
//  newsapp
//
//  Created by Kyle P. Ronayne on 4/20/21.
//

import Foundation
import SwiftUI

struct Article: View {
    @State var articleUrl: String = ""
    
    func shareArticle() {
        let activityController = UIActivityViewController(activityItems: [articleUrl], applicationActivities: nil)
        
        UIApplication.shared.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
    }
    
    var body: some View {
        ArticleWebView(url: articleUrl)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
//                    LikeButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: shareArticle) {
                        Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.black)
                    }
                }
            }
    }
}
