//
//  CineMatchAppApp.swift
//  CineMatchApp
//
//  Created by Brielle on 2025-05-06.
//

import SwiftUI

@main
struct CineMatchApp: App {
    init() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.black
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }

        // --- Navigation bar styling ---
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = .clear // Full transparency
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.clear]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

