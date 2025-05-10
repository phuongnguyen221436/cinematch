//
//  Movies.swift
//  CineMatchApp
//
//  Created by Brielle on 2025-05-07.
//

import Foundation

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String?
    let vote_average: Double
    let release_date: String?
}

