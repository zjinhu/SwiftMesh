//
//  ViewController.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        BaseRequest.setHeader()
        // Do any additional setup after loading the view.
        BaseRequest.get("https://jsonplaceholder.typicode.com/posts", success: { (json) in
            print(json)
        }) { (config) in
            print(config)
        }
        
        
    }


}

