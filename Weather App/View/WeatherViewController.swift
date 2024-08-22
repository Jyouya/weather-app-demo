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
    
    let temperatureLabel = UILabel()
    let descriptionLabel = UILabel()
    let feelsLikeLabel = UILabel()
    let icon = UIImageView()
    
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
                
                // Only show F/C for current temp, user probably will infer that the rest of the units are the same
                self?.temperatureLabel.text = formatTemperature(K: currentWeather.main.temp, showUnit: true)
                self?.descriptionLabel.text = currentWeather.weather.first?.description.localizedCapitalized
                
                let low = formatTemperature(K: currentWeather.main.tempMin)
                let high = formatTemperature(K: currentWeather.main.tempMax)
                
                self?.feelsLikeLabel.text = "\(high) / \(low) Feels like \(formatTemperature(K: currentWeather.main.feelsLike))"
                
                // Could move the network call to the viewmodel and make a separate icon publisher to update the image
                IconRequest.send(icon: currentWeather.weather.first?.icon ?? "01d", size: 2) { result in
                    switch(result) {
                    case .failure:
                        // TODO: Display some sort of "no icon" image
                        return
                    case .success(let image):
                        DispatchQueue.main.async {
                            self?.icon.image = image
                        }
                    }
                }
                
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
        
        title = "Loading..." // placeholder since we don't know the location name yet
        
        view.addSubview(temperatureLabel)
        // Set placeholder temperature while loading
        temperatureLabel.text = formatTemperature(K: 295.5)
        // set the temperature to be large in the top left
        temperatureLabel.font = temperatureLabel.font.withSize(60)
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: temperatureLabel, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 12).isActive = true
        NSLayoutConstraint(item: temperatureLabel, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 12).isActive = true
        
        // Icon goes to the right of the temperature
        view.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: icon, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 12).isActive = true
//        NSLayoutConstraint(item: icon, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: view.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: -12).isActive = true
        NSLayoutConstraint(item: icon, attribute: .left, relatedBy: .equal, toItem: temperatureLabel, attribute: .right, multiplier: 1, constant: 12).isActive = true
        NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal, toItem: temperatureLabel, attribute: .height, multiplier: 1, constant: 0).isActive = true
        
        // Description goes below temperature and icon
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Loading..."
        descriptionLabel.font = descriptionLabel.font.withSize(16)
        NSLayoutConstraint(item: descriptionLabel, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 12).isActive = true
        NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: temperatureLabel, attribute: .bottom, multiplier: 1, constant: 12).isActive = true
    
        // feels like goes below description, but spaced a bit further
        view.addSubview(feelsLikeLabel)
        feelsLikeLabel.translatesAutoresizingMaskIntoConstraints = false
        feelsLikeLabel.text = "Loading..."
        feelsLikeLabel.font = feelsLikeLabel.font.withSize(16)
        NSLayoutConstraint(item: feelsLikeLabel, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 12).isActive = true
        NSLayoutConstraint(item: feelsLikeLabel, attribute: .top, relatedBy: .equal, toItem: descriptionLabel, attribute: .bottom, multiplier: 1, constant: 16).isActive = true
        
        // Would have liked a fade out effect on the bottom of the table view.  Would need to subclass it and add a gradient layer as a mask
        view.addSubview(forecastView)
        forecastView.backgroundColor = .white.withAlphaComponent(0.1)
        forecastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: forecastView, attribute: .left, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: 12).isActive = true
        NSLayoutConstraint(item: forecastView, attribute: .right, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: -12).isActive = true
        NSLayoutConstraint(item: forecastView, attribute: .top, relatedBy: .equal, toItem: feelsLikeLabel, attribute: .bottom, multiplier: 1, constant: 16).isActive = true
        NSLayoutConstraint(item: forecastView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -12).isActive = true
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

