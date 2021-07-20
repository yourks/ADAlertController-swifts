//
//  ADAlertAction.swift
//  ADAlertController-swift
//
//  Created by apple on 2021/6/25.
//

import UIKit


/// 按钮点击回调
public typealias ADAlertActionHandler = (ADAlertAction) -> Void

/// 警告框按钮
public class ADAlertAction {

    // MARK: - pubilc
    
    /// 标题
    public let title: String?
    
    /// 图片
    public let image: UIImage?
    
    /// 按钮点击回调
    public let actionHandler: ADAlertActionHandler?
    
    /// 按钮类型默认 default
    public let style: ADActionStyle
    
    /// 按钮配置
    public let configuration: ADAlertActionConfiguration
    
    /// 按钮所在的alertController
    public var alertController: UIViewController? {
        return _alertController
    }
    
    /// 按钮能否点击
    public var enabled: Bool = true {
        didSet {
            self._button?.isEnabled = enabled
        }
    }
    
    // MARK: - private
    weak var _alertController: UIViewController?
    
    // 按钮
    private var _button: UIButton?
    
    public var view: UIView {
                
        return self.loadView()
    }
        
    // 父视图 ADAlertControllerViewProtocol
//    private var _mainView: ADAlertControllerViewProtocol?

    // MARK: - life cycle
    deinit {
        print("\(self) deinit")
    }
    
    /// 初始化方法
    /// - Parameters:
    ///   - title: 标题
    ///   - image: 图片
    ///   - style: 样式风格
    ///   - actionHandler: 点击回调
    ///   - configuration: 按钮UI配置,包括字体,文字颜色
    public init(title: String? = nil, image: UIImage? = nil, style: ADActionStyle = .default,
                configuration: ADAlertActionConfiguration? = nil,
                actionHandler: ADAlertActionHandler? = nil) {
        
        self.title = title
        self.image = image
        self.style = style
        self.actionHandler = actionHandler
        self.configuration = configuration ?? ADAlertActionConfiguration(style: style)
    }
    
}

extension ADAlertAction {

    @objc func loadView() -> UIView {
        let actionBtn: ADAlertButton = ADAlertButton(title: title, image: image)
        actionBtn.addTarget(self, action: #selector(actionTapped(sender:)), for: .touchUpInside)
        
        actionBtn.setTitleColor(configuration.disabledTitleColor, for: .disabled)
        actionBtn.setTitleColor(configuration.titleColor, for: .normal)
        actionBtn.setTitleColor(configuration.titleColor, for: .highlighted)
        actionBtn.titleLabel?.font = configuration.titleFont

        self._button = actionBtn
        
        return actionBtn
    }
    
    // MARK: - @objc func
    @objc private func actionTapped(sender: UIButton) {
        actionHandler?(self)
        ADAlertController.hidenAlertVC(viewController: alertController)
    }
}

