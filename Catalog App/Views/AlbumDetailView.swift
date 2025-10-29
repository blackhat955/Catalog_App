//
//  AlbumDetailView.swift
//  Catalog App
//
//  Created by DURGESH TIWARI on 10/29/25.
//

import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @StateObject private var viewModel = MusicCatalogViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                AlbumHeaderView(album: album)
                
                // Tab Selection
                TabSelectionView(selectedTab: $selectedTab)
                
                // Tab Content
                Group {
                    switch selectedTab {
                    case 0:
                        AlbumInfoView(album: album)
                    case 1:
                        TrackListView(songs: album.songs)
                    case 2:
                        ReviewsView(reviews: album.reviews)
                    default:
                        AlbumInfoView(album: album)
                    }
                }
                
                // Related Albums Section
                RelatedAlbumsView(
                    relatedAlbums: viewModel.getRelatedAlbums(for: album)
                )
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.toggleFavorite(albumId: album.id)
                }) {
                    Image(systemName: viewModel.isFavorite(albumId: album.id) ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite(albumId: album.id) ? .red : .primary)
                }
            }
        }
    }
}

// MARK: - Album Header View
struct AlbumHeaderView: View {
    let album: Album
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
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
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            // Album Info
            VStack(alignment: .leading, spacing: 8) {
                Text(album.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Text(album.artistName)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text(album.genre)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                
                HStack {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= Int(album.rating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                        Text(String(format: "%.1f", album.rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("(\(album.reviewCount) reviews)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("$\(String(format: "%.2f", album.price))")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                if album.isPopular {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Popular")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Tab Selection View
struct TabSelectionView: View {
    @Binding var selectedTab: Int
    
    private let tabs = ["Info", "Tracks", "Reviews"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Text(tabs[index])
                            .font(.subheadline)
                            .fontWeight(selectedTab == index ? .semibold : .regular)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                }
                .foregroundColor(selectedTab == index ? .blue : .secondary)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Album Info View
struct AlbumInfoView: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About This Album")
                .font(.headline)
            
            Text(album.description)
                .font(.body)
                .lineSpacing(4)
            
            HStack {
                InfoItemView(title: "Release Date", value: formatDate(album.releaseDate))
                Spacer()
                InfoItemView(title: "Duration", value: album.duration)
            }
            
            HStack {
                InfoItemView(title: "Tracks", value: "\(album.trackCount)")
                Spacer()
                InfoItemView(title: "Genre", value: album.genre)
            }
        }
        .padding(.top)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Info Item View
struct InfoItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Track List View
struct TrackListView: View {
    let songs: [Song]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Track Listing")
                .font(.headline)
            
            ForEach(songs) { song in
                TrackRowView(song: song)
            }
        }
        .padding(.top)
    }
}

// MARK: - Track Row View
struct TrackRowView: View {
    let song: Song
    
    var body: some View {
        HStack {
            Text("\(song.trackNumber)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Text(song.duration)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: {
                // Play preview functionality
            }) {
                Image(systemName: "play.circle")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Reviews View
struct ReviewsView: View {
    let reviews: [Review]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reviews")
                .font(.headline)
            
            if reviews.isEmpty {
                Text("No reviews yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(reviews) { review in
                    ReviewRowView(review: review)
                }
            }
        }
        .padding(.top)
    }
}

// MARK: - Review Row View
struct ReviewRowView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.userName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Text(formatReviewDate(review.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(review.comment)
                .font(.body)
                .lineSpacing(2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatReviewDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Related Albums View
struct RelatedAlbumsView: View {
    let relatedAlbums: [Album]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("You Might Also Like")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(relatedAlbums) { album in
                        NavigationLink(destination: AlbumDetailView(album: album)) {
                            RelatedAlbumCardView(album: album)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.top)
    }
}

// MARK: - Related Album Card View
struct RelatedAlbumCardView: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            .frame(width: 120, height: 120)
            .clipped()
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(album.artistName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text("$\(String(format: "%.2f", album.price))")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 120)
    }
}

#Preview {
    NavigationView {
        AlbumDetailView(album: Album(
            id: "1",
            title: "Sample Album",
            artistId: "1",
            artistName: "Sample Artist",
            description: "A sample album description",
            price: 9.99,
            imageURL: "https://picsum.photos/300/300",
            genre: "Rock",
            releaseDate: "2024-01-01",
            rating: 4.5,
            reviewCount: 100,
            duration: "45:30",
            trackCount: 10,
            isPopular: true,
            songs: [],
            reviews: []
        ))
    }
}