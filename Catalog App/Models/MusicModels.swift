//
//  MusicModels.swift
//  Catalog App
//
//  Created by DURGESH TIWARI on 10/29/25.
//

import Foundation

// MARK: - Artist Model
struct Artist: Codable, Identifiable {
    let id: String
    let name: String
    let bio: String
    let imageURL: String
    let genre: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, bio, genre, country
        case imageURL = "image_url"
    }
}

// MARK: - Album Model
struct Album: Codable, Identifiable {
    let id: String
    let title: String
    let artistId: String
    let artistName: String
    let description: String
    let price: Double
    let imageURL: String
    let genre: String
    let releaseDate: String
    let rating: Double
    let reviewCount: Int
    let duration: String
    let trackCount: Int
    let isPopular: Bool
    let songs: [Song]
    let reviews: [Review]
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, price, genre, rating, duration, songs, reviews
        case artistId = "artist_id"
        case artistName = "artist_name"
        case imageURL = "image_url"
        case releaseDate = "release_date"
        case reviewCount = "review_count"
        case trackCount = "track_count"
        case isPopular = "is_popular"
    }
}

// MARK: - Song Model
struct Song: Codable, Identifiable {
    let id: String
    let title: String
    let duration: String
    let trackNumber: Int
    let previewURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, duration
        case trackNumber = "track_number"
        case previewURL = "preview_url"
    }
}

// MARK: - Review Model
struct Review: Codable, Identifiable {
    let id: String
    let userName: String
    let rating: Int
    let comment: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case id, rating, comment, date
        case userName = "user_name"
    }
}

// MARK: - Filter Options
enum SortOption: String, CaseIterable {
    case newest = "Newest"
    case priceAscending = "Price: Low to High"
    case priceDescending = "Price: High to Low"
    case mostPopular = "Most Popular"
    case rating = "Highest Rated"
    case alphabetical = "A-Z"
}

enum GenreFilter: String, CaseIterable {
    case all = "All"
    case rock = "Rock"
    case pop = "Pop"
    case jazz = "Jazz"
    case classical = "Classical"
    case electronic = "Electronic"
    case hiphop = "Hip-Hop"
    case country = "Country"
    case blues = "Blues"
}

// MARK: - Search and Filter State
struct FilterState {
    var searchText: String = ""
    var selectedGenre: GenreFilter = .all
    var priceRange: ClosedRange<Double> = 0...100
    var minimumRating: Double = 0
    var sortOption: SortOption = .newest
    var showOnlyPopular: Bool = false
}