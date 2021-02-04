//
//  DetailViewController.swift
//  PryanikiTestTask
//
//  Created by Maxim Alekseev on 03.02.2021.
//

import UIKit

class DetailViewController: UIViewController {
    
    //MARK: - Properties
    
    private var viewModel: DetailViewModel!
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIElements()
        
    }
    
    //MARK: - Methods
    
    //Set View model
    func setViewModel(title: String, viewModel: DetailViewModel) {
        self.navigationItem.title = title
        self.viewModel = viewModel
    }
    
    private func setupUIElements() {
        
        self.textLabel.text = viewModel.text ?? "No data"
        
        guard let imageURL = viewModel.imageURL else {
            imageView.isHidden = true
            return
        }
        
        imageView.webImage(imageURL, placeHolder: UIImage(named: "questionmark.square"))
        
    }
}
