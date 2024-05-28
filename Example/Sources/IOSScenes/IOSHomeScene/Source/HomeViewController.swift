//
//  HomeViewController.swift
//  IOSHomeSceneSource
//
//  Created by Jaewon Yun on 5/1/24.
//

import UIKit

public final class HomeViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBrown
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
