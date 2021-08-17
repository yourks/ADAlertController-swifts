//
//  ADAlertControllerPriorityQueue.swift
//  ADAlertController-swift
//
//  Created by apple on 2021/7/2.
//

import UIKit

//  用最大堆来实现优先级队列,存储逻辑是使用一个可变数组来保存所有节点,当插入一个节点元素时,进行上滤,使之保持结构完整性
//  删除时,从最顶部删除最大的那个节点,然后从队列末尾处取出放到最顶部,并进行下滤,保持最大堆的完整性

// 比较父节点是否大于子节点,第一个参数为子节点,第二个参数为父节点,第三个为是否上滤
public typealias ChildCompareParentBlock = (_ childNode: ADAlertControllerPriorityQueueProtocol, _ parentNode: ADAlertControllerPriorityQueueProtocol, _ up: Bool) -> Bool

// 从两个孩子节点中决定哪个作为新的父节点
public typealias SearchProperParentBlock = (_ leftChild: ADAlertControllerPriorityQueueProtocol, _ rightChild: ADAlertControllerPriorityQueueProtocol) -> ADAlertControllerPriorityQueueProtocol

class ADAlertControllerPriorityQueue: ADAlertControllerPriorityQueueProtocol {
    var alertPriority: ADAlertPriority?
    
    var autoHidenWhenInsertSamePriority: Bool?
    
    var targetViewController: UIViewController?
    
    var hidenWhenTargetViewControllerDisappear: Bool?
    
    func enqueue() {}
    
    func cleanQueueAllObject() {}
    
    func show() {
        
    }
    
    func hiden() {}
    

    // MARK: - property/private

    // queue
    private var queue: [ADAlertControllerPriorityQueueProtocol]?

    // alertOperationQueue
    private var alertOperationQueue: OperationQueue?

    // semaphore
    private var semaphore: DispatchSemaphore?

    // parentChildNeedSwapBlock
    private var parentChildNeedSwapBlock: ChildCompareParentBlock?

    // searchProperParentBlock
    private var searchProperParentBlock: SearchProperParentBlock?
    
    // currentAlertController
    public var currentAlertController: ADAlertController? {
        didSet{
            if currentAlertController != oldValue {
                weak var weakSelf = self

                currentAlertController?.didDismissBlock = {(alertController: ADAlertController ) in
                    //信号量恢复
                    weakSelf?.semaphore?.signal()
                    if alertController.deleteWhenHiden == true {
                        if alertController.isEqual(ADAlertControllerPriorityQueue.getMax()) == true {
                            //若当前要隐藏的 alertController 是最前面的,直接执行deleteMax,
                            _ = ADAlertControllerPriorityQueue.deleteMax()
                        }else{
                            let tempItems = (weakSelf?.queue!)! as NSArray
                            let deleteIndex = tempItems.index(of: alertController)
                            ADAlertControllerPriorityQueue.deleteAtIndex(deleteIndex)
                        }
                        weakSelf?.currentAlertController = nil;
                        //若这里的 showNext ,没成功显示下一个警告框
                        //在alertController_viewDidAppear 也有机会去执行
                        
                        DispatchQueue.main.async {
                            // 返回到主线程更新 UI
                            weakSelf?.showNext()
                        }
                    }
                };
            }
        }
    }

    // MARK: - static func
    // step3
    static func shareInstance() -> ADAlertControllerPriorityQueue {
        struct Static {
            // Singleton instance. Initializing keyboard manger.
            static let shareInstance: ADAlertControllerPriorityQueue = ADAlertControllerPriorityQueue()
        }
        return Static.shareInstance
    }

    init() {
        self.queue = Array();
        self.alertOperationQueue = OperationQueue();
        self.alertOperationQueue?.name = "com.adalertcontroller.alertoperationqueue";
        self.alertOperationQueue?.maxConcurrentOperationCount = 1;
        self.semaphore = DispatchSemaphore(value: 1) ;

        self.parentChildNeedSwapBlock = {(childNode: ADAlertControllerPriorityQueueProtocol, parentNode: ADAlertControllerPriorityQueueProtocol, up: Bool) -> Bool in

            if (up) {
                //上滤时,仅在子节点严格大于父节点时才需要交换
                return childNode.alertPriority ?? ADAlertPriorityLow > parentNode.alertPriority ?? ADAlertPriorityLow;
            }else{
                //下滤时,如果父子优先级相同,需要比较插入时间
                if (childNode.alertPriority == parentNode.alertPriority) {

                    if let childNodes: ADAlertController = childNode as? ADAlertController, let parentNodes: ADAlertController = parentNode as? ADAlertController {

                        return (childNodes.ad_insertTimeInterval < parentNodes.ad_insertTimeInterval);
                    }
                }
                //当父节点不大于子节点就需要交换
                return parentNode.alertPriority ?? ADAlertPriorityLow <= childNode.alertPriority ?? ADAlertPriorityLow;
            }
        };

        self.searchProperParentBlock = {(leftChild: ADAlertControllerPriorityQueueProtocol, rightChild: ADAlertControllerPriorityQueueProtocol) -> ADAlertControllerPriorityQueueProtocol in

            if (leftChild.alertPriority ?? ADAlertPriorityLow > rightChild.alertPriority ?? ADAlertPriorityLow) {
                //左节点优先级大于右节点,返回左节点
                return leftChild;
            }else if (leftChild.alertPriority == rightChild.alertPriority) {
                //左右节点优先级相同,比较插入时间
                if let leftChilds: ADAlertController = leftChild as? ADAlertController, let rightChilds: ADAlertController = rightChild as? ADAlertController {
                    if (leftChilds.ad_insertTimeInterval < rightChilds.ad_insertTimeInterval) {
                        return leftChild;
                    }
                }
            }
            return rightChild;
        };

    };
    
    // MARK: - static logic
    // step6
    // 处理插入新元素的情况
    // @param element 新插入的元素
    func handlerInsertElement(_ element: ADAlertControllerPriorityQueueProtocol) {
        if self.currentAlertController == nil {
            //当前暂没有显示 alertController
            self.showNext()
        }
        else if self.currentAlertController?.alertPriority ?? ADAlertPriorityLow < element.alertPriority ?? ADAlertPriorityLow{
            //若当前显示的 alertController 优先级较插入的低,需要隐藏当前的
            //设置为 NO,不会在隐藏时被移除
            self.currentAlertController?.deleteWhenHiden = false;
            //判断是否已经显示了 currentAlertController
            if (self.currentAlertController?.isShow == true) {
                //执行隐藏方法,会自动显示下一个可用的警告框视图
                self.currentAlertController?.hiden()
                
            }else{
                self.currentAlertController?.donotShow = true;
            }

        }else if (self.currentAlertController?.alertPriority ?? ADAlertPriorityLow == element.alertPriority ?? ADAlertPriorityLow &&
                    self.currentAlertController?.autoHidenWhenInsertSamePriority == true){
            //当前显示的与入队列的 alertController 优先级相同,且当前警告框允许被自动覆盖
            self.currentAlertController?.deleteWhenHiden = true;
            
            if (self.currentAlertController?.isShow == true) {
                //执行隐藏方法,会自动显示下一个可用的警告框视图
                self.currentAlertController?.hiden()
            }else{
                self.currentAlertController?.donotShow = true;
            }

        }
    }
    
    func checkShowNextValidity() -> Bool {
        if self.currentAlertController == nil,ADAlertControllerPriorityQueue.getMax() != nil {
            return true;
        }
        return false;
    }

    // step7
    func showNext() {
        if UIViewController.isShowBlackListController() == false {
            if var nextAlertController: ADAlertController = ADAlertControllerPriorityQueue.getMax() as? ADAlertController {
                    var parentIndex: NSInteger = 0;
                    var childIndex: NSInteger = 0;
                    
                while nextAlertController.canShow() == false {
                    childIndex = self.fineBestChildIndexWithParentIndex(parentIndex)
                    if let nextAlertControllers: ADAlertController = self.queue![childIndex] as? ADAlertController {
                        nextAlertController = nextAlertControllers
                        //继续遍历队列中的元素
                        parentIndex += 1;
                        if (parentIndex >= self.queue!.count) {
                            break;
                        }
                    }
                }
                if nextAlertController.canShow() == true {
                    self.currentAlertController = nextAlertController;
                    self.insertOperationToShowAlertController()
                }
            }
        }
    }
    // 寻找最佳的孩子下标,若同时有左右孩子,会比较左右孩子的优先级,以及入队列时间,
    // 若左右孩子都不可用,返回父节点下标
    // @param index 父节点下标
    func fineBestChildIndexWithParentIndex(_ index: NSInteger) -> NSInteger {
        //当前 index 的左孩子下标
        let lc: NSInteger = 1 + ((index) << 1)
        //当前 index 的右孩子下标
        let rc: NSInteger = ((index) + 1) << 1
        //1.判断当前节点的左右孩子都存在
        if lc < self.queue!.count, rc < self.queue!.count {
            //左右孩子都存在,与下滤操作中一样,取出适合的当父亲节点的那个下标
            let lcObject: ADAlertControllerPriorityQueueProtocol = (self.queue?[lc])!;
            let rcObject: ADAlertControllerPriorityQueueProtocol = (self.queue?[rc])!;
            let properParentObject: ADAlertControllerPriorityQueueProtocol = self.searchProperParentBlock!(lcObject,rcObject);
            let tempItems = self.queue! as NSArray
            let objectIndex = tempItems.index(of: properParentObject)
            return objectIndex;

        }else if(lc < self.queue!.count){
            //左孩子存在 返回左孩子
            return lc;
        }
        return index;
    }

    // 显示警告框视图,添加到队列中,并执行信号量,防止其他地方再显示
    func insertOperationToShowAlertController() {
        if self.currentAlertController != nil {
            weak var weakSelf = self
            let blockOperation: BlockOperation = BlockOperation.init {
                DispatchQueue.main.async {
                    // 返回到主线程更新 UI
                    if weakSelf?.currentAlertController != nil {
                        weakSelf?.currentAlertController?.show()
                        weakSelf?.semaphore?.wait()
                    }
                }
            }
                
            self.alertOperationQueue?.cancelAllOperations()
            self.alertOperationQueue?.addOperation(blockOperation)

        }
    }
}

// MARK: - extension private  func
extension ADAlertController {
    // 添加此属性只是为了解决从两个同样优先级的孩子节点中,决定出哪个为合适的父节点,为了与插入次序保持同样的次序显示
    // step2
    private struct AssociatedKeys {
        static var ad_insertTimeInterval: Void?
    }

    public var ad_insertTimeInterval: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ad_insertTimeInterval) as? TimeInterval ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ad_insertTimeInterval, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

// MARK: - extension public  extension
// MARK: - HeapBehaviour
extension ADAlertControllerPriorityQueue {
    // step1
    public static func inset(_ element: ADAlertController) {
        element.ad_insertTimeInterval = NSDate().timeIntervalSince1970
        ADAlertControllerPriorityQueue.shareInstance().queue?.append(element)
        _ = ADAlertControllerPriorityQueue.shareInstance().percolateUp((ADAlertControllerPriorityQueue.shareInstance().queue?.count ?? 1 )-1)
        ADAlertControllerPriorityQueue.shareInstance().handlerInsertElement(element)
    }
    
    public static func getMax() -> ADAlertControllerPriorityQueueProtocol? {
        return ADAlertControllerPriorityQueue.shareInstance().queue?.first
    }

    public static func deleteMax() -> ADAlertControllerPriorityQueueProtocol? {
        if ADAlertControllerPriorityQueue.shareInstance().queue?.count == 0 {
            return nil;
        }
        
        let firstObject: ADAlertControllerPriorityQueueProtocol = (ADAlertControllerPriorityQueue.shareInstance().queue?.first!)!;
        if (ADAlertControllerPriorityQueue.shareInstance().queue?.count == 1) {
            ADAlertControllerPriorityQueue.shareInstance().queue?.removeLast()
        }else{
            let lastObject: ADAlertControllerPriorityQueueProtocol = (ADAlertControllerPriorityQueue.shareInstance().queue?.last)!;
            ADAlertControllerPriorityQueue.shareInstance().queue?.removeLast()
            ADAlertControllerPriorityQueue.shareInstance().queue?[0] = lastObject;
            _ = ADAlertControllerPriorityQueue.shareInstance().percolateDown(index: 0)
        }

        return firstObject;
    }

    public static func deleteAtIndex(_ deleteIndex: NSInteger) {
        
    }

    // MARK: - private
    // step5
    func parentValid(index: NSInteger) -> Bool {
        return index > 0 && ((index - 1) >> 1) < self.queue?.count ?? 0;
    }
    
    // 从某个位置的下标开始进行下滤
    // @param index 开始下滤位置
    func percolateDown(index: NSInteger) -> NSInteger {
        
        var changeIndex = index

        //index 的(至多)两个孩子的下标,用 c 表示
        var c: NSInteger = 0
        c = self.properParent(index: changeIndex)

        while (changeIndex != c) {
            //只要可能的父亲存在,且 index != c,则交换,
            self.swap(firstIndex: changeIndex, secondIndex: c)
            //更新 index,继续下滤
            changeIndex = c;
            
            c = self.properParent(index: changeIndex)
        }
        return changeIndex;
        
    }

    func properParent(index: NSInteger) -> NSInteger {
        let lc: NSInteger = 1 + ((index) << 1)
        let rc: NSInteger = ((index) + 1) << 1
        if lc < self.queue?.count ?? 0, rc < self.queue?.count ?? 0 {
            let lcObject: ADAlertControllerPriorityQueueProtocol = (self.queue?[lc])!;
            let rcObject: ADAlertControllerPriorityQueueProtocol = (self.queue?[rc])!;
            let properParentObject: ADAlertControllerPriorityQueueProtocol = self.searchProperParentBlock!(lcObject,rcObject);
            if self.parentChildNeedSwapBlock!(properParentObject,self.queue![index],false) == true {
                let tempItems = self.queue! as NSArray
                let objectIndex = tempItems.index(of: properParentObject)
                return objectIndex;
            }else if ( self.parentChildNeedSwapBlock!(self.queue![lc],self.queue![index],false) == true) {
                if lc < self.queue?.count ?? 0  {
                    return lc;
                }
            }
        }
        return index;
    }
    
    // step4
    // 对某个位置的元素进行上滤
    // @param index 开始检查位置
    func percolateUp(_ index: NSInteger) -> NSInteger {
        
        var changeIndex = index
        
        while self.parentValid(index: changeIndex) {
            //只要 index 尚有父亲
            //用 p 表示父亲的下标
            let p: NSInteger =  ((changeIndex - 1) >> 1);
            
            if let childNode: ADAlertControllerPriorityQueueProtocol = self.queue?[changeIndex], let parentNode: ADAlertControllerPriorityQueueProtocol = self.queue?[p] {
                
                let isSwitch = self.parentChildNeedSwapBlock!(childNode, parentNode, true)
                
                if isSwitch {
                    //父节点不大于子节点,交换之
                    self.swap(firstIndex: index, secondIndex: p)
                    changeIndex = p;
                }else{
                    break
                }
            }
                       
        }
        return changeIndex;
    }
    
    func swap(firstIndex: NSInteger, secondIndex: NSInteger) {
        if let firstIndexObjects: ADAlertControllerPriorityQueue = self.queue?[firstIndex] as? ADAlertControllerPriorityQueue, let secondIndexObjects: ADAlertControllerPriorityQueue = self.queue?[secondIndex] as? ADAlertControllerPriorityQueue {
            
            self.queue?[firstIndex] = secondIndexObjects;
            self.queue?[secondIndex] = firstIndexObjects;
        }
        
    }

}

// MARK: - ADExtention
extension ADAlertControllerPriorityQueue {
    public static func cleanQueueAllObject() {
        ADAlertControllerPriorityQueue.shareInstance().queue?.removeAll();
    }
}

// MARK: - ADAlertControllerQueueSupport
extension UIViewController {
    public class func initializeMethod(){
        
        var originalSelectorArr: [Selector] = Array()
        originalSelectorArr.append(#selector(UIViewController.viewDidAppear(_:)))
        originalSelectorArr.append(#selector(UIViewController.viewDidDisappear(_:)))

        var swizzledSelectorArr: [Selector] = Array()
        swizzledSelectorArr.append(#selector(UIViewController.alertController_viewDidAppear(animated:)))
        swizzledSelectorArr.append(#selector(UIViewController.alertController_viewDidDisappear(animated:)))

        for index in 0 ..< originalSelectorArr.count {
            let originalSelector: Selector = originalSelectorArr[index]
            let swizzledSelector: Selector = swizzledSelectorArr[index]
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

            //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
            let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
            //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }

        }
    }
    
    @objc func alertController_viewDidAppear(animated: Bool) {
        if (ADAlertControllerPriorityQueue.shareInstance().checkShowNextValidity() == true) {
            ADAlertControllerPriorityQueue.shareInstance().showNext()
        }
        self.alertController_viewDidAppear(animated: animated)
    }

    @objc func alertController_viewDidDisappear(animated: Bool) {
        if ADAlertControllerPriorityQueue.shareInstance().currentAlertController?.targetViewController == self, ADAlertControllerPriorityQueue.shareInstance().currentAlertController?.autoHidenWhenTargetViewControllerDisappear == true {
            ADAlertControllerPriorityQueue.shareInstance().currentAlertController?.deleteWhenHiden = false
            ADAlertControllerPriorityQueue.shareInstance().currentAlertController?.hiden()
        }else if(ADAlertControllerPriorityQueue.shareInstance().checkShowNextValidity() == true){
            ADAlertControllerPriorityQueue.shareInstance().showNext()
        }
        self.alertController_viewDidDisappear(animated: animated)
    }

    static func isShowBlackListController() -> Bool {
        let topVisibleVC: UIViewController = UIViewController.ad_topVisibleViewController()
        if let blackList: NSArray = ADAlertController.blackClassList  {
            for vc in blackList {
                if vc is UIViewController  {
                    if topVisibleVC.isKind(of: vc as! AnyClass) {
                        return false;
                    }
                }
            }
        }
        return false;
    }
}

