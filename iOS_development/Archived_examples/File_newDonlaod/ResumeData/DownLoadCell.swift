//
//  DownLoadCell.swift
//  ResumeData
//
//  Created by wenjing on 2019/11/1.
//  Copyright © 2019 wenjing. All rights reserved.
//

import UIKit

class DownLoadCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var progressLabel: UILabel!
    var downModel:DownloadSourceModel? {
        didSet {
            self.setData()
        }
    }
    
    func setData() {
        guard let downModel = self.downModel else {return }
        self.nameLabel.text = downModel.fileName
//        self.actionButton.isEnabled = false
        self.updateViewWithModel()
    }
    
    func updateViewWithModel() {
        guard let downModel = self.downModel else {return }
        if downModel.state == .Waiting {
            self.actionButton.setTitle("等待下载", for: .normal)
        } else if downModel.state == .Default {
            self.actionButton.setTitle("等待下载", for: .normal)
        } else if downModel.state == .Finish {
            self.actionButton.setTitle("完成", for: .normal)
        } else if downModel.state == .Downloading {
            self.actionButton.setTitle("正在下载", for: .normal)
        } else if downModel.state == .Suspend {
            self.actionButton.setTitle("已暂停", for: .normal)
        } else if downModel.state == .Error {
            self.actionButton.setTitle("错误", for: .normal)
        } else {
             self.actionButton.setTitle("错误", for: .normal)
        }
        if downModel.state == .Finish {
            self.actionButton.isEnabled = false
        } else {
          self.actionButton.isEnabled = true
        }
        self.downloadProgress.progress = Float(downModel.progress.fractionCompleted)
        self.progressLabel.text = String(format: "%.4f", self.downloadProgress.progress)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
