//
//  TFSimpleMessagePresenter.swift
//  dkom-ios
//
//  Created by Ran Hassid on 08/01/2019.
//  Copyright © 2019 Trench Girls LTD. All rights reserved.
//

import Foundation
import UIKit

struct SimpleMessagePresenter {
    let title: String?
    let message: String?
    
    init(title: String? = nil, message: String?) {
        self.title = title
        self.message = message
    }
    
    func present(on viewController: UIViewController, closeHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Close", style: .cancel) { _ in
            closeHandler?()
        }
        
        alertController.addAction(action)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
}
