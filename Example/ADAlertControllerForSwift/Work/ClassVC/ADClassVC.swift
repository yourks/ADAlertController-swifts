//
//  ADClassVC.swift
//  ADAlertController-swift
//
//  Created by apple on 2021/6/23.
//

import UIKit


class ADClassVC: ADBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    
    func netRequest() {
        /*
            第一种：
            通过guard let，传入的默认值：1， 会直接走到Swift case1， 抛出异常， guard let直接return
         */
        guard let error =  try? netThrow(type: 1) else {
            return
        }
        print(error)
        
        /*
                 第二种：
                 原理一样， 控制台会打印出： 出错了---1
         */
        do {
            
            let data = try netThrow(type: 1)
            
            print(data)

        } catch ADClassHttpError.errorNoData {
            
            print("出错了---errorNoData")
            
        } catch ADClassHttpError.errorNetNoFound {
            
            print("出错了---errorNetNoFound")
            
        } catch ADClassHttpError.errorDataFormatWrong {
            
            print("出错了---errorNetNoFound")
            
        } catch {
            
            print("出错了---others")
        }

        /*
          简写，catch let error as MyError， 打印错误值
        */
        do {
            
            let data = try netThrow(type: 10)
            
            print(data)
            
        } catch let error as ADClassHttpError {
            
            print(error)
            
        } catch {
            
            print("others")
        }
        
        // 通过try?来调用,返回num是nil
        let num = try? netThrow(type: 1)
        print(num as Any)
    }
    
    // noHandlerError函数声明了throws，一样没有处理异常，只是往上抛出，看有没有人去处理。!不捕捉Error，在当前函数增加throws声明，Error将自动抛给上层函数。如果最终没人处理，系统一样会崩溃闪退。
    func noHandlerError() throws {
        let num = try netThrow(type: 1)
        print(num)
    }

//         rethrows
//
//     rethrows表明：函数本身不会抛出错误，但调用闭包参数抛出错误，那么它会将错误向上抛。
//     rethrows主要用于参数有闭包的时候，闭包本身会有抛出异常的情况。
//     rethrows作为一个标志，显示的要求调用者去处理这个异常（不处理往上抛）。
    func testRethrow(testThrowCall: (Int) throws -> String, num: Int) rethrows -> String {
        guard (try? netThrow(type: 1)) != nil else {
            return ""
        }
        return ""
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ADClassVC {
    func netThrow(type: NSInteger) throws -> NSString {
            
            print("开始处理错误")
         
            switch type {
            case 1:
                throw ADClassHttpError.errorNoData
            case 2:
                throw ADClassHttpError.errorDataFormatWrong
            case 3:
                throw ADClassHttpError.errorNetNoFound
            default:
                throw ADClassHttpError.errorOther
            }
        }
}
