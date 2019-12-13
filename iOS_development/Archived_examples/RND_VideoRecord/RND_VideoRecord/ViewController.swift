//
//  ViewController.swift
//  RND_VideoRecord
//
//  Created by wenjing on 2019/11/12.
//  Copyright © 2019 wenjing. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.red
    }
    
    //拍照
    @IBAction func takePhoto(_ sender: UIButton) {
        self.navigationController?.pushViewController(TakePhotoViewController(), animated: true)
    }
    
    //录制
    @IBAction func record(_ sender: Any) {
        self.navigationController?.pushViewController(RecordWithDataViewController(), animated: true)
    }
}
