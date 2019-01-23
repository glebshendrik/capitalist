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
import AlamofireImage

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
        return UIFlowManager.reachPoint(key: className)
    }
}

extension UIColor {
    static var mainNavBarColor: UIColor {
        return UIColor(red: 47 / 255.0,
                       green: 58 / 255.0,
                       blue: 88 / 255.0,
                       alpha: 1.0)
    }
    
    static var navBarColor: UIColor {
        return UIColor(red: 242 / 255.0,
                       green: 245 / 255.0,
                       blue: 254 / 255.0,
                       alpha: 1.0)
    }
}

/// Navigation bar colors for `ColorableNavigationController`, called on `push` & `pop` actions
public protocol NavigationBarColorable: class {
    var navigationTintColor: UIColor? { get }
    var navigationBarTintColor: UIColor? { get }
}

public extension NavigationBarColorable {
    var navigationTintColor: UIColor? { return nil }
}

/**
 UINavigationController with different colors support of UINavigationBar.
 To use it please adopt needed child view controllers to protocol `NavigationBarColorable`.
 - note: Don't forget to set initial tint and barTint colors
 */
open class ColorableNavigationController: UINavigationController {
    private var previousViewController: UIViewController? {
        guard viewControllers.count > 1 else {
            return nil
        }
        return viewControllers[viewControllers.count - 2]
    }
    
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let colors = viewController as? NavigationBarColorable {
            self.setNavigationBarColors(colors)
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override open func popViewController(animated: Bool) -> UIViewController? {
        if let colors = self.previousViewController as? NavigationBarColorable {
            self.setNavigationBarColors(colors)
        }
        
        // Let's start pop action or we can't get transitionCoordinator()
        let popViewController = super.popViewController(animated: animated)
        
        // Secure situation if user cancelled transition
        transitionCoordinator?.animate(alongsideTransition: nil, completion: { [weak self] (context) in
            guard let colors = self?.topViewController as? NavigationBarColorable else { return }
            self?.setNavigationBarColors(colors)
        })
        
        return popViewController
    }
    
    private func setNavigationBarColors(_ colors: NavigationBarColorable) {
        if let tintColor = colors.navigationTintColor {
            self.navigationBar.tintColor = tintColor
        }
        
        self.navigationBar.barTintColor = colors.navigationBarTintColor
    }
}

extension UIView {
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {
        
        var borders = [UIView]()
        
        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }
        
        
        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }
        
        return borders
    }
}

extension UIImageView {
    func showCoinLoader() {
        self.animationImages = [Int](1...16).compactMap { UIImage(named: "coin-loader-\($0)") }
        self.animationDuration = 1
        self.startAnimating()
    }
    
    func showLoader() {
        self.animationImages = [Int](1...20).compactMap { UIImage(named: "loader-\($0)") }
        self.animationDuration = 1.5
        self.startAnimating()
    }
}

extension UIViewController {
    func set(_ activityIndicator: UIView, hidden: Bool, animated: Bool = true) {
        guard animated else {
            activityIndicator.isHidden = hidden
            return
        }
        UIView.transition(with: activityIndicator,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
                            activityIndicator.isHidden = hidden
        })
    }
    
    func update(_ collectionView: UICollectionView, scrollToEnd: Bool = false, section: Int = 0) {
        guard let collectionViewDataSource = self as? UICollectionViewDataSource else {
            return
        }
        
        let numberOfItems = collectionViewDataSource.collectionView(collectionView, numberOfItemsInSection: section)
        collectionView.performBatchUpdates({
            let indexSet = IndexSet(integersIn: 0...0)
            collectionView.reloadSections(indexSet)
        }, completion: { _ in
            if scrollToEnd && numberOfItems > 0 {
                collectionView.scrollToItem(at: IndexPath(item: numberOfItems - 1, section: 0),
                                            at: .right,
                                            animated: true)
            }
        })
    }
}

extension UIImageView {
    func setImage(with url: URL?, placeholderName: String, renderingMode: UIImage.RenderingMode = .automatic) {
        self.af_cancelImageRequest()
        let placeholderImage = UIImage(named: placeholderName)?.withRenderingMode(.alwaysTemplate)
        if let imageURL = url {
            self.af_setImage(withURL: imageURL,
                             placeholderImage: placeholderImage,
                             filter: DynamicImageFilter("TemplateImageFilter") { image in
                                return image.withRenderingMode(renderingMode)
                             },
                             progress: nil,
                             progressQueue: DispatchQueue.main,
                             imageTransition: UIImageView.ImageTransition.crossDissolve(0.3),
                             runImageTransitionIfCached: false,
                             completion: nil)
        }
        else {
            self.image = placeholderImage
        }
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
