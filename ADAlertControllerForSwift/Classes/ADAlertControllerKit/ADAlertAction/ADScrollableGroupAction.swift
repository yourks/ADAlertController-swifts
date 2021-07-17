//
//  ADScrollableGroupAction.swift
//  ADAlertController-swift
//
//  Created by apple on 2021/7/2.
//

import UIKit

/// 可滑动的GroupAction
public class ADScrollableGroupAction: ADAlertGroupAction {
    
    public let actionWidth: CGFloat
    
    private var actionButtonStackView: UIStackView?

    // MARK: - life cycle
    public init(actions: [ADAlertAction], actionWidth: CGFloat = 80) throws {
        self.actionWidth = actionWidth
        try super.init(actions: actions)
    }
    
}

extension ADScrollableGroupAction {
    
    override func loadView() -> UIView {

        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        

        let scroll: UIScrollView = UIScrollView()
        view.addSubview(scroll)
        scroll.snp.makeConstraints({ (constraintMaker) in
            constraintMaker.edges.equalToSuperview()
            constraintMaker.height.equalToSuperview()
        })
        scroll.backgroundColor = UIColor.clear
        scroll.bounces = false

        self.actionButtonStackView = UIStackView()
        self.actionButtonStackView?.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        self.actionButtonStackView?.spacing = 30.0
        
        let width: CGFloat = CGFloat(self.actions.count) * actionWidth
        scroll.addSubview(self.actionButtonStackView!)
        self.actionButtonStackView?.snp.makeConstraints({ (constraintMaker) in
            constraintMaker.left.top.bottom.equalToSuperview()
            constraintMaker.right.equalToSuperview()
            constraintMaker.width.equalTo(width)
            constraintMaker.height.equalToSuperview()
        })
        self.actionButtonStackView?.backgroundColor = UIColor.clear

        actionButtonStackView?.axis = NSLayoutConstraint.Axis.horizontal
        actionButtonStackView?.alignment = UIStackView.Alignment.fill
        actionButtonStackView?.distribution = UIStackView.Distribution.fillEqually
        self.actionButtonStackView?.layoutIfNeeded()

        for action: ADAlertAction in self.actions {
            self.actionButtonStackView!.addArrangedSubview(action.loadView())
        }

        return view
    }
}
