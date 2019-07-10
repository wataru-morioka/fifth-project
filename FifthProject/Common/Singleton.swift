//
//  Constant.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/07.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation

class Singleton {
    // 自動的に遅延初期化される(初回アクセスのタイミングでインスタンス生成)
    static let shared = Singleton()
    // 外部からのインスタンス生成をコンパイルレベルで禁止
    private init() {}
    
    static let regions = [ "北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"
    ]
    
    static let ages = ([Int])(5...120)
    
    static let targetNumbers = ([Int])(1...100)

    static let timeUnits = [ "分", "時間", "日" ]
    
    static let minutes = ([Int])(1...60)
    
    static let hours = ([Int])(1...24)
    
    static let days = ([Int])(1...3)
    
    static let timeUnitDictionary: [String: Int] = [
    "分": 1,
    "時間": 60,
    "日" : 1440
    ]
    
    static let timePeriodDictionary: [String: [Int]] = [
    "分": minutes,
    "時間": hours,
    "日" : days
    ]
    
    static let maxLength = 15
    
    static func getNowStringFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        return formatter.string(from: Date())
    }
}
