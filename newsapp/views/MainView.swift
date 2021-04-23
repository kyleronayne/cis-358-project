//
//  MainView.swift
//  newsapp
//
//  Created by AJ Natzic on 3/22/21.
//

import SwiftUI


struct MainView: View {
    @State private var showingAlert = false
    @State private var darkMode = false
    @State private var accentColor = Color.black
    
    var categories: [String] = ["World", "US", "Politics", "Health", "Business", "Sports", "Entertainment"]
    
    var body: some View {
        TabView {
            NavigationView {
                List {
                    ForEach(categories, id: \.self) { key in
                        ArticlesRow(category: key)
                    }
                }
                .navigationTitle("Headlines")
            }
            .navigationBarHidden(true)
            .tabItem {
                Image(systemName: "antenna.radiowaves.left.and.right")
                Text("News")
            }
            
            
            Text("Favorites")
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .navigationBarHidden(true)
            NavigationView {
                Form {
                    Section(header: Text("View Settings")) {
                        Toggle("Dark Mode", isOn: $darkMode)
                            .onChange(of: darkMode, perform: { value in
                                setupColorScheme()
                            })
                        ColorPicker("Accent color", selection: $accentColor, supportsOpacity: false)
                            .onChange(of: accentColor, perform: { value in
                                setupColorScheme()
                            })
                    }
                    
                    Section {
                        Button("Remove all favorites"){
                            showingAlert = true
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Are you sure you want to delete all favorites?"),
                                message: Text("These cannot be recovered."),
                                primaryButton: .destructive(Text("Delete")) {
                                    print("Deleting...")
                                    // TODO: Method that deletes all favorites
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .navigationBarTitle(Text("Settings"))
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .navigationBarHidden(true)
        }
        
    }
    
    private func setupColorScheme() {
        let window = UIApplication.shared.windows.first
        if(darkMode) {
            window?.overrideUserInterfaceStyle = .dark
            window?.tintColor = UIColor(.white)
        }
        else {
            window?.overrideUserInterfaceStyle = .light
            window?.tintColor = UIColor(.black)
        }
    }
}
