//
//  MusicCatalogView.swift
//  Catalog App
//
//  Created by DURGESH TIWARI on 10/29/25.
//

import SwiftUI

struct MusicCatalogView: View {
    @StateObject private var viewModel = MusicCatalogViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBarView(searchText: $viewModel.filterState.searchText)
                    .padding(.horizontal)
                
                // Filter and Sort Controls
                FilterControlsView(
                    viewModel: viewModel,
                    showingFilters: $showingFilters
                )
                .padding(.horizontal)
                
                // Content
                if viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        viewModel.loadData()
                    }
                } else {
                    if viewModel.isGridView {
                        AlbumGridView(albums: viewModel.filteredAlbums)
                    } else {
                        AlbumListView(albums: viewModel.filteredAlbums)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Music Catalog")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.toggleViewMode) {
                        Image(systemName: viewModel.isGridView ? "list.bullet" : "square.grid.2x2")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheetView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Search Bar View
struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search albums, artists, genres...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Filter Controls View
struct FilterControlsView: View {
    @ObservedObject var viewModel: MusicCatalogViewModel
    @Binding var showingFilters: Bool
    
    var body: some View {
        HStack {
            // Quick Genre Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GenreFilter.allCases.prefix(5), id: \.self) { genre in
                        Button(action: {
                            viewModel.updateGenreFilter(genre)
                        }) {
                            Text(genre.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    viewModel.filterState.selectedGenre == genre ?
                                    Color.blue : Color.gray.opacity(0.2)
                                )
                                .foregroundColor(
                                    viewModel.filterState.selectedGenre == genre ?
                                    .white : .primary
                                )
                                .cornerRadius(15)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            Spacer()
            
            // More Filters Button
            Button(action: { showingFilters = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                    Text("Filters")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Album Grid View
struct AlbumGridView: View {
    let albums: [Album]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(albums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        AlbumGridCardView(album: album)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

// MARK: - Album List View
struct AlbumListView: View {
    let albums: [Album]
    
    var body: some View {
        List(albums) { album in
            NavigationLink(destination: AlbumDetailView(album: album)) {
                AlbumListRowView(album: album)
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Album Grid Card View
struct AlbumGridCardView: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Album Cover
            AsyncImage(url: URL(string: album.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(8)
            
            // Album Info
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", album.rating))
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", album.price))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Album List Row View
struct AlbumListRowView: View {
    let album: Album
    
    var body: some View {
        HStack(spacing: 12) {
            // Album Cover
            AsyncImage(url: URL(string: album.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 60)
            .clipped()
            .cornerRadius(8)
            
            // Album Info
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(album.genre)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", album.rating))
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(String(format: "%.2f", album.price))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                if album.isPopular {
                    Text("Popular")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading music catalog...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retry) {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MusicCatalogView()
}