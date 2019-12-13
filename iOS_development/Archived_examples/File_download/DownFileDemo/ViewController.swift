//
//  ViewController.swift
//  DownFileDemo
//
//  Created by wenjing on 2019/10/31.
//  Copyright © 2019 wenjing. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        button.backgroundColor = UIColor.red
        button.setTitle("登录", for: .normal)
        button.addTarget(self, action: #selector(downFile), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    
    @objc func downFile() {
        
        self.downFileMethod2()
    }
    
    func downFileMethod1() {
        
        let urlStr = "http://overboy.scorchstudios.com/stager_storage_beta"
        if let url = URL(string: urlStr) {
            let request = URLRequest(url:url)
            Alamofire.request(request).responseData { (res) in
                let path = url.path
                let filePathString = self.filePath().appendingFormat("%@", path)
                guard let data = res.data else {return}
                let flag = FileManager.default.createFile(atPath: filePathString, contents: data, attributes: nil)
                if  flag == true {
                    print("下载成功")
                } else {
                    print("下载失败")
                }
                
                
            }
            .downloadProgress { (progress) in
                //print(progress)
            }
            
        }
    }
    
    func downFileMethod2() {
        
        let urlStr = "http://overboy.scorchstudios.com/stager_storage_beta/frame_0161.exr"
        if let url = URL(string: urlStr) {
            Alamofire.download(url) { (requestUrl, res) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                print(url.path)
                // print(res)
                let path = url.path
                let filePathString = self.filePath().appendingFormat("%@", path)
                return (URL(fileURLWithPath: filePathString),.removePreviousFile)
            }
            .downloadProgress { (progress) in
                
            }
            .responseData { (data) in
                
                print(data)
            }
            
        }
    }
    //获取文件路径 Get the path of the file under the sandbox
    func filePath()->(String)  {
        
        //        let urlPath = FileManager.default.
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return ""
        }
        print("文件路径----%@",documentPath)
        let filePath = documentPath.appendingFormat("%@", "/download")
        if FileManager.default.fileExists(atPath: filePath) == false {
            do {
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("createDirectory failed")
                
            }
        }
        return filePath
    }
}

