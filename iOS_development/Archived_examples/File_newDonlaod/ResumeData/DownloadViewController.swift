//
//  DownloadViewController.swift
//  ResumeData
//
//  Created by wenjing on 2019/11/1.
//  Copyright © 2019 wenjing. All rights reserved.
//

import UIKit
//import Alamofire

//重新下载问题
class DownloadViewController: UIViewController {
    
    var tableView:UITableView!
    var dataArray = [DownloadSourceModel]()
    var count = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("走了")
        self.view.backgroundColor = UIColor.red
        DownloadTool.shareInstance.delegate = self
        self.initData()
        self.creatTableView()
    }
    
    //获取下载的文件
    func initData() {
        
        guard let path = Bundle.main.path(forResource: "testData.plist", ofType: nil) else { return }
        guard let downloadMessageArray = try? NSArray(contentsOfFile: path) else { return }
        for itemDict in downloadMessageArray ?? NSArray() {
            let dowmloadSoucre = DownloadSourceModel.init(dict: itemDict as! Dictionary<String, Any>)
            dowmloadSoucre.fileName = (dowmloadSoucre.fileName as NSString).components(separatedBy: "/").last ?? "null"
            
            DownloadTool.shareInstance.downloadSourcesDic [dowmloadSoucre.url] = dowmloadSoucre
            self.dataArray.append(dowmloadSoucre)
            DownloadTool.shareInstance.startDownload(dowmloadSoucre)
        }
    }
    
    //add tableview
    func creatTableView() {
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 80
        self.tableView.register(UINib(nibName: "DownLoadCell", bundle: nil), forCellReuseIdentifier: "DownLoadCell")
        self.view.addSubview(self.tableView)
    }
    
    // 获取本地保存下载基本数据信息的路径
    func saveFileLocalPath()->(String)  {
        let documentPath = self.getFileLocalPath()
        let savepath =  documentPath.appendingFormat("%@", "/DownloadTool_downloadSources.data")
        return savepath
    }
    
    
    // 获取文件的本地存储(sandbox)路径 Get the path of the file under the sandbox
    func getFileLocalPath()->(String)  {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return ""
        }
        let filePath = documentPath.appendingFormat("%@", "/download")
        //        print(filePath)
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

// MARK:UITableViewDelegate UITableViewDataSource
extension DownloadViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownLoadCell", for: indexPath) as! DownLoadCell
        cell.actionButton.tag = indexPath.row
        cell.actionButton.addTarget(self, action: #selector(downlaodAction), for: .touchUpInside)
        cell.downModel = self.dataArray[indexPath.row]
        return cell
    }
    
    @objc func downlaodAction(_ btn:UIButton) {
        let model = self.dataArray[btn.tag]
        if model.state == .Downloading {
            DownloadTool.shareInstance.suspendDownload(model)
        } else {
            DownloadTool.shareInstance.startDownload(model)
        }
    }
}

// MARK:DownloadToolDelegate
extension DownloadViewController:DownloadToolDelegate {
    //刷新下载按钮状态
    func downloadState(sourceModel: DownloadSourceModel) {
        DispatchQueue.main.async {
            for (i,model) in self.dataArray.enumerated() {
                if model.url == sourceModel.url {
                    if let cell =  self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? DownLoadCell {
                        
                        cell.updateViewWithModel()
                        break
                    }
                }
            }
        }
    }
    
    func downloadingSource(sourceModel: DownloadSourceModel?, downloadTask: URLSessionDownloadTask, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        DispatchQueue.main.async {
            for (i,model) in self.dataArray.enumerated() {
                if model.url == downloadTask.taskDescription {
                    if let cell =  self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? DownLoadCell {
                        model.progress.completedUnitCount  = totalBytesWritten
                        model.progress.totalUnitCount = totalBytesExpectedToWrite
                        cell.updateViewWithModel()
                        break
                    }
                }
            }
        }
    }
    
    func downloadFinsh(sourceModel: DownloadSourceModel) {
        
        for (i,model) in self.dataArray.enumerated() {
            if model.url == sourceModel.url {
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                }
            }
        }
    }
}
