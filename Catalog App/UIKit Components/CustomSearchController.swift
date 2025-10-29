//
//  CustomSearchController.swift
//  Catalog App
//
//  Created by DURGESH TIWARI on 10/29/25.
//

import UIKit
import SwiftUI

// MARK: - UIKit Search Controller
class CustomSearchController: UISearchController {
    var onSearchTextChanged: ((String) -> Void)?
    var onSearchButtonClicked: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
    }
    
    private func setupSearchController() {
        searchResultsUpdater = self
        delegate = self
        searchBar.delegate = self
        
        // Customize appearance
        searchBar.placeholder = "Search albums, artists, genres..."
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .systemBlue
        
        // Configure search behavior
        obscuresBackgroundDuringPresentation = false
        hidesNavigationBarDuringPresentation = false
    }
}

// MARK: - Search Results Updating
extension CustomSearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        onSearchTextChanged?(searchText)
    }
}

// MARK: - Search Controller Delegate
extension CustomSearchController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        // Handle search controller presentation
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        // Handle search controller dismissal
    }
}

// MARK: - Search Bar Delegate
extension CustomSearchController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        onSearchButtonClicked?(searchText)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        onSearchTextChanged?("")
    }
}

// MARK: - SwiftUI Wrapper
struct UIKitSearchBar: UIViewControllerRepresentable {
    @Binding var searchText: String
    var onSearchButtonClicked: ((String) -> Void)?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let searchController = CustomSearchController()
        
        searchController.onSearchTextChanged = { text in
            DispatchQueue.main.async {
                self.searchText = text
            }
        }
        
        searchController.onSearchButtonClicked = { text in
            self.onSearchButtonClicked?(text)
        }
        
        viewController.navigationItem.searchController = searchController
        viewController.navigationItem.hidesSearchBarWhenScrolling = false
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let searchController = uiViewController.navigationItem.searchController {
            if searchController.searchBar.text != searchText {
                searchController.searchBar.text = searchText
            }
        }
    }
}

// MARK: - Advanced Filter UIKit Component
class AdvancedFilterViewController: UIViewController {
    var filterState: FilterState
    var onFilterChanged: ((FilterState) -> Void)?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    // Filter Controls
    private let genreSegmentedControl = UISegmentedControl()
    private let priceRangeSlider = UISlider()
    private let ratingSlider = UISlider()
    private let popularSwitch = UISwitch()
    
    init(filterState: FilterState) {
        self.filterState = filterState
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureControls()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Advanced Filters"
        
        // Setup navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        
        // Add filter sections
        addGenreSection()
        addPriceSection()
        addRatingSection()
        addPopularSection()
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func addGenreSection() {
        let sectionView = createSectionView(title: "Genre")
        
        // Configure segmented control
        let genres = ["All", "Rock", "Pop", "Jazz", "Electronic"]
        for (index, genre) in genres.enumerated() {
            genreSegmentedControl.insertSegment(withTitle: genre, at: index, animated: false)
        }
        genreSegmentedControl.selectedSegmentIndex = 0
        genreSegmentedControl.addTarget(self, action: #selector(genreChanged), for: .valueChanged)
        
        sectionView.addArrangedSubview(genreSegmentedControl)
        stackView.addArrangedSubview(sectionView)
    }
    
    private func addPriceSection() {
        let sectionView = createSectionView(title: "Price Range: $0 - $50")
        
        priceRangeSlider.minimumValue = 0
        priceRangeSlider.maximumValue = 50
        priceRangeSlider.value = 25
        priceRangeSlider.addTarget(self, action: #selector(priceChanged), for: .valueChanged)
        
        sectionView.addArrangedSubview(priceRangeSlider)
        stackView.addArrangedSubview(sectionView)
    }
    
    private func addRatingSection() {
        let sectionView = createSectionView(title: "Minimum Rating: 0 stars")
        
        ratingSlider.minimumValue = 0
        ratingSlider.maximumValue = 5
        ratingSlider.value = 0
        ratingSlider.addTarget(self, action: #selector(ratingChanged), for: .valueChanged)
        
        sectionView.addArrangedSubview(ratingSlider)
        stackView.addArrangedSubview(sectionView)
    }
    
    private func addPopularSection() {
        let sectionView = createSectionView(title: "Show Only Popular Albums")
        
        popularSwitch.addTarget(self, action: #selector(popularChanged), for: .valueChanged)
        
        let switchContainer = UIView()
        switchContainer.addSubview(popularSwitch)
        popularSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popularSwitch.leadingAnchor.constraint(equalTo: switchContainer.leadingAnchor),
            popularSwitch.centerYAnchor.constraint(equalTo: switchContainer.centerYAnchor),
            switchContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        sectionView.addArrangedSubview(switchContainer)
        stackView.addArrangedSubview(sectionView)
    }
    
    private func createSectionView(title: String) -> UIStackView {
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        
        sectionStack.addArrangedSubview(titleLabel)
        return sectionStack
    }
    
    private func configureControls() {
        // Set initial values based on filter state
        // This would be implemented based on the current filter state
    }
    
    @objc private func genreChanged() {
        // Update filter state based on selected genre
    }
    
    @objc private func priceChanged() {
        // Update price range in filter state
        if let titleLabel = stackView.arrangedSubviews[1].subviews.first as? UILabel {
            titleLabel.text = "Price Range: $0 - $\(Int(priceRangeSlider.value))"
        }
    }
    
    @objc private func ratingChanged() {
        // Update minimum rating in filter state
        if let titleLabel = stackView.arrangedSubviews[2].subviews.first as? UILabel {
            titleLabel.text = "Minimum Rating: \(Int(ratingSlider.value)) stars"
        }
    }
    
    @objc private func popularChanged() {
        // Update popular filter in filter state
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        onFilterChanged?(filterState)
        dismiss(animated: true)
    }
}

// MARK: - SwiftUI Wrapper for Advanced Filter
struct AdvancedFilterView: UIViewControllerRepresentable {
    let filterState: FilterState
    let onFilterChanged: (FilterState) -> Void
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let filterVC = AdvancedFilterViewController(filterState: filterState)
        filterVC.onFilterChanged = onFilterChanged
        return UINavigationController(rootViewController: filterVC)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Update if needed
    }
}