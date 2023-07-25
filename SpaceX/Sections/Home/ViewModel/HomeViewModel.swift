//
//  HomeViewModel.swift
//  SpaceX
//
//  Created by Gabriel Monteiro Camargo da Silva - GCM on 16/01/22.
//

import Foundation
import Combine

class HomeViewModel {
    
    @Published private(set) var rocketsLaunched: [RocketLaunchModel] = []
    @Published private(set) var infoText: String?
    @Published private(set) var error: NetworkError?
    @Published private(set) var selectedRocket: RocketLaunchModel?
    
    private let service: NetworkService<HomeAPI>
    
    init(service: NetworkService<HomeAPI> = NetworkService<HomeAPI>()) {
        self.service = service
    }
    
    func viewDidLoad() {
        Task {
            await fetchInfo()
            await fetchRocketsLaunched()
        }
    }
    
    func fetchInfo() async {
        switch await service.request(target: .info, expecting: RocketLaunchInfoModel.self) {
        case .success(let model):
            infoText = generateInfoText(for: model)
        case .failure(let error):
            self.error = error
        }
    }
    
    func fetchRocketsLaunched() async {
        switch await service.request(target: .rocketsLaunched, expecting: [RocketLaunchModel].self) {
        case .success(let model):
            rocketsLaunched = model
        case .failure(let error):
            self.error = error
        }
    }
    
    func getRocket(for index: Int) -> RocketLaunchModel {
        return rocketsLaunched[index]
    }
    
    private func generateInfoText(for model: RocketLaunchInfoModel) -> String {
        let convertedValuation = getConvertedValuation(value: model.valuation)
        
        return "\(model.name) was founded by \(model.founder) in \(model.year). It has now \(model.employees) employees, " +
            "\(model.launchSites) launch sites, and is valued at USD \(convertedValuation)."
    }
    
    private func getConvertedValuation(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currencyAccounting
        formatter.locale = Locale(identifier: "US")
        formatter.currencyCode = "usd"
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    func openDetails(index: Int) {
        selectedRocket = rocketsLaunched[index]
    }
}
