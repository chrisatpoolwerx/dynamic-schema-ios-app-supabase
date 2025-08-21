//
//  DynamicSchemaApp.swift
//  DynamicSchemaApp
//
//  Created on iOS Dynamic Schema Project
//

import SwiftUI

@main
struct DynamicSchemaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            CaptureView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Capture")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
