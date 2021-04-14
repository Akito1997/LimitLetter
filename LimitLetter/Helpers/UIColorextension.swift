//
//  UIColorextension.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/01/18.
//

import UIKit

extension UIColor{
    static let startColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    static let endColor = #colorLiteral(red: 0.2852321628, green: 0.938419044, blue: 0.9285692306, alpha: 1)
    static func rgb(red: CGFloat,green:CGFloat,blue:CGFloat)->UIColor{
        return self.init(red: red/255,green: green/255,blue: blue/255,alpha:1)
    }
}
