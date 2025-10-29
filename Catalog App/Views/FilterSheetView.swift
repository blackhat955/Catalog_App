//
//  FilterSheetView.swift
//  Catalog App
//
//  Created by DURGESH TIWARI on 10/29/25.
//

import SwiftUI

struct FilterSheetView: View {
    @ObservedObject var viewModel: MusicCatalogViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempFilterState: FilterState
    
    init(viewModel: MusicCatalogViewModel) {
        self.viewModel = viewModel
        self._tempFilterState = State(initialValue: viewModel.filterState)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Genre Section
                Section("Genre") {
                    Picker("Genre", selection: $tempFilterState.selectedGenre) {
                        ForEach(GenreFilter.allCases, id: \.self) { genre in
                            Text(genre.rawValue).tag(genre)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Price Range Section
                Section("Price Range") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("$\(String(format: "%.0f", tempFilterState.priceRange.lowerBound))")
                            Spacer()
                            Text("$\(String(format: "%.0f", tempFilterState.priceRange.upperBound))")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        RangeSlider(
                            range: $tempFilterState.priceRange,
                            bounds: 0...50,
                            step: 1
                        )
                    }
                }
                
                // Rating Section
                Section("Minimum Rating") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(tempFilterState.minimumRating) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        tempFilterState.minimumRating = Double(star)
                                    }
                            }
                            Spacer()
                            Text("\(String(format: "%.0f", tempFilterState.minimumRating))+ stars")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $tempFilterState.minimumRating,
                            in: 0...5,
                            step: 1
                        )
                    }
                }
                
                // Sort Options Section
                Section("Sort By") {
                    Picker("Sort Option", selection: $tempFilterState.sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Additional Filters Section
                Section("Additional Filters") {
                    Toggle("Show Only Popular Albums", isOn: $tempFilterState.showOnlyPopular)
                }
                
                // Actions Section
                Section {
                    Button("Clear All Filters") {
                        tempFilterState = FilterState()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        viewModel.filterState = tempFilterState
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Range Slider Component
struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let lowerPercent = (range.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
            let upperPercent = (range.upperBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
            
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                // Active track
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: width * (upperPercent - lowerPercent), height: 4)
                    .offset(x: width * lowerPercent)
                
                // Lower thumb
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .offset(x: width * lowerPercent - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newPercent = max(0, min(1, (value.location.x) / width))
                                let newValue = bounds.lowerBound + newPercent * (bounds.upperBound - bounds.lowerBound)
                                let steppedValue = round(newValue / step) * step
                                let clampedValue = max(bounds.lowerBound, min(range.upperBound - step, steppedValue))
                                range = clampedValue...range.upperBound
                            }
                    )
                
                // Upper thumb
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .offset(x: width * upperPercent - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newPercent = max(0, min(1, (value.location.x) / width))
                                let newValue = bounds.lowerBound + newPercent * (bounds.upperBound - bounds.lowerBound)
                                let steppedValue = round(newValue / step) * step
                                let clampedValue = max(range.lowerBound + step, min(bounds.upperBound, steppedValue))
                                range = range.lowerBound...clampedValue
                            }
                    )
            }
        }
        .frame(height: 20)
    }
}

#Preview {
    FilterSheetView(viewModel: MusicCatalogViewModel())
}