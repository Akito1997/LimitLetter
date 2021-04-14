//
//  ViewController.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/01/17.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var Leaveletter: UILabel!
    var count=Int()
    let userDefaults = UserDefaults.standard
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 適当に開始時点のDateを用意する
        let f_now = DateFormatter()
        f_now.dateStyle = .full
        f_now.timeStyle = .full
        let now = Date()
        print(f_now.string(from: now)) //2017年8月13日
        
        
        
        
        let startDate = Date().addingTimeInterval(-180071.3325)

        // 開始からの経過秒数を取得する
        let timeInterval = Date().timeIntervalSince(startDate)
        let time = Int(timeInterval)

        let d = time / 86400
        let h = time / 3600 % 24
        let m = time / 60 % 60
        let s = time % 60

        // ミリ秒
        let ms = Int(timeInterval * 100) % 100

        let string = String(format: "%d日%d時間%d分%d.%d秒", d, h, m, s, ms)

        // 2日2時間1分11.33秒
        print(string)

        Timer.scheduledTimer( //TimerクラスのメソッドなのでTimerで宣言
          timeInterval: 1, //処理を行う間隔の秒
          target: self,  //指定した処理を記述するクラスのインスタンス
          selector: #selector(self.countletter), //実行されるメソッド名
          userInfo: nil, //selectorで指定したメソッドに渡す情報
          repeats: true //処理を繰り返すか否か
        )

    }
    @objc func countletter(){
        count+=1
        Leaveletter.text=String(count)
    }


}

