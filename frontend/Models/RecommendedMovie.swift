//
//  RecommendedMovie.swift
//  CineMatchApp
//
//  Created by Brielle on 2025-05-08.
//

import Foundation

struct RecommendedMovie: Identifiable, Decodable {
    let id: Int
    let title: String
    let score: Double
    let reason: String
}
