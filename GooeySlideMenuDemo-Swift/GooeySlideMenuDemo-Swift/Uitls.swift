//
//  Uitls.swift
//  GooeySlideMenuDemo-Swift
//  
//  Created by CoderSamz on 2022.
// 
    

import Foundation
import UIKit

extension UIApplication {
    var mainWindow: UIWindow? {
        get {
            if #available(iOS 13, *) {
                for scence in self.connectedScenes {
                    if scence.activationState == UIScene.ActivationState.foregroundActive {
                        if let windowScence = scence as? UIWindowScene {
                            for window in windowScence.windows {
                                if window.isKeyWindow {
                                    return window
                                }
                            }
                        }
                    }
                }
            } else {
                return self.keyWindow
            }
            return nil
        }
    }
    
}
