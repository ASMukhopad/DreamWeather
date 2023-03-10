//
//  MainViewModel.swift
//  DreamWeather
//
//  Created by Alexander on 25.01.2023.
//

import Foundation

class MainViewModel {
    
    private var cellModels = [MainViewController.CellModel]()
    
    weak var mainViewController: MainViewController?
    
    private let decoder = JSONDecoder()
    
    func search(queryString: String?) {
        if queryString?.isEmpty == true {
            mainViewController?.reloadDataSource(cellModelList: cellModels)
        } else {
            let filterCellModels = cellModels.filter {
                $0.cityName.lowercased().contains((queryString?.lowercased() ?? ""))
            }
            mainViewController?.reloadDataSource(cellModelList: filterCellModels)
        }
    }
    
    func load() {
        guard let path = Bundle.main.url(forResource: "Cities", withExtension: "json"),
              let data = try? Data(contentsOf: path, options: .mappedIfSafe),
              let cityModelList = try? decoder.decode([CityModel].self, from: data) else { return }
        
        cityModelList.forEach {
            guard let request = self.createRequest(model: $0) else { return }
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data,
                                                                   options: []),
                      let response = try? self.decoder.decode(TemplateWeather.self, from: data) else { return }
                DispatchQueue.main.async {
                    self.updateCellModels(model: response, countCity: cityModelList.count)
                }
            }.resume()
        }
    }
    
    private func createRequest(model: CityModel) -> URLRequest? {
        var urlComponents = URLComponents(string: "https://api.weather.yandex.ru/v2/forecast")
        let queryItems = [
            URLQueryItem(name: "lat", value: "\(model.lat)"),
            URLQueryItem(name: "lon", value: "\(model.lon)"),
            URLQueryItem(name: "lang", value: "ru_RU"),
        ]
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { return nil }
        var request = URLRequest(url: url)
        request.addValue("3a098a05-363f-467b-b937-9e65a65c2631", forHTTPHeaderField: "X-Yandex-API-Key")
        return request
    }
    
    func updateCellModels(model: TemplateWeather, countCity: Int) {
        cellModels.append(
            MainViewController.CellModel(
                cityName: model.geoObject.locality.name,
                weatherCondition: model.fact.condition,
                temp: model.fact.temp,
                detailed: {
                    self.mainViewController?.presentDetailViewController(model: model)
                }
            )
        )
        if countCity == cellModels.count {
            mainViewController?.reloadDataSource(cellModelList: cellModels)
        }
    }
}
