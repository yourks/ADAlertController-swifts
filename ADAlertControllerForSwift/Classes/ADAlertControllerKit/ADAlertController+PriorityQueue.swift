//
//  ADAlertController+PriorityQueue.swift
//  ADAlertControllerForSwift
//
//  Created by huangxianhui on 2021/7/17.
//

extension ADAlertController: ADAlertControllerPriorityQueueProtocol {
    
    private struct AssociatedKeys {
        static var alertPriority: Void?
        static var autoHidenWhenInsertSamePriority: Void?
        static var targetViewController: Void?
        static var hidenWhenTargetViewControllerDisappear: Void?
    }
        
    public var alertPriority: ADAlertPriority? {
        get {
            let alertPriority = objc_getAssociatedObject(self, &AssociatedKeys.alertPriority) as? ADAlertPriority
            return alertPriority ?? ADAlertPriorityDefault
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.alertPriority, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var autoHidenWhenInsertSamePriority: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.autoHidenWhenInsertSamePriority) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.autoHidenWhenInsertSamePriority, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    public var targetViewController: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.targetViewController) as? UIViewController
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.targetViewController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var hidenWhenTargetViewControllerDisappear: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.hidenWhenTargetViewControllerDisappear) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.hidenWhenTargetViewControllerDisappear, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    public func enqueue() {
        ADAlertControllerPriorityQueue.inset(self)
    }
    
    public func cleanQueueAllObject() {
        ADAlertControllerPriorityQueue.cleanQueueAllObject()
    }
   
}

extension ADAlertController {
    // step8
    func canShow() -> Bool {
        let topVisibleVC: UIViewController = UIViewController.ad_topVisibleViewController()
        if self.targetViewController != nil {
            return topVisibleVC == self.targetViewController;
        }
        return true
    }
    
//    func isShow() -> Bool {
//        return !!self.presentingViewController
//    }
}

