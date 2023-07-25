//
//  HomeCoordinator.swift
//  SpaceX
//
//  Created by Gabriel Monteiro Camargo da Silva - GCM on 16/01/22.
//

import UIKit
import Combine

class HomeCoordinator: Coordinator {
    var childCoordinator: Coordinator?
    var viewController: UIViewController
    var navigationController: UINavigationController?
    
    var cancellableBag = Set<AnyCancellable>()
    
    init() {
        let viewModel = HomeViewModel()
        viewController = HomeViewController(viewModel: viewModel)
        setupObservable(selectedRocket: viewModel.$selectedRocket)
    }
    
    func setupObservable(selectedRocket: Published<RocketLaunchModel?>.Publisher) {
        selectedRocket
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rocketLaunched in
                guard let rocketLaunched else { return }
                self?.openDetails(model: rocketLaunched)
            }.store(in: &cancellableBag)
    }
}

extension HomeCoordinator {
    func openDetails(model: RocketLaunchModel) {
        guard let navigationController = navigationController else { return }
        let rocketLaunchCoordinator = RocketLaunchDetailsCoordinator(model: model)
        route(to: rocketLaunchCoordinator, withPresenter: .present(navigationController, .formSheet))
    }
}
