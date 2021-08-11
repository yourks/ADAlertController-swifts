//
//  ADClassThrowsConfig.swift
//  ADAlertControllerForSwift_Example
//
//  Created by apple on 2021/7/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

// 错误类型枚举
enum ADClassHttpError: Error {
    
    case errorNoData
    case errorNetNoFound
    case errorDataFormatWrong
    case errorOther
    
    func errorDes() {
        
        switch self {
        case .errorNoData:
            print("请求成功没数据")
        case .errorNetNoFound:
            print("404nofound")
        case .errorDataFormatWrong:
            print("数据格式不对")
        default:
            print("其他错误")
        }
    }
}
