//
//  MainViewCellModel.swift
//  DreamWeather
//
//  Created by Alexander on 25.01.2023.
//

import Foundation

extension MainViewController {
    struct CellModel: Hashable {
        static func == (lhs: MainViewController.CellModel, rhs: MainViewController.CellModel) -> Bool {
            lhs.cityName == rhs.cityName
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(cityName)
        }
        
        let cityName: String
        let weatherCondition: String
        let temp: Float
        let detailed: () -> Void
    }
}
