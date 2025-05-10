//
//  ContentView.swift
//  CineMatchApp
//
//  Created by Brielle on 2025-05-06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Full-screen dark gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.12),
                    Color(red: 0.15, green: 0.1, blue: 0.05)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all) // IMPORTANT

            // TabView layered on top
            TabView {
                RankingView()
                    .tabItem {
                        Label("Rank", systemImage: "slider.horizontal.3")
                    }

                MoodDiscoveryView()
                    .tabItem {
                        Label("Discover", systemImage: "sparkles")
                    }
            }
        }
    }
}


