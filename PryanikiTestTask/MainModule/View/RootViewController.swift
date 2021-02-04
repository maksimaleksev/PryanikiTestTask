//
//  ViewController.swift
//  PryanikiTestTask
//
//  Created by Maxim Alekseev on 03.02.2021.
//

import UIKit
import RxSwift
import RxCocoa

class RootViewController: UIViewController {
    
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private var viewModel: RootViewModel!
    private let cellId = "Cell"
    private var sectionsSubscription: Disposable?
    private var variantsSubscription: Disposable?
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = RootViewModel()
        subscribeVCStates()
        tableViewCellHasSelected()
        initTableViewSetup()
    }
    
    //MARK: - Methods
    
    //Switch VC state
    private func subscribeVCStates() {
        
        viewModel.vcStates.subscribe(onNext: { [weak self] state in
            guard let self = self else { return }
            
            self.navigationPanelSetup(for: state)
            
            switch state {
            
            case .Sections:
                self.populateTableViewBySections()
            case .Variants(let variants):
                self.populateTableViewByVariants(variants)
            }
            
        }).disposed(by: disposeBag)
        
    }
    
    
    //Populate table view by sections
    private func populateTableViewBySections() {
        variantsSubscription?.dispose()
        sectionsSubscription = viewModel.sections
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: cellId)) {index, section, cell in
                cell.textLabel?.text = section.name.capitalized
            }
    }
    
    //Populate table view by variants
    private func populateTableViewByVariants(_ variants: [Variant] ) {
        sectionsSubscription?.dispose()
        let v = Observable.just(variants)
        variantsSubscription = v.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: cellId, cellType: UITableViewCell.self)) {index, variant, cell in
                cell.textLabel?.text = variant.text
            }
    }
    
    
    //Table view setup
    private func initTableViewSetup() {
        tableView.tableFooterView = UIView()
    }
    
    //Setup nav items
    private func navigationPanelSetup(for vcState: RootViewModel.VCStates ) {
        
        let mainTitle = "Main"
        let selectorTitle = "Selector"
        
        switch vcState {
        
        case .Sections:
            self.navigationItem.title = mainTitle
            self.navigationItem.leftBarButtonItem = nil
        case .Variants(_):
            self.navigationItem.title = selectorTitle
            let leftNavButton = UIBarButtonItem(title: mainTitle, style: .plain, target: self, action: #selector(changeState))
            self.navigationItem.leftBarButtonItem = leftNavButton
        }
    }
    
    //Segue to detail vc
    private func segueToDetailVC(with title: String, and viewModel: DetailViewModel) {
        let storyboard = UIStoryboard(name: StoryBoards.Detail.rawValue, bundle: nil)
        let detailVC = storyboard.instantiateInitialViewController() as! DetailViewController
        detailVC.setViewModel(title: title, viewModel: viewModel)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //Action on cell has selected
    private func tableViewCellHasSelected() {
        
        tableView.rx.itemSelected.subscribe (onNext:{[weak self] indexPath in
            guard let self = self else { return }
            
            switch self.viewModel.vcStates.value {
            
            case .Sections:
                
                let section = self.viewModel.sections.value[indexPath.row]
                self.switchSectionType(section)
                
            case .Variants(let variants):
                
                let variant = variants[indexPath.row]
                print("Variant id is: \(variant.id)")
                
            }
        }).disposed(by: disposeBag)
    }
    
    //switchSectionType
    private func switchSectionType(_ section: Section) {
        
        switch section.sectionType {
        case .hz, .picture:
            self.segueToDetailVC(with: section.name.capitalized, and: section.sectionData)
        case .selector:
            guard let variants = section.sectionData.variants else { return  }
            self.viewModel.vcStates.accept(.Variants(variants))
        case .unknown:
            break
        }
    }
    
    @objc func changeState() {
        viewModel.vcStates.accept(.Sections)
    }
}

