//
//  ALFileManager.swift
//  ResumeData
//
//  Created by liwenjing on 2019/11/9.
//  Copyright © 2019年 wenjing. All rights reserved.
//

import UIKit

class ALFileManager {
    
    static let `default` = ALFileManager()
    //从sanbox 中获取保存路径
    func getLocalPath(fileName:String) -> (String) {
        let documentPath = self.getdocumentsPath()
        let savepath =  documentPath.appendingFormat("/%@", fileName)
        return savepath
    }
    
    //获取文件路径 Get the path of the file under the sandbox
    func getdocumentsPath() -> (String) {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return ""
        }
        let filePath = documentPath.appendingFormat("%@","/download")
        if FileManager.default.fileExists(atPath: filePath) == false {
            do {
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("createDirectory failed")
            }
        }
        return filePath
    }
    
    //清空temp文件用于清空之前下载失败的临时文件
    func clearCatcheLibraryDictionary() {
        do {
            try FileManager.default.removeItem(atPath: NSTemporaryDirectory())
        } catch {
            print("清理失败")
        }
    }
}
