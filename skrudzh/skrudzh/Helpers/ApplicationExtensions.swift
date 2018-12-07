//
//  ApplicationExtensions.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import UIKit
import SwifterSwift
import SwiftDate

extension UITableView {
    func reloadData(with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}

extension String {
    var decimalFloat: Float? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        return formatter.number(from: self)?.floatValue
    }
    
    var decimalString: String {
        if let float = decimalFloat {
            return String(describing: float)
        }
        return self
    }
    
    var twoFractionDigits: String {
        let styler = NumberFormatter()
        styler.minimumFractionDigits = 2
        styler.maximumFractionDigits = 2
        styler.numberStyle = .decimal
        let converter = NumberFormatter()
        converter.decimalSeparator = "."
        if let result = converter.number(from: self) {
            return styler.string(for: result) ?? ""
        }
        return ""
    }
}

extension Float {
    var twoFractionDigits: String {
        let styler = NumberFormatter()
        styler.minimumFractionDigits = 2
        styler.maximumFractionDigits = 2
        styler.numberStyle = .decimal
        let converter = NumberFormatter()
        converter.decimalSeparator = "."
        let string = String(describing: self)
        if let result = converter.number(from: string) {
            return styler.string(for: result) ?? ""
        }
        return ""
    }
}

extension String {
    
    func isLastCharacterWhiteSpace() -> Bool {
        guard let last = self.unicodeScalars.last else {
            return false
        }
        return CharacterSet.whitespaces.contains(last)
    }
}

extension Data {
    func hexString() -> String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

extension UIViewController {
    var canPresentViewController: Bool {
        return self.presentedViewController == nil
    }
    
    var concreteViewController: UIViewController {
        if let navVC = self as? UINavigationController,
            let navRootVC = navVC.viewControllers.first {
            return navRootVC
        }
        return self
    }
    
    var topmostPresentedViewController: UIViewController {
        if let tabVC = self as? UITabBarController,
            let selectedVC = tabVC.selectedViewController {
            return selectedVC.topmostPresentedViewController
        } else if let navVC = self as? UINavigationController,
            let selectedVC = navVC.viewControllers.last {
            return selectedVC.topmostPresentedViewController
        } else if let presentedVC = self.presentedViewController {
            return presentedVC.topmostPresentedViewController
        } else {
            return self
        }
    }
}

extension UIViewController {
    
    func handleCommonNetworkError(error: Error) {
        guard let messagePresenterManager = (self as? UIMessagePresenterManagerDependantProtocol)?.messagePresenterManager else { return }
        messagePresenterManager.show(navBarMessage: message(for: error), theme: .error)
    }
    
    fileprivate func message(for error: Error) -> String {
        switch error {
        case APIRequestError.noConnection:
            return "No Internet Connection"
        case APIRequestError.timedOut:
            return "Request timed out, please try again"
        default:
            return "Server Error"
        }
    }
}

extension UIApplication {
    static func cleanupBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

extension UILocalNotification {
    var identifier: String? {
        return self.userInfo?[NotificationInfoKeys.NotificationId] as? String
    }
}

struct ToolTip {
    struct ItemDetails {
        static let dismissDuration = 0.3
        static let maxWidth: CGFloat = 270
    }
}

// MARK: - Application Fonts
enum FontType {
    case Normal, Bold, Light
    
    private var fontExtension: String {
        switch self {
        case .Bold: return "Bold"
        case .Light: return "Light"
        default: return ""
        }
    }
    
    var helveticaFontName: String {
        switch self {
        case .Normal: return "HelveticaNeue"
        default:
            return "HelveticaNeue-\(self.fontExtension)"
        }
    }
    
    var alwaysForeverFontName: String {
        switch self {
        case .Normal: return "AlwaysForever"
        case .Light: assert(true, "AlwaysForever-Light does not included!"); return ""
        default:
            return "AlwaysForever-\(self.fontExtension)"
        }
    }
    
    
}

extension UIFont {
    class func applicationFontHelvetica(ofType type: FontType = .Normal, size: CGFloat = 16.0) -> UIFont {
        return UIFont(name: type.helveticaFontName, size: size)!
    }
}

extension Date {
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    
    var ageMonths: Int {
        return Calendar.current.dateComponents([.month], from: self, to: Date()).month!
    }
    
    var ageDays: Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day!
    }
    
//    var ageVerbose: String {
//        let components: [Calendar.Component] = [.year, .month, .day, .hour]
//        let diff = (Date() - self).in(components).filter { $0.value > 0 }
//        if diff.count == 0 { return "Just created" }
//        return components
//            .compactMap {
//                guard let value = diff[$0] else { return nil }
//                switch $0 {
//                case .year:
//                    return "\(value) years"
//                case .month:
//                    return "\(value) months"
//                case .day:
//                    return "\(value) days"
//                case .hour:
//                    return "\(value) hours"
//                default:
//                    return nil
//                }
//            }
//            .joined(separator: ", ")
//    }
}

extension UILabel {
    func hidingSet(text: String?) {
        isHidden = text == nil
        self.text = text ?? ""
    }
}

extension String {
    init?(from string: String?, with displayName: String? = nil) {
        if let string = string, let displayName = displayName {
            self = "\(string) \(displayName)"
        }
        else if let string = string {
            self = String(describing: string)
        }
        else {
            return nil
        }
    }
    
    init?(from integer: Int?, with displayName: String? = nil) {
        if let integer = integer, let displayName = displayName {
            self = "\(integer) \(displayName)"
        }
        else if let integer = integer {
            self = String(describing: integer)
        }
        else {
            return nil
        }
    }
    
    init?(from float: Float?, with displayName: String? = nil) {
        if let float = float, let displayName = displayName {
            self = "\(float) \(displayName)"
        }
        else if let float = float {
            self = String(describing: float)
        }
        else {
            return nil
        }
    }
    
    init?(from stringsArray: [String]?) {
        guard let stringsArray = stringsArray, !stringsArray.isEmpty else { return nil }
        self = stringsArray.joined(separator: ", ")
    }
}

extension Bool {
    init(from bool: Bool?) {
        if let bool = bool {
            self = bool
        }
        else {
            self = false
        }
    }
}

extension Array where Element == String {
    init?(from string: String?) {
        if let array = string?.components(separatedBy: ", ") {
            self = array
        }
        else {
            self = []
        }
    }
}

extension JSONEncoder {
    func encodeJSONObject<T: Encodable>(_ value: T, options opt: JSONSerialization.ReadingOptions = []) throws -> [String : Any] {
        let data = try encode(value)
        return try JSONSerialization.jsonObject(with: data, options: opt) as! [String : Any]
    }
}

extension JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, withJSONObject object: Any, options opt: JSONSerialization.WritingOptions = []) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: object, options: opt)
        return try decode(T.self, from: data)
    }
}

extension UIViewController {
    var className: String {
        return String(describing: type(of: self))
    }
    
    var didRunBefore: Bool {
        return UIFlowManager.reachedPoint(key: className)
    }
}
