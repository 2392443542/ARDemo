//
//  DownloadSourceModel.swift
//  ResumeData
//
//  Created by wenjing on 2019/11/1.
//  Copyright © 2019 wenjing. All rights reserved.
//

import UIKit
import Foundation

class DownloadSourceModel:NSObject,NSCoding {
    
    var url:String = ""                     // url
    var resumeData:Data?                    // 下载的数据
    var progress:Progress = Progress()      // 下载进度
    var fileName:String = ""                // 文件名
    var totalUnitCount:Int64 = 0            // 文件总大小
    var completedUnitCount:Int64 = 0        // 下载大小
    
    var state:DownloadState = .Default
    var downTask:URLSessionDownloadTask?
    
    
    // MARK: - init
    override init () {}
    
    init(dict: Dictionary<String, Any>) {
        super.init()
        self.url = dict["url"] as? String ?? ""
        self.fileName = dict["fileName"] as? String ?? ""
        self.resumeData = dict["resumeData"] as? Data
        self.progress = dict["progress"] as? Progress ?? Progress()
    }
    
    required init?(coder: NSCoder) {
        url = coder.decodeObject(forKey: "url") as? String ?? ""
        state = DownloadState(rawValue: coder.decodeObject(forKey: "state") as? Int ?? 0) ?? .Default
        progress.totalUnitCount = coder.decodeObject(forKey: "totalUnitCount") as? Int64 ?? 0
        progress.completedUnitCount = coder.decodeObject(forKey: "completedUnitCount") as? Int64 ?? 0
        
    }
    
    func encode(with coder: NSCoder) {
        
        coder.encode(NSNumber(value: state.rawValue), forKey: "state")
        coder.encode(url, forKey: "url")
        coder.encode(resumeData, forKey: "resumeData")
        coder.encode(NSNumber(value:progress.totalUnitCount), forKey: "totalUnitCount")
        coder.encode(NSNumber(value: progress.completedUnitCount), forKey: "completedUnitCount")
        coder.encode(fileName, forKey: "fileName")
    }
}

