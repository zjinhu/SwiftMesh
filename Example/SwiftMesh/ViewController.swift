//
//  ViewController.swift
//  SwiftMesh
//
//  Created by iOS on 2023/5/11.
//

import UIKit
import Combine
import ProgressHUD
import SnapKit
import SwiftBrick
import SwiftMesh
class ViewController: UIViewController {
    var request = RequestModel()
    private var cancellables: Set<AnyCancellable> = []
    
    lazy var requestButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .random
        btn.setTitle("Request", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTouchUpInSideBtnAction { [weak self]sender in
            Task{
                ProgressHUD.animate()
                await self?.request.getResult()
                ProgressHUD.dismiss()
            }
        }
        return btn
    }()
    
    lazy var downloadButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .random
        btn.setTitle("Download", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTouchUpInSideBtnAction { [weak self]sender in
            Task{
                ProgressHUD.animate()
                await self?.request.download()
                ProgressHUD.dismiss()
            }
        }
        return btn
    }()
    
    lazy var resultLabel: UILabel = {
        let resultLabel = UILabel()
        resultLabel.numberOfLines = 0
        return resultLabel
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
 
        view.addSubview(requestButton)
        requestButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(80)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
        
        view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(200)
        }
 
        view.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(200)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
 
        request.$yesterday
            .receive(on: RunLoop.main)
            .sink { (model) in
                self.resultLabel.text = String(describing: model)
                print("请求数据Model \(String(describing: model))")
         }.store(in: &cancellables)
        
        
        request.$downloadUrl
            .receive(on: RunLoop.main)
            .sink { (model) in
                print("下载文件地址 \(String(describing: model))")
         }.store(in: &cancellables)
    }
 
}

