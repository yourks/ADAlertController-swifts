//
//  ADAlertControllerConfiguration.swift
//  ADAlertController-swift
//
//  Created by apple on 2021/6/25.
//

import UIKit

public final class ADAlertControllerConfiguration {

    public let preferredStyle: ADAlertControllerStyle
     
    /// 点击背景是否关闭警告框视图,默认 NO
    public var hidenWhenTapBackground: Bool = false

    /// 针对 alert 类型视图,是否允许手势滑动关闭警告框视图,默认 NO
    public var swipeDismissalGestureEnabled: Bool = false
    
    /// 针对alert 类型视图,若只有两个按钮时,是否总是垂直排列,默认 NO
    public var alwaysArrangesActionButtonsVertically: Bool = false
    
    /// 覆盖在最底下的蒙版 view 的背景色,默认0.5透明度的黑色
    public var alertMaskViewBackgroundColor: UIColor =  UIColor.black.withAlphaComponent(0.5)

    /// 内容容器视图背景色,默认白色
    public var alertViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.3)

    /// 内容容器视图背景色,默认白色
    public var alertContainerViewBackgroundColor: UIColor = UIColor.white

    /// 按钮背景色 ActionsView
    public var alertActionsViewBtnBackgroundColors: [UIColor] = []

    /// 内容容器视图圆角,默认4
    public var alertViewCornerRadius: CGFloat = 4.0

    /// 标题文本颜色,默认黑色
    public var titleTextColor: UIColor = UIColor.black

    /// 详细消息文本颜色,默认黑色
    public var messageTextColor: UIColor = UIColor.black

    /// 在按钮周围是否显示分割线,默认 false
    /// 按钮间的showsSeparators 可以通过控制actionButtonStackView?.spacing = 0.0 来控制
    public var showsSeparators: Bool = false

    ///  分割线颜色,默认UIColor.lightGray
    ///  按钮间的separatorColor 可以通过 控制actionButtonStackView?.背景色 来控制
    public var separatorColor: UIColor = UIColor.lightGray

   /// 内部自定义 view 四周边距
    public var contentViewInset: UIEdgeInsets = .zero

    /// messageText 四周边距
    public var messageTextInset: UIEdgeInsets = .zero

   ///  标题文本字体,默认UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
    public var titleFont: UIFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)

    /// 详细消息文本字体,默认UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
    public var messageFont: UIFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)

    /// 背景是否需要模糊效果,默认true,未实现
    public var backgroundViewBlurEffects: Bool = true

    // MARK: - 初始化方法
    public init(preferredStyle: ADAlertControllerStyle) {
        self.preferredStyle = preferredStyle
    }
    
    public static var DefaultSheetStyleConfiguration: ADAlertControllerConfiguration {
        let config: ADAlertControllerConfiguration = ADAlertControllerConfiguration(preferredStyle: .sheet)
        config.alertViewCornerRadius = 0
        return config
    }

}
