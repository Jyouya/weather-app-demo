//
//  WeatherViewController.swift
//  Weather App
//
//  Created by William West on 8/20/24.
//

import Foundation
import UIKit
import Combine

class WeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    

    private var viewModel: WeatherViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var cityLabelSubscriber: AnyCancellable?
    private var forecast = [Date: [WeatherEntry]]()
    private var dates = [Date]()
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    private let currentWeatherView = CurrentWeatherView()
    // setup forecast view
    private let forecastView: UITableView = {
        let tableView = UITableView()
        tableView.register(ForecastCell.self, forCellReuseIdentifier: "ForecastCell")
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    private let forecastGradient = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 118.0/255.0, green: 215.0/255.0, blue: 196.0/255.0, alpha: 1.0)
        setupView()
        forecastView.dataSource = self
        forecastView.delegate = self
        viewModel = WeatherViewModel()
        bindViewModel()
        
        registerForTraitChanges([UITraitVerticalSizeClass.self, UITraitHorizontalSizeClass.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
            
            self.updateLayout(for: self.traitCollection)
        }
    }
            
    func bindViewModel() {
        // subscribe to weather changes from view model
        viewModel.weatherPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main) // so we can do UI work
            .sink(receiveValue: { [weak self] weatherEntries in
                // TODO: Guards should display error if weather data cannot be bound
                let dates = Array(weatherEntries.keys).sorted()
                
                guard let date = dates.first else { return }
                
                guard let currentWeather = weatherEntries[date]?.first else { return }
                
                self?.dates = dates
 
                self?.currentWeatherView.configure(for: currentWeather)
                
                self?.forecast = weatherEntries
                self?.forecastView.reloadData()
            })
            .store(in: &cancellables)
        
        // subscribe to city info from viewmodel
        cityLabelSubscriber = viewModel.cityPublisher
            .receive(on:DispatchQueue.main)
            .assign(to: \.title, on: self)
    }
    
    @objc private func searchButtonTapped() {
        let searchController = SearchViewController(locationAvailable: viewModel.locationAvailable, completion: viewModel.handleSearch)
        
        navigationController?.pushViewController(searchController, animated: true)
    }
    
    func setupView() {
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        searchButton.tintColor = .label
        navigationItem.leftBarButtonItem = searchButton
        
        view.addSubview(currentWeatherView)
        view.addSubview(forecastView)
        
        forecastView.contentInset = .zero
            
        forecastView.translatesAutoresizingMaskIntoConstraints = false
        currentWeatherView.translatesAutoresizingMaskIntoConstraints = false
        
        forecastView.backgroundColor = .white.withAlphaComponent(0.1)
        
        // Setup constraints common between size classes
        NSLayoutConstraint.activate([
            currentWeatherView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            currentWeatherView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            forecastView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            forecastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        
        portraitConstraints = [
            forecastView.topAnchor.constraint(equalTo: currentWeatherView.bottomAnchor, constant: 16),
            forecastView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
        ]
        
        landscapeConstraints = [
            forecastView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            forecastView.leadingAnchor.constraint(equalTo: currentWeatherView.trailingAnchor, constant: 16)
        ]
        
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
    
    func updateLayout(for traitCollection: UITraitCollection) {
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        }
        
        view.layoutIfNeeded()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = dates[section]
        return forecast[date]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastCell
        
        let date = dates[indexPath.section]
        if let entry = forecast[date]?[indexPath.row] {
            cell.configure(with: entry)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = dates[section]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
}

