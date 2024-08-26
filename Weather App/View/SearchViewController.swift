//
//  SearchViewController.swift
//  Weather App
//
//  Created by William West on 8/22/24.
//

import Foundation
import UIKit
import Combine

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var viewModel: SearchViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var searchResults: [Location] = []
    
    private var noResults = false
    
    let searchLabel = UILabel()
    let searchBar = UITextField()
    let searchButton = UIButton()
    let useLocationButton = UIButton()
    
    let searchResultsView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    init(locationAvailable: Bool, completion: @escaping (SearchViewResult) -> Void) {
        super.init(nibName: nil, bundle: nil)
        viewModel = SearchViewModel(locationAvailable: locationAvailable, completion: completion)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 118.0/255.0, green: 196.0/255.0, blue: 215.0/255.0, alpha: 1.0)
        setupView()
        searchResultsView.dataSource = self
        searchResultsView.delegate = self
        
        bindViewModel()
    }
    
    // Draw an underline on the text input.  Not a scalable solution, should subclass UITextField if you need more than one.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(
            x: 0,
            y: searchBar.frame.size.height - 1,
            width: searchBar.frame.size.width,
            height: 1)
        bottomLine.backgroundColor = UIColor.label.cgColor
        searchBar.borderStyle = .none
        searchBar.layer.addSublayer(bottomLine)
    }
    
    func bindViewModel() {
        viewModel.searchResultsPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] searchResults in
                if searchResults.count == 0 {
                    self?.noResults = true
                } else {
                    self?.noResults = false
                }
                
                self?.searchResults = searchResults
                self?.searchResultsView.reloadData()
            })
            .store(in: &cancellables)
    }
    
    @objc private func searchButtonTapped() {
        guard let query = searchBar.text else { return }
        viewModel.search(query: query)
    }
    
    @objc private func useLocationButtonTapped() {
        navigationController?.popViewController(animated: true)
        self.viewModel.useLocation()
    }
    
    func setupView() {
        title = "Search"
        
        // Ideally, we'd capture the done button for the text field as well, since it's a single field form
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        useLocationButton.addTarget(self, action: #selector(useLocationButtonTapped), for: .touchUpInside)
        
        if (viewModel.locationAvailable) {
            view.addSubview(useLocationButton)
//            useLocationButton.setTitle("Use Current Location", for: .normal)
            useLocationButton.tintColor = UIColor(red: 80.0/255.0, green: 140.0/255.0, blue: 180.0/255.0, alpha: 0.5)
            useLocationButton.layer.cornerRadius = 5
            var buttonConfiguration = UIButton.Configuration.filled()
            
            buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 7.0, bottom: 5.0, trailing: 7.0)
            buttonConfiguration.title = "Use Current Location"
            buttonConfiguration.baseForegroundColor = .label
            
            useLocationButton.configuration = buttonConfiguration
            
            useLocationButton.titleLabel?.font = useLocationButton.titleLabel?.font.withSize(16)
            useLocationButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: useLocationButton, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 12).isActive = true
            NSLayoutConstraint(item: useLocationButton, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 12).isActive = true
        }
        
        view.addSubview(searchLabel)
        searchLabel.text = "Search by city, region, or zipcode"
        searchLabel.font = searchLabel.font.withSize(16)
        searchLabel.translatesAutoresizingMaskIntoConstraints = false

        if (viewModel.locationAvailable) {
            NSLayoutConstraint(item: searchLabel, attribute: .top, relatedBy: .equal, toItem: useLocationButton, attribute: .bottom, multiplier: 1, constant: 16).isActive = true
        } else {
            NSLayoutConstraint(item: searchLabel, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 12).isActive = true
        }
        NSLayoutConstraint(item: searchLabel, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 12).isActive = true
        
        view.addSubview(searchBar)
        searchBar.font = searchBar.font?.withSize(16)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.accessibilityLabel = "Search by city, region, or zipcode"
        NSLayoutConstraint(item: searchBar, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 12).isActive = true
        NSLayoutConstraint(item: searchBar, attribute: .top, relatedBy: .equal, toItem: searchLabel, attribute: .bottom, multiplier: 1, constant: 12).isActive = true
        
        view.addSubview(searchButton)
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .label
        searchButton.accessibilityLabel = "Search"
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: searchButton, attribute: .left, relatedBy: .equal, toItem: searchBar, attribute: .right, multiplier: 1, constant: 12).isActive = true
        NSLayoutConstraint(item: searchButton, attribute: .top, relatedBy: .equal, toItem: searchBar, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: searchButton, attribute: .right, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: -12).isActive = true
        NSLayoutConstraint(item: searchButton, attribute: .height, relatedBy: .equal, toItem: searchBar, attribute: .height, multiplier: 1, constant: 0).isActive = true
        
        // Give the remaining vertical space to the table view
        view.addSubview(searchResultsView)
        searchResultsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: searchResultsView, attribute: .top, relatedBy: .equal, toItem: searchBar, attribute: .bottom, multiplier: 1, constant: 16).isActive = true
        NSLayoutConstraint(item: searchResultsView, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 12).isActive = true
        NSLayoutConstraint(item: searchResultsView, attribute: .right, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: -12).isActive = true
        NSLayoutConstraint(item: searchResultsView, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -12).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noResults {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        cell.backgroundColor = UIColor(red: 90.0/255.0, green: 160.0/255.0, blue: 200.0/255.0, alpha: 0.5)
        
        if (!noResults) {
            let location = searchResults[indexPath.item]
            config.text = location.name
            
            let country = Locale.current.localizedString(forRegionCode: location.country)
            
            var secondaryText: String?
            if let state = location.state {
                secondaryText = "\(state), \(country ?? "")"
            } else {
                secondaryText = country
            }
            
            config.secondaryText = secondaryText
        } else {
            config.text = "No results"
        }
        
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if noResults {
            return;
        }
        navigationController?.popViewController(animated: true)
        viewModel.choose(location: searchResults[indexPath.item])
    }
}
