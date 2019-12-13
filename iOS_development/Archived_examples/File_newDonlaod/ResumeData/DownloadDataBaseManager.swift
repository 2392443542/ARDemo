
//
//  DwonloadDataBaseManager.swift
//  ResumeData
//
//  Created by wenjing on 2019/11/4.
//  Copyright © 2019 wenjing. All rights reserved.
//

import UIKit


enum DBGetDateOption:Int {
    case  DBGetDateOptionAllCacheData = 0      // 所有缓存数据
    case  DBGetDateOptionAllDownloadingData = 1    // 所有正在下载的数据
    case  DBGetDateOptionAllDownloadedData = 2   // 所有下载完成的数据
    case  DBGetDateOptionAllUnDownloadedData = 3   // 所有未下载完成的数据
    case  DBGetDateOptionAllWaitingData = 4        // 所有等待下载的数据
    case  DBGetDateOptionModelWithUrl = 5         // 通过url获取单条数据
    case  DBGetDateOptionWaitingModel = 6          // 第一条等待的数据
    case  DBGetDateOptionLastDownloadingModel = 7  // 最后一条正在下载的数据
}


class DownloadDataBaseManager: NSObject {
    
    static let shareInstance = DownloadDataBaseManager()
    
    lazy var dbQueue: FMDatabaseQueue = {
        //数据库文件路径
        var documentPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last
        let path = (documentPath ?? "") + "DownloadVideoCaches.sqlite"
         // 创建队列对象，内部会自动创建一个数据库, 并且自动打开
        let queue = FMDatabaseQueue(path: path)
        queue?.inDatabase({ (db:FMDatabase) in
            
        
            if db.executeUpdate(sql: "CREATE TABLE IF NOT EXISTS t_videoCaches (id integer PRIMARY KEY AUTOINCREMENT, vid text, fileName text, url text, resumeData blob, totalFileSize integer, tmpFileSize integer, state integer, progress float, lastSpeedTime double, intervalFileSize integer, lastStateTime integer)", DownloadSourceModel.self ){
                    print("创建表成功")
                }else{
                    print("创建表失败")
                }
        })
        return queue ?? FMDatabaseQueue()
    }()

    
    func insertModel(_ model:DownloadSourceModel) {
        dbQueue.inDatabase { (db:FMDatabase) in
            let  result = db.executeUpdate("INSERT INTO t_videoCaches (vid, fileName, url, resumeData, totalFileSize, tmpFileSize, state, progress, lastSpeedTime, intervalFileSize, lastStateTime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [model.vid, model.fileName, model.url, model.resumeData,NSNumber(integerLiteral: model.totalFileSize),NSNumber(integerLiteral: model.tmpFileSize),NSNumber(integerLiteral: model.state.rawValue),NSNumber(value: model.progress),NSNumber(value: 0.0),NSNumber(value: 0),NSNumber(value: 0)])
            if result == true {
                print("插入成功：%@", model.fileName)
            } else {
                print("插入失败：%@", model.fileName)
            }
        }
    }
    
    // 获取单条数据
    func getModelWithUrl(_ url:String) {
        
        
    }
    
    
    func getModelWithOption(_ option:DBGetDateOption,_ url:String) -> (DownloadSourceModel) {

        var model:DownloadSourceModel = DownloadSourceModel ()
        dbQueue.inDatabase { (db:FMDatabase) in
            var resultSet:FMResultSet?
            switch option  {
            case .DBGetDateOptionModelWithUrl:
               
                resultSet = db.executeQuery("SELECT * FROM t_videoCaches WHERE url = ?", withArgumentsIn: [url])

                break
            case .DBGetDateOptionWaitingModel:
                resultSet = db.executeQuery("SELECT * FROM t_videoCaches WHERE state = ? order by lastStateTime asc limit 0,1", withArgumentsIn: [NSNumber(value: option.rawValue)])
                break;
            case .DBGetDateOptionLastDownloadingModel:
                resultSet = db.executeQuery("SELECT * FROM t_videoCaches WHERE state = ? order by lastStateTime desc limit 0,1", withArgumentsIn: [NSNumber(value: option.rawValue)])
                break;
                default:
                break;
            }
            
            
            while resultSet?.next() ?? false {
//                model = DownloadSourceModel(dict: <#T##Dictionary<String, Any>#>)
            }
        }

        return model
    }
    
}
