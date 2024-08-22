//
//  ForecastCell.swift
//  Weather App
//
//  Created by William West on 8/21/24.
//

import Foundation
import UIKit

class ForecastCell: UITableViewCell {
    let tempLabel = UILabel()
    let icon = UIImageView()
    let timeLabel = UILabel()
    let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .white.withAlphaComponent(0.1)
        self.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = timeLabel.font.withSize(16)
        timeLabel.textAlignment = .center

        NSLayoutConstraint(item: timeLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 8).isActive = true
        NSLayoutConstraint(item: timeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        self.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint(item: icon, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: timeLabel, attribute: .right, multiplier: 1, constant: 16).isActive = true
        NSLayoutConstraint(item: icon, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 64).isActive = true
        NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
        NSLayoutConstraint(item: icon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
        
        self.addSubview(tempLabel)
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.textAlignment = .center
        NSLayoutConstraint(item: tempLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tempLabel, attribute: .left, relatedBy: .equal, toItem: icon, attribute: .right, multiplier: 1, constant: 16).isActive = true
        
        self.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textAlignment = .right
        NSLayoutConstraint(item: descriptionLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: descriptionLabel, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: tempLabel, attribute: .right, multiplier: 1, constant: 16).isActive = true
        NSLayoutConstraint(item: descriptionLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -8).isActive = true
        
    }
    
    // URLSession will cache small images, so we don't need to implement cacheing ourselves
    private func loadIcon(name: String) {
        IconRequest.send(icon: name, size: 2) { result in
            switch(result) {
            case .failure:
                // TODO: Display some sort of "no icon" image
                return
            case .success(let image):
                DispatchQueue.main.async {
                    self.icon.image = image
                }
            }
        }
    }
    
    func configure(with weatherEntry: WeatherEntry) {
        let date = Date(timeIntervalSince1970: weatherEntry.timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        timeLabel.text = formatter.string(from: date)
        tempLabel.text = formatTemperature(K: weatherEntry.main.temp)
        descriptionLabel.text = weatherEntry.weather.first?.description
        
        loadIcon(name: weatherEntry.weather.first?.icon ?? "01d")
    }
}
