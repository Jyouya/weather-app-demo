//
//  CurrentWeatherView.swift
//  Weather App
//
//  Created by William West on 8/26/24.
//

import Foundation
import UIKit

class CurrentWeatherView: UIView {
    let temperatureLabel = UILabel()
    let descriptionLabel = UILabel()
    let feelsLikeLabel = UILabel()
    let icon = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        addSubview(temperatureLabel)
        addSubview(descriptionLabel)
        addSubview(feelsLikeLabel)
        addSubview(icon)
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        feelsLikeLabel.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        temperatureLabel.font = temperatureLabel.font.withSize(60)
        descriptionLabel.font = descriptionLabel.font.withSize(16)
        feelsLikeLabel.font = feelsLikeLabel.font.withSize(16)
        
        // Set placeholders
        temperatureLabel.text = formatTemperature(K: 295.5)
        descriptionLabel.text = "Loading..."
        feelsLikeLabel.text = "Loading..."
        
        NSLayoutConstraint.activate([
            temperatureLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            temperatureLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            icon.leadingAnchor.constraint(equalTo: temperatureLabel.trailingAnchor, constant: 12),
            icon.heightAnchor.constraint(equalTo: temperatureLabel.heightAnchor, constant: 0),
            icon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            
            descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            
            feelsLikeLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            feelsLikeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            feelsLikeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    public func configure(for data: WeatherEntry) {
        // Only show F/C for current temp, user probably will infer that the rest of the units are the same
        temperatureLabel.text = formatTemperature(K: data.main.temp, showUnit: true)
        descriptionLabel.text = data.weather.first?.description.localizedCapitalized
        
        let low = formatTemperature(K: data.main.tempMin)
        let high = formatTemperature(K: data.main.tempMax)
        
        feelsLikeLabel.text = "\(high) / \(low) Feels like \(formatTemperature(K: data.main.feelsLike))"
        
        IconRequest.send(icon: data.weather.first?.icon ?? "01d", size: 2) { [weak self] result in
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
    }
}
