//
//  MusicCatalogViewModel.swift
//  Catalog App
//
//  Created by DURGESH TIWARI on 10/29/25.
//

import Foundation
import Combine

@MainActor
class MusicCatalogViewModel: ObservableObject {
    @Published var albums: [Album] = []
    @Published var artists: [Artist] = []
    @Published var filteredAlbums: [Album] = []
    @Published var filterState = FilterState()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isGridView = true
    @Published var favoriteAlbumIds: Set<String> = []
    
    // Offline caching
    private let userDefaults = UserDefaults.standard
    private let albumsCacheKey = "cached_albums"
    private let artistsCacheKey = "cached_artists"
    private let favoritesKey = "favorite_albums"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupFilterObservers()
        loadFavorites()
        loadData()
    }
    
    // MARK: - Data Loading
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Try to load from cache first
                if let cachedAlbums = loadFromCache() {
                    self.albums = cachedAlbums.albums
                    self.artists = cachedAlbums.artists
                    self.applyFilters()
                } else {
                    // Load from JSON files
                    try await loadFromJSON()
                }
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to load music catalog: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func loadFromJSON() async throws {
        guard let albumsURL = Bundle.main.url(forResource: "albums", withExtension: "json"),
              let artistsURL = Bundle.main.url(forResource: "artists", withExtension: "json") else {
            throw NSError(domain: "FileNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "JSON files not found"])
        }
        
        let albumsData = try Data(contentsOf: albumsURL)
        let artistsData = try Data(contentsOf: artistsURL)
        
        let decoder = JSONDecoder()
        let loadedAlbums = try decoder.decode([Album].self, from: albumsData)
        let loadedArtists = try decoder.decode([Artist].self, from: artistsData)
        
        self.albums = loadedAlbums
        self.artists = loadedArtists
        
        // Cache the data
        saveToCache(albums: loadedAlbums, artists: loadedArtists)
        
        applyFilters()
    }
    
    // MARK: - Caching
    private func saveToCache(albums: [Album], artists: [Artist]) {
        let encoder = JSONEncoder()
        do {
            let albumsData = try encoder.encode(albums)
            let artistsData = try encoder.encode(artists)
            userDefaults.set(albumsData, forKey: albumsCacheKey)
            userDefaults.set(artistsData, forKey: artistsCacheKey)
        } catch {
            print("Failed to cache data: \(error)")
        }
    }
    
    private func loadFromCache() -> (albums: [Album], artists: [Artist])? {
        guard let albumsData = userDefaults.data(forKey: albumsCacheKey),
              let artistsData = userDefaults.data(forKey: artistsCacheKey) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            let albums = try decoder.decode([Album].self, from: albumsData)
            let artists = try decoder.decode([Artist].self, from: artistsData)
            return (albums, artists)
        } catch {
            print("Failed to load from cache: \(error)")
            return nil
        }
    }
    
    // MARK: - Filter Setup
    private func setupFilterObservers() {
        // Observe changes to filter state and apply filters automatically
        $filterState
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Filtering and Sorting
    func applyFilters() {
        var filtered = albums
        
        // Search filter
        if !filterState.searchText.isEmpty {
            filtered = filtered.filter { album in
                album.title.localizedCaseInsensitiveContains(filterState.searchText) ||
                album.artistName.localizedCaseInsensitiveContains(filterState.searchText) ||
                album.genre.localizedCaseInsensitiveContains(filterState.searchText)
            }
        }
        
        // Genre filter
        if filterState.selectedGenre != .all {
            filtered = filtered.filter { $0.genre.lowercased() == filterState.selectedGenre.rawValue.lowercased() }
        }
        
        // Price range filter
        filtered = filtered.filter { filterState.priceRange.contains($0.price) }
        
        // Rating filter
        filtered = filtered.filter { $0.rating >= filterState.minimumRating }
        
        // Popular filter
        if filterState.showOnlyPopular {
            filtered = filtered.filter { $0.isPopular }
        }
        
        // Apply sorting
        filtered = sortAlbums(filtered, by: filterState.sortOption)
        
        filteredAlbums = filtered
    }
    
    private func sortAlbums(_ albums: [Album], by sortOption: SortOption) -> [Album] {
        switch sortOption {
        case .newest:
            return albums.sorted { $0.releaseDate > $1.releaseDate }
        case .priceAscending:
            return albums.sorted { $0.price < $1.price }
        case .priceDescending:
            return albums.sorted { $0.price > $1.price }
        case .mostPopular:
            return albums.sorted { album1, album2 in
                if album1.isPopular && !album2.isPopular { return true }
                if !album1.isPopular && album2.isPopular { return false }
                return album1.reviewCount > album2.reviewCount
            }
        case .rating:
            return albums.sorted { $0.rating > $1.rating }
        case .alphabetical:
            return albums.sorted { $0.title < $1.title }
        }
    }
    
    // MARK: - Public Methods
    func updateSearchText(_ text: String) {
        filterState.searchText = text
    }
    
    func updateGenreFilter(_ genre: GenreFilter) {
        filterState.selectedGenre = genre
    }
    
    func updatePriceRange(_ range: ClosedRange<Double>) {
        filterState.priceRange = range
    }
    
    func updateMinimumRating(_ rating: Double) {
        filterState.minimumRating = rating
    }
    
    func updateSortOption(_ option: SortOption) {
        filterState.sortOption = option
    }
    
    func togglePopularFilter() {
        filterState.showOnlyPopular.toggle()
    }
    
    func toggleViewMode() {
        isGridView.toggle()
    }
    
    func clearFilters() {
        filterState = FilterState()
    }
    
    func getArtist(by id: String) -> Artist? {
        return artists.first { $0.id == id }
    }
    
    func getRelatedAlbums(for album: Album, limit: Int = 4) -> [Album] {
        return albums
            .filter { $0.id != album.id && ($0.genre == album.genre || $0.artistId == album.artistId) }
            .prefix(limit)
            .map { $0 }
    }
    
    func refreshData() {
        // Clear cache and reload
        userDefaults.removeObject(forKey: albumsCacheKey)
        userDefaults.removeObject(forKey: artistsCacheKey)
        loadData()
    }
    
    // MARK: - Favorites Management
    func toggleFavorite(albumId: String) {
        if favoriteAlbumIds.contains(albumId) {
            favoriteAlbumIds.remove(albumId)
        } else {
            favoriteAlbumIds.insert(albumId)
        }
        saveFavorites()
    }
    
    func isFavorite(albumId: String) -> Bool {
        return favoriteAlbumIds.contains(albumId)
    }
    
    private func saveFavorites() {
        let favoritesArray = Array(favoriteAlbumIds)
        userDefaults.set(favoritesArray, forKey: favoritesKey)
    }
    
    private func loadFavorites() {
        if let savedFavorites = userDefaults.array(forKey: favoritesKey) as? [String] {
            favoriteAlbumIds = Set(savedFavorites)
        }
    }
}