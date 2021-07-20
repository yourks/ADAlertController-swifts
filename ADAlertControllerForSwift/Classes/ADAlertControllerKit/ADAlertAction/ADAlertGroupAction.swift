//
//  ADAlertGroupAction.swift
//  ADAlertController-swift
//
//  Created by apple on 2021/7/2.
//

import UIKit

public enum ADGroupActionError: Error {
    case actionCountTooSmall
    case errorInitMethod
    
}

/// 可将多个 AlertAction 当做一个AlertAction 来处理
public class ADAlertGroupAction: ADAlertAction {

    // MARK: - proprety/pubilc
    
    /// 分割线颜色
    public var separatorColor: UIColor?
    /// 分割线是否显示
    public var showsSeparators: Bool?
    
    public let actions: [ADAlertAction]
    
    private var actionButtonStackView: UIStackView?

    public override var _alertController: UIViewController? {
        didSet {
            for action in self.actions {
                action._alertController = _alertController
            }
        }
    }
    
    // MARK: - life cycle
    public init(actions: [ADAlertAction], showsSeparators: Bool = false, separatorColor: UIColor? = nil) throws {
                
        if actions.count == 0 || actions.count == 1 {
            throw ADGroupActionError.actionCountTooSmall
        }
        
        self.actions = actions
        self.showsSeparators = showsSeparators
        self.separatorColor = separatorColor
        super.init()
    }
    
    private override init(title: String? = nil, image: UIImage? = nil, style: ADActionStyle = .default,
                          configuration: ADAlertActionConfiguration? = nil,
                          actionHandler: ADAlertActionHandler? = nil) {
        self.actions = []
        super.init()
    }
}

extension ADAlertGroupAction {

    override func loadView() -> UIView {
        
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        self.actionButtonStackView = UIStackView()
        self.actionButtonStackView?.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        self.actionButtonStackView?.spacing = 0.0
        view.addSubview(self.actionButtonStackView!)
        self.actionButtonStackView?.snp.makeConstraints({ (constraintMaker) in
            constraintMaker.edges.equalToSuperview()
        })
        
        actionButtonStackView?.axis = NSLayoutConstraint.Axis.horizontal
        actionButtonStackView?.alignment = UIStackView.Alignment.fill
        actionButtonStackView?.distribution = UIStackView.Distribution.fillEqually
        self.actionButtonStackView?.layoutIfNeeded()

        for action in self.actions {            
            self.actionButtonStackView!.addArrangedSubview(action.view)
        }
        // TODO: 实现分割线
        
        return view
    }
    
    private var seperatorView: UIView {
        let view = UIView()
        view.backgroundColor = self.separatorColor
        return view
    }
    
    // FIXME: NSException
    // MARK: - func overriride
    //https://www.jianshu.com/p/84edfd5b30dd/
    //https://www.jianshu.com/p/87fb293a70b8?utm_campaign=maleskine&utm_content=note&utm_medium=seo_notes&utm_source=recommendation
    //http://www.zyiz.net/tech/detail-117055.html
//    + (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image style:(ADActionStyle)style handler:(ADAlertActionHandler)handler{
//        [NSException raise:@"ADAlertGroupActionCallException" format:@"Tried to initialize a grouped action with +[%@ %@]. Please use +[%@ %@] instead.", NSStringFromClass(self), NSStringFromSelector(_cmd), NSStringFromClass(self), NSStringFromSelector(@selector(groupActionWithActions:))]
//        return nil
//    }

    
}
