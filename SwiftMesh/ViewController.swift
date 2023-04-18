//
//  ViewController.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
import Combine
class ViewController: UIViewController {
    var request = RequestModel()
    private var cancellables: Set<AnyCancellable> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        request.getAppliances()
        
        request.$cityResult
            .receive(on: RunLoop.main)
            .sink { (model) in
                print("hello \(String(describing: model))")
         }.store(in: &cancellables)
    }
 
}

