//
//  ApplicationExtensions.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import UIKit
import SwifterSwift
import SwiftDate
import AlamofireImage
import Haptica
import ESPullToRefresh
import SafariServices
import EasyTipView
import SwiftyBeaver

extension SwiftyBeaver {
    static var cloud: SBPlatformDestination? {
        return SwiftyBeaver.destinations.first(where: { $0 is SBPlatformDestination } ) as? SBPlatformDestination
    }
}

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
    
    private func message(for error: Error) -> String {
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

extension UIViewController {
    var isRoot: Bool {
        let isRoot = self == UIApplication.shared.keyWindow?.rootViewController
        let isNavigationRoot = navigationController == UIApplication.shared.keyWindow?.rootViewController && navigationController?.viewControllers.count == 1
        return isRoot || isNavigationRoot
    }
    
    var isModal: Bool {        
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController

        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    func setupNavigationBarAppearance() {
        
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 18)!,
                          NSAttributedString.Key.foregroundColor : UIColor.by(.white100)]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.by(.white100)
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)
        
        if isModal || isRoot {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close-icon"), style: .plain, target: self, action: #selector(didTapCloseButton(sender:)))
        }
    }
        
    @objc func didTapCloseButton(sender: Any) {
        closeButtonHandler()
    }
            
    @objc func closeButtonHandler(completion: (() -> Void)? = nil) {
        if isRoot {
            (self as? ApplicationRouterDependantProtocol)?.router.route()
        }
        else {
            (navigationController ?? self).dismiss(animated: true, completion: completion)
        }
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
    func showLoader() {
        self.animationImages = [Int](1...20).compactMap { UIImage(named: "loader-\($0)")?.withRenderingMode(.alwaysTemplate) }
        self.animationDuration = 1.5
        self.startAnimating()
        
    }
    
    func showTutorial() {
        let localizedDragTutorialName = NSLocalizedString("drag-tutorial", comment: "drag-tutorial")
        self.animationImages = [Int](1...86).compactMap { UIImage(named: "\(localizedDragTutorialName)-\($0)") }
        self.animationDuration = 4
        self.startAnimating()
    }
    
    func showStartAnimationWith(duration: TimeInterval) {
        self.animationImages = [Int](1...115).compactMap { UIImage(named: "launch-animation-\($0)") }
        self.animationDuration = duration
        self.animationRepeatCount = 1
        self.startAnimating()
    }
}

extension CGFloat {
    var abs: CGFloat {
        return CGFloat(fabsf(Float(self)))
    }
}

extension UIColor {
    func toColor(_ color: UIColor, ratio: CGFloat) -> UIColor {
        let ratio = max(min(ratio, 1.0), 0)
        switch ratio {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }

            return UIColor(red: CGFloat(r1 + (r2 - r1) * ratio),
                           green: CGFloat(g1 + (g2 - g1) * ratio),
                           blue: CGFloat(b1 + (b2 - b1) * ratio),
                           alpha: CGFloat(a1 + (a2 - a1) * ratio))
        }
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
    
    func update(_ collectionView: UICollectionView, animated: Bool = true, scrollToEnd: Bool = false, section: Int = 0) {
        guard animated else {
            collectionView.reloadData()
            return
        }
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
    func setImage(with url: URL?, placeholderName: String?, renderingMode: UIImage.RenderingMode = .automatic) {
        self.af_cancelImageRequest()
        let placeholderImage = placeholderName != nil ? UIImage(named: placeholderName!)?.withRenderingMode(.alwaysTemplate) : nil
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

extension UICollectionViewCell {
    
}


extension UIView {
    
    func roundTopCorners(radius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.clipsToBounds = false
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.frame
            rectShape.position = self.center
            rectShape.path = UIBezierPath(roundedRect: self.bounds,
                                          byRoundingCorners: [.topLeft , .topRight],
                                          cornerRadii: CGSize(width: radius, height: radius)).cgPath
            self.layer.mask = rectShape
        }
    }
    
}

extension UIButton {
    func setImageToRight() {
        self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
}

typealias TabAppearance = (textColor: UIColor, isHidden: Bool)

extension Locale {
    static var preferredLanguageCode: String {
        return String(Locale.preferredLanguages[0].prefix(2))
    }
}

extension UIViewController {
    func modal(_ viewController: UIViewController?, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let viewController = viewController else { return }
        present(viewController, animated: animated, completion: completion)
    }
    
    func push(_ viewController: UIViewController?, animated: Bool = true) {
        guard let viewController = viewController else { return }
        let navigationController = self.navigationController ?? (self as? UINavigationController)
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func sheet(title: String?, actions: [UIAlertAction], message: String? = nil, preferredStyle: UIAlertController.Style = .actionSheet) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: preferredStyle)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        alertController.addAction(title: NSLocalizedString("Отмена", comment: "Отмена"),
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        modal(alertController, animated: true)
    }
    
    var isAlert: Bool {
        return self.isMember(of: UIAlertController.self)
    }
    
    func dismissIfAlert() {
        if isAlert {
            dismiss(animated: false, completion: nil)
        }
    }
    
    func show(url: String) {
        guard let url = URL(string: url) else { return }
        let browser = SFSafariViewController(url: url)
        browser.modalPresentationStyle = .popover
        modal(browser)
    }
    
    func open(url: String) {
        guard   let urlString = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
                let url = URL(string: urlString),
                UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.canOpenURL(<#T##url: URL##URL#>)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func tip(_ text: String, position: EasyTipView.ArrowPosition, offset: CGPoint? = nil, inset: CGPoint? = nil, for anchor: UIAppearance, within container: UIView?, delegate: EasyTipViewDelegate?, show: Bool = true) -> EasyTipView {
        
        let tip = createTip(text, position: position, offset: offset, inset: inset, delegate: delegate)
        if show {
            if let anchorView = anchor as? UIView {
                tip.show(animated: true, forView: anchorView, withinSuperview: container)
            }
            else if let anchorItem = anchor as? UIBarItem {
                tip.show(animated: true, forItem: anchorItem, withinSuperView: container)
            }
        }
        return tip
    }
        
    private func createTip(_ text: String, position: EasyTipView.ArrowPosition, offset: CGPoint? = nil, inset: CGPoint? = nil, delegate: EasyTipViewDelegate?) -> EasyTipView {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Roboto-Light", size: 14)!
        preferences.drawing.foregroundColor = UIColor.by(.white100)
        preferences.drawing.backgroundColor = UIColor.by(.blue1)
        preferences.drawing.arrowPosition = position
        preferences.drawing.cornerRadius = 8
        preferences.drawing.textAlignment = .left
        
        if let inset = inset {
            preferences.positioning.contentVInset = inset.y
            preferences.positioning.contentHInset = inset.x
        }
        
        if let offset = offset {
            preferences.positioning.bubbleVInset = offset.y
            preferences.positioning.bubbleHInset = offset.x
        }
        
        preferences.animating.showDuration = 0.3
        preferences.animating.dismissDuration = 0.2
        return EasyTipView(text: text, preferences: preferences, delegate: delegate)
    }
}

extension UIView {
    var absoluteFrame: CGRect? {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        return self.superview?.convert(self.frame, to: rootView)
    }
    
    var absoluteBottomY: CGFloat? {
        return absoluteFrame?.maxY
    }
    
    var bottomLineScreenSplitRatio: CGFloat? {
        guard let y = absoluteFrame?.maxY, let screenHeight = UIApplication.shared.keyWindow?.rootViewController?.view.frame.height else { return nil }
        return y / screenHeight
    }
}

extension UISegmentedControl {
    func setSelectedSegmentColor(with foregroundColor: UIColor, font: UIFont, and tintColor: UIColor) {
        if #available(iOS 13.0, *) {
            self.setTitleTextAttributes([.foregroundColor: foregroundColor, .font: font], for: .selected)
            self.setTitleTextAttributes([.foregroundColor: foregroundColor, .font: font], for: .normal)
            self.selectedSegmentTintColor = tintColor
        }
        else {
            self.tintColor = tintColor
        }
    }
    
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor!), for: .normal, barMetrics: .default)
        if #available(iOS 13.0, *) {
            setBackgroundImage(imageWithColor(color: selectedSegmentTintColor!), for: .selected, barMetrics: .default)
        }
        else {
            setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default)
        }
        
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }

    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 36.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor);
        context?.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image
    }
}

extension UICollectionView {
    func fillLayout(columns: Int,
                    itemHeight: CGFloat,
                    horizontalInset: CGFloat,
                    verticalInset: CGFloat,
                    fillVertically: Bool) {
        
        guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let verticalSpace = self.bounds.size.height - verticalInset
        let rows = Int(verticalSpace / itemHeight)
        let fillItemHeight = verticalSpace / CGFloat(rows)
        
        let horizontalSpace = self.bounds.width - horizontalInset * 2
        let fillItemWidth = horizontalSpace / CGFloat(columns)
        
        layout.itemSize = CGSize(width: fillItemWidth, height: fillVertically ? fillItemHeight : itemHeight)
        layout.sectionInset = UIEdgeInsets(horizontal: horizontalInset, vertical: verticalInset)
        layout.minimumLineSpacing = 0
        
    }
}

extension UIWindow {
    func addBlur(with id: Int) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        blurView.frame = self.frame
        blurView.tag = id
        self.addSubview(blurView)
    }
    
    func removeBlur(with id: Int) {
        guard let blurView = self.viewWithTag(id) else { return }
        UIView.animate(withDuration: 0.2, animations: {
            blurView.alpha = 0
        }) { _ in
            blurView.removeFromSuperview()
        }
    }
}

extension Date {
    func replacing(hour: Int, minute: Int) -> Date? {
        return Date(calendar: Calendar.autoupdatingCurrent,
                    timeZone: TimeZone.autoupdatingCurrent,
                    era: self.era,
                    year: self.year,
                    month: self.month,
                    day: self.day,
                    hour: hour,
                    minute: minute,
                    second: 0,
                    nanosecond: 0)
    }
    
    
}

extension Array {
    func groupByKey<K: Hashable>(keyForValue: (_ element: Element) throws -> K) rethrows -> [K: [Element]] {
        var group = [K: [Element]]()
        for value in self {
            let key = try keyForValue(value)
            group[key] = (group[key] ?? []) + [value]
        }
        return group
    }
}

extension UIView {
    func haptic() {
        if #available(iOS 13.0, *) {
            Haptic.impact(.rigid).generate()
        } else {
            Haptic.impact(.heavy).generate()
        }
    }
}

extension UIScrollView {
    var refreshControlHeaderTitleLabel: UILabel? {
        return (header?.animator as? ESRefreshHeaderAnimator)?.titleLabel
    }
    
    var refreshControlHeaderImageView: UIImageView? {
        return (header?.animator as? ESRefreshHeaderAnimator)?.imageView
    }
    
    var refreshControlHeaderIndicatorView: UIActivityIndicatorView? {
        return (header?.animator as? ESRefreshHeaderAnimator)?.indicatorView
    }
    
    var refreshControlFooterTitleLabel: UILabel? {
        return (footer?.animator as? ESRefreshFooterAnimator)?.titleLabel
    }
        
    var refreshControlFooterIndicatorView: UIActivityIndicatorView? {
        return (footer?.animator as? ESRefreshFooterAnimator)?.indicatorView
    }
    
    func setupPullToRefreshAppearance() {
        refreshControlHeaderTitleLabel?.textColor = UIColor.by(.white64)
        refreshControlHeaderIndicatorView?.color = UIColor.by(.white64)
        refreshControlHeaderImageView?.tintColor = UIColor.by(.white64)
        refreshControlHeaderTitleLabel?.font = UIFont(name: "Roboto-Light", size: 13)
        refreshControlFooterTitleLabel?.textColor = UIColor.by(.white64)
        refreshControlFooterIndicatorView?.color = UIColor.by(.white64)
        refreshControlFooterTitleLabel?.font = UIFont(name: "Roboto-Light", size: 13)
        refreshControl = UIRefreshControl(frame: .zero)
        refreshControl?.tintColor = .clear
    }
}

extension ESRefreshHeaderAnimator {
    var titleLabel: UILabel? {
        return self.view.subviews.first { $0 is UILabel } as? UILabel
    }
    
    var imageView: UIImageView? {
        return self.view.subviews.first { $0 is UIImageView } as? UIImageView
    }
    
    var indicatorView: UIActivityIndicatorView? {
        return self.view.subviews.first { $0 is UIActivityIndicatorView } as? UIActivityIndicatorView
    }
}

extension ESRefreshFooterAnimator {
    var titleLabel: UILabel? {
        return self.view.subviews.first { $0 is UILabel } as? UILabel
    }
        
    var indicatorView: UIActivityIndicatorView? {
        return self.view.subviews.first { $0 is UIActivityIndicatorView } as? UIActivityIndicatorView
    }
}

class Once {
  var already: Bool = false

  func run(block: () -> Void) {
    guard !already else { return }

    block()
    already = true
  }
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

extension URL {
    var iconType: IconType {
        return absoluteString.components(separatedBy: ".").last == "svg" ? .vector : .raster
    }
}
