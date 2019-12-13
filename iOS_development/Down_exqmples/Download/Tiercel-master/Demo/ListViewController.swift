//
//  ListViewController.swift
//  Example
//
//  Created by Daniels on 2018/3/16.
//  Copyright © 2018 Daniels. All rights reserved.
//

import UIKit
import Tiercel

class ListViewController: UITableViewController {


    lazy var URLStrings: [String] = {
        return ["https://www.apple.com/105/media/cn/ipad/2018/08716702_0a2f_4b2c_9fdd_e08394ae72f1/films/use-two-apps/ipad-use-two-apps-tpl-cn-20180404_1280x720h.mp4",
                "https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4",
                "https://www.apple.com/105/media/us/imac-pro/2018/d0b63f9b_f0de_4dea_a993_62b4cb35ca96/thumbnails/buck/large.mp4",
                "http://hwcpicc.cdn.51touxiang.com/video/dcTwZK2pyJ5_fWFI25ixkTNUpeZJLiGenmYOD4Yw.mp4?pid=zSyldevP%2B3bfG%2B%2BYUgeT6YPyiyw1qnNmdjOO5PzKS74%3D&utk=U_MTYzNDI0NzM%3D&uk=rJgytP6zlhHv2cl3CFD7F4HXJRZ4LPKh65eD3xFIRWs%3D&t=1573015029&sign=456f8f5f167aa468788a8d1df207ebbc&ip=115.216.26.101",
                "http://api.gfs100.cn/upload/20180202/201802021048136875.mp4",
                "http://api.gfs100.cn/upload/20180126/201801261120124536.mp4",
                "http://api.gfs100.cn/upload/20180201/201802011423168057.mp4",
                "http://api.gfs100.cn/upload/20180126/201801261545095005.mp4",
                "http://api.gfs100.cn/upload/20171218/201712181643211975.mp4",
                "http://api.gfs100.cn/upload/20171219/201712191351314533.mp4",
                "http://api.gfs100.cn/upload/20180126/201801261644030991.mp4",
                "http://api.gfs100.cn/upload/20180202/201802021322446621.mp4",
                "http://api.gfs100.cn/upload/20180201/201802011038548146.mp4",
                "http://api.gfs100.cn/upload/20180201/201802011545189269.mp4",
                "http://api.gfs100.cn/upload/20180202/201802021436174669.mp4",
                "http://api.gfs100.cn/upload/20180131/201801311435101664.mp4",
                "http://api.gfs100.cn/upload/20180131/201801311059389211.mp4",
                "http://api.gfs100.cn/upload/20171219/201712190944143459.mp4"]
    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11, *) {
        } else {
            let topSafeArea = (navigationController?.navigationBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.size.height
            tableView.contentInset.top = topSafeArea
            tableView.scrollIndicatorInsets.top = topSafeArea
        }

    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return URLStrings.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListViewCell
        cell.URLStringLabel.text = "视频\(indexPath.row + 1).mp4"
        let URLStirng = URLStrings[indexPath.row]
        cell.downloadClosure = { cell in
            appDelegate.sessionManager4.download(URLStirng, fileName: cell.URLStringLabel.text)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
