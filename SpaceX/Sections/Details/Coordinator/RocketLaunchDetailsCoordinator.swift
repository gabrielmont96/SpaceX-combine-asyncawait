//
//  RocketLaunchDetailsCoordinator.swift
//  SpaceX
//
//  Created by Gabriel Monteiro Camargo da Silva - GCM on 17/01/22.
//

import UIKit

class RocketLaunchDetailsCoordinator: Coordinator {
    var childCoordinator: Coordinator?
    var viewController: UIViewController
    var navigationController: UINavigationController?
    
    init(model: RocketLaunchModel) {
        let viewModel = RocketLaunchDetailsViewModel(links: model.links)
        viewController = RocketLaunchDetailsViewController(viewModel: viewModel)
    }
}
