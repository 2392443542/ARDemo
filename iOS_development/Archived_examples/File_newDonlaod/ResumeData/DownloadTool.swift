//
//  DownloadTool.swift
//  ResumeData
//
//  Created by wenjing on 2019/11/1.
//  Copyright © 2019 wenjing. All rights reserved.
//


import UIKit


// WHEN HOW WHERE to use
// 当下载状态改变时会使用
enum DownloadState: Int {
    case Default = 0        // 默认
    case Downloading = 1    // 正在下载
    case Waiting = 2        // 等待
    case Suspend = 3        // 暂停
    case Finish = 4         // 完成
    case Error = 5          // 错误
}

// MARK:下载完成的delegate
protocol DownloadToolDelegate: class {
    // 下载返回data数据的回调
    func downloadingSource(sourceModel:DownloadSourceModel?,downloadTask:URLSessionDownloadTask,totalBytesWritten:Int64,totalBytesExpectedToWrite:Int64)
    
    // 下载状态改变时回调
    func downloadState(sourceModel:DownloadSourceModel)  
}


class DownloadTool: NSObject {
    
    // 采用方案保存resumedata，下次下载传入resumeData
    static let shareInstance = DownloadTool()
    var downloadSourcesDic = [String:DownloadSourceModel]()   // 用于存储下载文件的基本信息
    var dataQueue:OperationQueue = OperationQueue()           // 下载的线程
    var delegate:DownloadToolDelegate?
    var session:URLSession!
    var maxConcurrentCount = 5                               //最大下载量
    var currentCount = 0                                      //当前正在下载的数量
    
    override init() {
        super.init()
        // 1、配置请求参数,backfround 启用后台下载
        let date = Date()
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.scorchstudios.background_\(date)")
        // 默认下载方式不启用后台下载
        //        let configuration = URLSessionConfiguration.default
        // 2.下载的线程最大并发量
        dataQueue.maxConcurrentOperationCount = 1
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.httpMaximumConnectionsPerHost = 1
        // 3.创建下载的session
        session = URLSession.init(configuration: configuration,delegate: self,delegateQueue: dataQueue)
    }
    
    func startDownload(_ sourceModel:DownloadSourceModel) {
        print("下载量---%zd",sourceModel.state,currentCount)
        // 判断url是否有效
        //        guard ((try? sourceModel.url.asURL()) != nil) else {
        //            print("无效的url")
        //            return
        //        }
        // 判断当前task是否已经在执行，当如果有任务在执行时app被kill，重新启动会自动下载
        if sourceModel.state == .Downloading || sourceModel.state == .Finish {
            self.downloadSourcesDic[sourceModel.url] = sourceModel
            return
        }
        
        // 先判断是否已经存入字典中
        if  sourceModel.state == .Default {
            sourceModel.state = .Waiting
            self.downloadSourcesDic[sourceModel.url] = sourceModel
        }
        // 判读是否超出最大下载量
        if currentCount >= maxConcurrentCount {
            sourceModel.state = .Waiting
            currentCount = maxConcurrentCount
        } else {
            currentCount = currentCount + 1
            self.addDownloadTask(sourceModel )
        }
    }
    
    // 添加一个下载任务 start Task
    func addDownloadTask(_ sourceModel:DownloadSourceModel) {
        let url = URL.init(string: sourceModel.url)!
        if let resumeData = sourceModel.resumeData {
            let downTask = session.downloadTask(withResumeData: resumeData)
            downTask.taskDescription = sourceModel.url
            sourceModel.downTask = downTask
            downTask.resume()
            print(self.downloadSourcesDic)
        } else {
            let downTask = session.downloadTask(with: url)
            downTask.taskDescription = sourceModel.url
            sourceModel.downTask = downTask
            downTask.resume()
        }
        sourceModel.state = .Downloading
        self.downloadSourcesDic[sourceModel.url] = sourceModel
        self.saveDownloadSource()
    }
    
    // 将等待中的任务开启
    func startDownloadWaitingTask() {
        let waitingArr = self.downloadSourcesDic.filter {$0.value.state == .Waiting}
        for (_,contentModel) in waitingArr {
            self.startDownload(contentModel)
        }
    }
    
    // suspend dowwload file 暂停
    func suspendDownload(_ sourceModel:DownloadSourceModel) {
        if sourceModel.state == .Downloading {
            sourceModel.downTask?.cancel(byProducingResumeData: { (resumeData) in
                print("取消成功")
                sourceModel.state = .Suspend
                sourceModel.resumeData = resumeData
                self.currentCount = self.currentCount > 0 ? self.currentCount - 1 : 0
            })
        }
    }
    
    deinit {
        self.session.invalidateAndCancel() //取消session否则会造成内存泄漏
    }
}

//MARK: 保存下载信息到本地
extension DownloadTool {
    //保存下载的信息到本地 save download message to localPath
    func saveDownloadSource() {
        let modelArr = NSMutableArray()
        for (_,contentModel) in self.downloadSourcesDic {
            //判断系统是否是ios 11，ios 11之后使用 func archivedData(withRootObject object: Any, requiringSecureCoding requiresSecureCoding: Bool)
            //            if #available(iOS 11.0, *) {
            //                guard  let data = try? NSKeyedArchiver.archivedData(withRootObject: contentModel, requiringSecureCoding: true) else { continue }
            //                modelArr.add(data)
            //            } else {
            let data = NSKeyedArchiver.archivedData(withRootObject: contentModel)
            modelArr.add(data)
            //            }
        }
        let savePath = ALFileManager.default.getLocalPath(fileName:"DownloadTool_downloadSources.data")
        let flag = (modelArr as NSArray).write(toFile: savePath, atomically: true)
        if flag {
            print("保存成功")
        } else {
            print("保存失败")
        }
    }
}

//MARK: 对缓存数据的基本信息的处理
extension DownloadTool {
    
    //通过url获取model
    func getSourceModel(_ urlStr:String) -> DownloadSourceModel? {
        let contentModel = self.downloadSourcesDic[urlStr]
        return contentModel
    }
    // 修改下载状态 change current state to finsh
    func changeFinshState(_ urlStr:String) {
        let contentModel = self.downloadSourcesDic[urlStr]
        contentModel?.state = .Finish
    }
}

//MARK:URLSessionDownloadDelegate
extension DownloadTool:URLSessionDownloadDelegate {
    
    //下载任务完成或者出错的回调
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("下载错误 ---\(task.taskDescription)----\(String(describing: error))")
        guard let currentSourceModel = self.getSourceModel(task.taskDescription ?? "") else { return }
        if let urlError = error as? URLError {
            
            if urlError.code != URLError.cancelled {
                currentSourceModel.state = .Suspend
                
            } else {
                currentSourceModel.state = .Error
            }
        } else {
            //防止后台下载完成任务之后进度条进度不为100%
            currentSourceModel.progress.completedUnitCount = currentSourceModel.progress.totalUnitCount
            currentSourceModel.state = .Finish
        }
        
        self.delegate?.downloadState(sourceModel: currentSourceModel)
        if self.currentCount > 0 {
            self.currentCount = self.currentCount - 1
        }
        
        self.startDownloadWaitingTask()
        self.saveDownloadSource()
    }
    
    // finished downloading.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //下载完成将下载完成的文件从library文件夹下移动到document下
        let fileName = downloadTask.currentRequest?.url?.lastPathComponent ?? ""
        let filePathString = ALFileManager.default.getLocalPath(fileName: fileName)
        if FileManager.default.fileExists(atPath: filePathString) {
            do {
                try FileManager.default.removeItem(atPath: filePathString)
            } catch {
                print("删除文件失败")
            }
        }
        do {
            try  FileManager.default.moveItem(atPath: location.path, toPath: filePathString)
        } catch {
            print("移动失败")
        }
    }
    
    // download’s progress.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let currentDownloadModel =  self.getSourceModel(downloadTask.taskDescription ?? "")
        currentDownloadModel?.totalUnitCount = totalBytesExpectedToWrite
        currentDownloadModel?.completedUnitCount = totalBytesWritten
        self.saveDownloadSource()
        self.delegate?.downloadingSource(sourceModel: currentDownloadModel, downloadTask: downloadTask, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    // 当后台任务下载完成时的回调
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("后台任务下载回来")
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let backgroundHandle = appDelegate.backgroundCompletionHandler else { return }
            backgroundHandle()
        }
    }
}

