//import UIKit
//
//final class UIBlockingProgressHUD {
//    private static var window: UIWindow? {
//        return UIApplication.shared.windows.first
//    }
//    
//    private static var hud: UIView?
//    
//    static func show() {
//        guard hud == nil else { return }
//        
//        let hudView = UIView(frame: window?.bounds ?? UIScreen.main.bounds)
//        hudView.backgroundColor = UIColor.ypBlack.withAlphaComponent(0.3)
//        
//        let activityIndicator = UIActivityIndicatorView(style: .large)
//        activityIndicator.center = hudView.center
//        activityIndicator.startAnimating()
//        
//        hudView.addSubview(activityIndicator)
//        window?.addSubview(hudView)
//        
//        hud = hudView
//    }
//    
//    static func dismiss() {
//        hud?.removeFromSuperview()
//        hud = nil
//    }
//}

