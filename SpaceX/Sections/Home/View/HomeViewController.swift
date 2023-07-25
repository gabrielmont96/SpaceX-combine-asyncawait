//
//  HomeViewController.swift
//  SpaceX
//
//  Created by Gabriel Monteiro Camargo da Silva - GCM on 16/01/22.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var companyLabel: UILabel!
    
    var viewModel: HomeViewModel
    var cancellableBag = Set<AnyCancellable>()
        
    required init?(coder aDecoder: NSCoder) {
        viewModel = HomeViewModel()
        super.init(coder: aDecoder)
    }
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SpaceX"
        setupBindings()
        setupTableView()
        viewModel.viewDidLoad()
    }
}

// Bindings
extension HomeViewController {
    func setupLaunchesModel() {
        viewModel.$rocketsLaunched
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.separatorStyle = .singleLine
                self?.tableView.reloadData()
            }.store(in: &cancellableBag)
    }
    
    func setupInfoText() {
        viewModel.$infoText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.companyLabel.text = text
            }.store(in: &cancellableBag)
    }
    
    func setupError() {
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { error in
                guard let error else { return }
                print("--------------")
                print("Request failed")
                print(String(describing: error))
                print("--------------")
            }.store(in: &cancellableBag)
    }
    
    func setupBindings() {
        setupLaunchesModel()
        setupInfoText()
        setupError()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let homeCell = UINib(nibName: RocketInfoCell.identifier, bundle: nil)
        tableView.register(homeCell, forCellReuseIdentifier: RocketInfoCell.identifier)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rocketsLaunched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: RocketInfoCell.identifier) as? RocketInfoCell {
            let model = viewModel.getRocket(for: indexPath.row)
            cell.setup(model: model)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.openDetails(index: indexPath.row)
    }
}
