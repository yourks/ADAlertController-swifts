//
//  ADAlertActionConfiguration.swift
//  ADAlertController-swift
//
//  Created by apple on 2021/6/29.
//

import UIKit

/// 警告框按钮(AlertAction)的配置信息
public class ADAlertActionConfiguration {
    
    ///  alertAction 显示的标题字体,默认为 UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
    public var titleFont: UIFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)

    ///  alertAction 显示的标题颜色,默认为UIColor.darkGray
    public var titleColor: UIColor = UIColor.darkGray
    
    ///  alertAction 不可用时的标题颜色,默认为UIColor.gray.withAlphaComponent(0.6)
    public var disabledTitleColor: UIColor = UIColor.gray.withAlphaComponent(0.6)
    
    /// 构造器方法
    /// - Parameter style: 如果为destructive类型,按钮颜色和禁用按钮颜色为UIColor.red
    public init(style: ADActionStyle) {
        if style == .destructive {
            self.titleColor = UIColor.red
            self.disabledTitleColor = UIColor.red
        }
    }
}
