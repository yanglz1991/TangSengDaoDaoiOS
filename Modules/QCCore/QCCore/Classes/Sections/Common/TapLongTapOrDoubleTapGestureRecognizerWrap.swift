//
//  QCTapLongTapOrDoubleTapGestureRecognizer.swift
//  QCCore
//
//  Created by tt on 2022/6/21.
//

import Foundation
import UIKit

@objc public class TapLongTapOrDoubleTapGestureRecognizerWrap: NSObject {
    @objc public  var gesture: TapLongTapOrDoubleTapGestureRecognizer?
    @objc public var tapAction:QCTapLongTapOrDoubleTapGesture
    @objc public var tapPoint:CGPoint
    let action:  (_ gesture:TapLongTapOrDoubleTapGestureRecognizerWrap)->Void?
    @objc public var tapActionAtPoint: ((CGPoint) ->QCTapLongTapOrDoubleTapGestureRecognizerEvent )?
    @objc public var longTap: ((CGPoint, TapLongTapOrDoubleTapGestureRecognizerWrap) -> Void)?
    
    @objc public init(action: @escaping (_ gesture:TapLongTapOrDoubleTapGestureRecognizerWrap)->Void) {
        self.action = action
        self.tapPoint = CGPoint()
        self.tapAction = QCTapLongTapOrDoubleTapGestureTap
       
    }
    
    @objc  public func setup() {
        self.gesture = TapLongTapOrDoubleTapGestureRecognizer(target: self, action: #selector(self.tapLongTapOrDoubleTapGesture(_:)))
        
        self.gesture!.tapActionAtPoint = { [weak self] point in
            if let strongSelf = self {
                if  let event = strongSelf.tapActionAtPoint?(point) {
                    
                    switch event.action {
                    case QCTapLongTapOrDoubleTapGestureRecognizerActionWaitForSingleTap:
                        return .waitForSingleTap
                    case QCTapLongTapOrDoubleTapGestureRecognizerActionFail:
                        return .fail
                    case QCTapLongTapOrDoubleTapGestureRecognizerActionKeepWithSingleTap:
                        return .keepWithSingleTap
                    default:
                        return .fail
                    }
                }
            }
            return .fail
        }
        
        self.gesture!.longTap = {  point, recognizer in
            self.longTap?(point,self)
        }

    }
    
    @objc public func attachTo(view:UIView) {
        view.addGestureRecognizer(self.gesture!)
    }
    @objc
    func tapLongTapOrDoubleTapGesture(_ recognizer: TapLongTapOrDoubleTapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let (gesture, location) = recognizer.lastRecognizedGestureAndLocation {
                self.tapPoint = location
                switch gesture {
                case .tap:
                    self.tapAction = QCTapLongTapOrDoubleTapGestureTap
                    break
                case .doubleTap:
                    self.tapAction = QCTapLongTapOrDoubleTapGestureDoubleTap
                    break
                case .longTap:
                    self.tapAction = QCTapLongTapOrDoubleTapGestureLongTap
                    break
                case .hold:
                    self.tapAction = QCTapLongTapOrDoubleTapGestureHold
                    break
                }
                self.action(self)
                
                
            }
        default:
            break
        }
    }

}


