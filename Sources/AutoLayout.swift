//
//  AutoLayout.swift
//  AutoLayout <https://github.com/liam-i/AutoLayout>
//
//  Created by Liam on 2019/8/6.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

// MARK: - AutoLayout
public struct AutoLayout<ViewType> {
    private let view: ViewType

    public init(_ view: ViewType) {
        self.view = view
    }
}

extension AutoLayout where ViewType: UIView {
    public func constraints(_ closure: (LayoutMarker<ViewType>) -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false

        let marker = LayoutMarker(view)
        closure(marker)
        marker.activate()
    }

    public var top: NSLayoutYAxisAnchor { view.topAnchor }
    public var bottom: NSLayoutYAxisAnchor { view.bottomAnchor }
    public var leading: NSLayoutXAxisAnchor { view.leadingAnchor }
    public var trailing: NSLayoutXAxisAnchor { view.trailingAnchor }
    public var centerX: NSLayoutXAxisAnchor { view.centerXAnchor }
    public var centerY: NSLayoutYAxisAnchor { view.centerYAnchor }
    public var width: NSLayoutDimension { view.widthAnchor }
    public var height: NSLayoutDimension { view.heightAnchor }

    public var safeLayout: UILayoutGuide {
        guard #available(iOS 11.0, *) else { return view.layoutMarginsGuide }
        return view.safeAreaLayoutGuide
    }
}

// MARK: - LayoutCompatible
public protocol LayoutCompatible {
    associatedtype CompatibleAutoLayout

    var lp: CompatibleAutoLayout { get }
}

extension LayoutCompatible {
    public var lp: AutoLayout<Self> { AutoLayout(self) }
}

extension UIView: LayoutCompatible {}

// MARK: - LayoutAnchor
public protocol LayoutAnchor {}

extension UIView: LayoutAnchor {}
extension NSLayoutXAxisAnchor: LayoutAnchor {}
extension NSLayoutYAxisAnchor: LayoutAnchor {}
extension NSLayoutDimension: LayoutAnchor {}
extension UILayoutGuide: LayoutAnchor {}
extension CGSize: LayoutAnchor {}

// MARK: - LayoutOptions
public enum LayoutOptions {
    case constant(CGFloat)
    /// 只对`NSLayoutDimension(widthAnchor/heightAnchor)`生效
    case multiplier(CGFloat)
    case priority(UILayoutPriority)
}

/// 将 Integer 和 Float 的字面量自动转为 UILayoutPriority 类型
extension UILayoutPriority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public typealias FloatLiteralType = Float
    public typealias IntegerLiteralType = Int

    public init(floatLiteral value: Float) {
        self.init(rawValue: value)
    }

    public init(integerLiteral value: Int) {
        self.init(rawValue: Float(value))
    }
}

extension NSLayoutConstraint {
    /// Returns a value that is offset the specified distance from this value.
    public func advancedPriority(by n: Float) -> UILayoutPriority {
        UILayoutPriority(rawValue: priority.rawValue + n)
    }
}

// MARK: - LayoutMarker
public class LayoutMarker<ViewType> {
    public let view: ViewType

    public init(_ view: ViewType) {
        self.view = view
    }

    private enum Attributes { case top, bottom, leading, trailing, centerX, centerY, center, width, height, edges, size }
    private var attributes = Set<Attributes>()
    private var allConstraints: [NSLayoutConstraint] = []
}

extension LayoutMarker where ViewType: UIView {
    public var top: LayoutMarker { add(.top) }
    public var bottom: LayoutMarker { add(.bottom) }
    public var leading: LayoutMarker { add(.leading) }
    public var trailing: LayoutMarker { add(.trailing) }
    public var centerX: LayoutMarker { add(.centerX) }
    public var centerY: LayoutMarker { add(.centerY) }
    public var center: LayoutMarker { add(.center) }
    public var width: LayoutMarker { add(.width) }
    public var height: LayoutMarker { add(.height) }
    public var edges: LayoutMarker { add(.edges) }
    public var size: LayoutMarker { add(.size) }

    @discardableResult
    public func equal(to anchor: LayoutAnchor, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        equal(to: anchor, options: LayoutOptionsInfo(constant: constant), type: .equal)
    }

    @discardableResult
    public func equal(to anchor: LayoutAnchor, options: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: anchor, options: LayoutOptionsInfo(options), type: .equal)
    }

    @discardableResult
    public func greaterOrEqual(to anchor: LayoutAnchor, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        equal(to: anchor, options: LayoutOptionsInfo(constant: constant), type: .greater)
    }

    @discardableResult
    public func greaterOrEqual(to anchor: LayoutAnchor, options: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: anchor, options: LayoutOptionsInfo(options), type: .greater)
    }

    @discardableResult
    public func lessOrEqual(to anchor: LayoutAnchor, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        equal(to: anchor, options: LayoutOptionsInfo(constant: constant), type: .less)
    }

    @discardableResult
    public func lessOrEqual(to anchor: LayoutAnchor, options: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: anchor, options: LayoutOptionsInfo(options), type: .less)
    }

    @discardableResult
    public func equal(toConstant: CGFloat) -> [NSLayoutConstraint] {
        equal(to: nil, options: LayoutOptionsInfo(constant: toConstant), type: .equal)
    }

    @discardableResult
    public func equal(toOptions: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: nil, options: LayoutOptionsInfo(toOptions), type: .equal)
    }

    @discardableResult
    public func greaterOrEqual(toConstant: CGFloat) -> [NSLayoutConstraint] {
        equal(to: nil, options: LayoutOptionsInfo(constant: toConstant), type: .greater)
    }

    @discardableResult
    public func greaterOrEqual(toOptions: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: nil, options: LayoutOptionsInfo(toOptions), type: .greater)
    }

    @discardableResult
    public func lessOrEqual(toConstant: CGFloat) -> [NSLayoutConstraint] {
        equal(to: nil, options: LayoutOptionsInfo(constant: toConstant), type: .less)
    }

    @discardableResult
    public func lessOrEqual(toOptions: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: nil, options: LayoutOptionsInfo(toOptions), type: .less)
    }

    fileprivate func activate() {
        assert(allConstraints.isEmpty == false)
        NSLayoutConstraint.activate(allConstraints)
    }

    private func equal(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> [NSLayoutConstraint] {
        //assert(view.superview != nil, "superview is nil.")
        assert(attributes.isEmpty == false, "ambiguous constraints.")

        let constraints = attributes.reduce(into: [NSLayoutConstraint]()) {
            switch $1 {
            case .top:      $0.append(makeTop(to: anchor, options: options, type: type))
            case .bottom:   $0.append(makeBottom(to: anchor, options: options, type: type))
            case .leading:  $0.append(makeLeading(to: anchor, options: options, type: type))
            case .trailing: $0.append(makeTrailing(to: anchor, options: options, type: type))
            case .centerX:  $0.append(makeCenterX(to: anchor, options: options, type: type))
            case .centerY:  $0.append(makeCenterY(to: anchor, options: options, type: type))
            case .width:    $0.append(makeWidth(to: anchor, options: options, type: type))
            case .height:   $0.append(makeHeight(to: anchor, options: options, type: type))
            case .center:   $0.append(contentsOf: makeCenter(to: anchor, options: options, type: type))
            case .edges:    $0.append(contentsOf: makeEdges(to: anchor, options: options, type: type))
            case .size:     $0.append(contentsOf: makeSize(to: anchor, options: options, type: type))
            }
        }

        attributes.removeAll()
        allConstraints.append(contentsOf: constraints)
        return constraints
    }

    private func makeTop(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.topAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.topAnchor
            case let to as NSLayoutYAxisAnchor: return to
            case let to as UILayoutGuide:       return to.topAnchor
            default: fatalError("Only be `UIView`、`NSLayoutYAxisAnchor` or `UILayoutGuide`")
            }
        }(), options: options)
    }

    private func makeBottom(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.bottomAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.bottomAnchor
            case let to as NSLayoutYAxisAnchor: return to
            case let to as UILayoutGuide:       return to.bottomAnchor
            default: fatalError("Only be `UIView`、`NSLayoutYAxisAnchor` or `UILayoutGuide`")
            }
        }(), options: options.negated)
    }

    private func makeLeading(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.leadingAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.leadingAnchor
            case let to as NSLayoutXAxisAnchor: return to
            case let to as UILayoutGuide:       return to.leadingAnchor
            default: fatalError("Only be `UIView`、`NSLayoutXAxisAnchor` or `UILayoutGuide`")
            }
        }(), options: options)
    }

    private func makeTrailing(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.trailingAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.trailingAnchor
            case let to as NSLayoutXAxisAnchor: return to
            case let to as UILayoutGuide:       return to.trailingAnchor
            default: fatalError("Only be `UIView`、`NSLayoutXAxisAnchor` or `UILayoutGuide`")
            }
        }(), options: options.negated)
    }

    private func makeCenter(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> [NSLayoutConstraint] {
        [makeCenterX(to: anchor, options: options, type: type),
         makeCenterY(to: anchor, options: options, type: type)]
    }

    private func makeCenterX(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.centerXAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.centerXAnchor
            case let to as NSLayoutXAxisAnchor: return to
            case let to as UILayoutGuide:       return to.centerXAnchor
            default: fatalError("Only be `UIView`、`NSLayoutXAxisAnchor` or `UILayoutGuide`")
            }
        }(), options: options)
    }

    private func makeCenterY(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.centerYAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.centerYAnchor
            case let to as NSLayoutYAxisAnchor: return to
            case let to as UILayoutGuide:       return to.centerYAnchor
            default: fatalError("Only be `UIView`、`NSLayoutYAxisAnchor` or `UILayoutGuide`")
            }
        }(), options: options)
    }

    private func makeWidth(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.widthAnchor, to: anchor == nil ? nil : {
            switch anchor ?? view.superview {
            case let to as UIView:            return to.widthAnchor
            case let to as NSLayoutDimension: return to
            case let to as UILayoutGuide:     return to.widthAnchor
            default: fatalError("Only be `UIView`、`NSLayoutDimension` or `UILayoutGuide`")
            }
        }(), options: options)
    }

    private func makeHeight(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.heightAnchor, to: anchor == nil ? nil : {
            switch anchor ?? view.superview {
            case let to as UIView:            return to.heightAnchor
            case let to as NSLayoutDimension: return to
            case let to as UILayoutGuide:     return to.heightAnchor
            default: fatalError("Only be `UIView`、`NSLayoutDimension` or `UILayoutGuide`")
            }
        }(), options: options)
    }

    private func makeEdges(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> [NSLayoutConstraint] {
        let optionsNegated = options.negated
        switch anchor ?? view.superview {
        case let to as UIView:
            return [type.constraint(for: view.topAnchor, to: to.topAnchor, options: options),
                    type.constraint(for: view.bottomAnchor, to: to.bottomAnchor, options: optionsNegated),
                    type.constraint(for: view.leadingAnchor, to: to.leadingAnchor, options: options),
                    type.constraint(for: view.trailingAnchor, to: to.trailingAnchor, options: optionsNegated)]
        case let to as UILayoutGuide:
            return [type.constraint(for: view.topAnchor, to: to.topAnchor, options: options),
                    type.constraint(for: view.bottomAnchor, to: to.bottomAnchor, options: optionsNegated),
                    type.constraint(for: view.leadingAnchor, to: to.leadingAnchor, options: options),
                    type.constraint(for: view.trailingAnchor, to: to.trailingAnchor, options: optionsNegated)]
        default:
            fatalError("Only be `UIView` or `UILayoutGuide`")
        }
    }

    private func makeSize(to anchor: LayoutAnchor?, options: LayoutOptionsInfo, type: ConstraintType) -> [NSLayoutConstraint] {
        var toWidthAnchor: NSLayoutDimension?
        var toHeightAnchor: NSLayoutDimension?
        var widthOptions = options
        var heightOptions = options

        switch anchor ?? view.superview {
        case let to as UIView:
            if anchor != nil {
                toWidthAnchor = to.widthAnchor
                toHeightAnchor = to.heightAnchor
            }
        case let to as CGSize:
            widthOptions.setConstant(to.width)
            heightOptions.setConstant(to.height)
        case let to as NSLayoutDimension:
            toWidthAnchor = to
            toHeightAnchor = to
        case let to as UILayoutGuide:
            toWidthAnchor = to.widthAnchor
            toHeightAnchor = to.heightAnchor
        default:
            fatalError("Only be `UIView`、`CGSize`、`NSLayoutDimension` or `UILayoutGuide`")
        }
        return [type.constraint(for: view.widthAnchor, to: toWidthAnchor, options: widthOptions),
                type.constraint(for: view.heightAnchor, to: toHeightAnchor, options: heightOptions)]
    }

    private func add(_ attr: Attributes) -> Self {
        attributes.insert(attr)
        return self
    }
}

// MARK: - ConstraintType
private enum ConstraintType {
    case equal, greater, less

    func constraint(for anchor: NSLayoutYAxisAnchor, to other: NSLayoutYAxisAnchor, options: LayoutOptionsInfo) -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        switch self {
        case .equal:    constraint = anchor.constraint(equalTo: other, constant: options.constant)
        case .greater:  constraint = anchor.constraint(greaterThanOrEqualTo: other, constant: options.constant)
        case .less:     constraint = anchor.constraint(lessThanOrEqualTo: other, constant: options.constant)
        }
        options.withPriority { constraint.priority = $0 }
        return constraint
    }

    func constraint(for anchor: NSLayoutXAxisAnchor, to other: NSLayoutXAxisAnchor, options: LayoutOptionsInfo) -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        switch self {
        case .equal:    constraint = anchor.constraint(equalTo: other, constant: options.constant)
        case .greater:  constraint = anchor.constraint(greaterThanOrEqualTo: other, constant: options.constant)
        case .less:     constraint = anchor.constraint(lessThanOrEqualTo: other, constant: options.constant)
        }
        options.withPriority { constraint.priority = $0 }
        return constraint
    }

    func constraint(for anchor: NSLayoutDimension, to other: NSLayoutDimension?, options: LayoutOptionsInfo) -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        if let other = other {
            switch self {
            case .equal:    constraint = anchor.constraint(equalTo: other, multiplier: options.multiplier, constant: options.constant)
            case .greater:  constraint = anchor.constraint(greaterThanOrEqualTo: other, multiplier: options.multiplier, constant: options.constant)
            case .less:     constraint = anchor.constraint(lessThanOrEqualTo: other, multiplier: options.multiplier, constant: options.constant)
            }
        } else {
            switch self {
            case .equal:    constraint = anchor.constraint(equalToConstant: options.constant)
            case .greater:  constraint = anchor.constraint(greaterThanOrEqualToConstant: options.constant)
            case .less:     constraint = anchor.constraint(lessThanOrEqualToConstant: options.constant)
            }
        }
        options.withPriority { constraint.priority = $0 }
        return constraint
    }
}

// MARK: - LayoutOptionsInfo
private struct LayoutOptionsInfo {
    private(set) var constant: CGFloat = 0.0
    private(set) var multiplier: CGFloat = 1.0
    private(set) var priority: UILayoutPriority?

    init(constant: CGFloat) {
        self.constant = constant
    }

    init(_ items: [LayoutOptions]) {
        for item in items {
            switch item {
            case .constant(let value): constant = value
            case .multiplier(let value): multiplier = value
            case .priority(let value): priority = value
            }
        }
    }

    mutating func setConstant(_ newValue: CGFloat) {
        constant = newValue
    }

    func withPriority(_ populator: (UILayoutPriority) -> Void) {
        guard let priority = priority else { return }
        populator(priority)
    }

    var negated: LayoutOptionsInfo {
        if constant == 0.0 {
            return self
        }

        var new = self
        new.setConstant(-constant)
        return new
    }
}

//    public func update(constant: CGFloat) {
//        assert(attributes.isEmpty == false, "ambiguous constraints.")
//
//        guard let superview = view.superview else { return assert(false, "superview is nil.") }
//
//        func update(with attr: NSLayoutConstraint.Attribute, constant: CGFloat) {
//            let block: (NSLayoutConstraint) -> Bool = {
//                if $0.firstAttribute == attr {
//                    if let first = $0.firstItem as? UIView, first == self.view { return true }
//                    if let second = $0.secondItem as? UIView, second == self.view { return true }
//                }
//                return false
//            }
//
//            if let index = view.constraints.firstIndex(where: block) {
//                view.constraints[index].constant = constant
//            } else if let index = superview.constraints.firstIndex(where: block) {
//                superview.constraints[index].constant = constant
//            } else {
//                assert(false, "constraint(\(attr.rawValue)) not found.")
//            }
//        }
//
//        attributes.forEach {
//            switch $0 {
//            case .top:
//                update(with: .top, constant: constant)
//            case .bottom:
//                update(with: .bottom, constant: -constant)
//            case .leading:
//                update(with: .leading, constant: constant)
//            case .trailing:
//                update(with: .trailing, constant: -constant)
//            case .centerX:
//                update(with: .centerX, constant: constant)
//            case .centerY:
//                update(with: .centerY, constant: constant)
//            case .width:
//                update(with: .width, constant: constant)
//            case .height:
//                update(with: .height, constant: constant)
//            case .edges:
//                update(with: .top, constant: constant)
//                update(with: .bottom, constant: -constant)
//                update(with: .leading, constant: constant)
//                update(with: .trailing, constant: -constant)
//            case .size:
//                update(with: .width, constant: constant)
//                update(with: .height, constant: constant)
//            }
//        }
//        attributes.removeAll()
//    }

//      open class NSLayoutXAxisAnchor : NSLayoutAnchor<NSLayoutXAxisAnchor> {
//          open func anchorWithOffset(to otherAnchor: NSLayoutXAxisAnchor) -> NSLayoutDimension
//      }
//      open class NSLayoutYAxisAnchor : NSLayoutAnchor<NSLayoutYAxisAnchor> {
//          open func anchorWithOffset(to otherAnchor: NSLayoutYAxisAnchor) -> NSLayoutDimension
//      }
//      extension NSLayoutXAxisAnchor {
//          @available(iOS 11.0, *)
//          open func constraint(equalToSystemSpacingAfter anchor: NSLayoutXAxisAnchor, multiplier: CGFloat) -> NSLayoutConstraint
//          @available(iOS 11.0, *)
//          open func constraint(greaterThanOrEqualToSystemSpacingAfter anchor: NSLayoutXAxisAnchor, multiplier: CGFloat) -> NSLayoutConstraint
//          @available(iOS 11.0, *)
//          open func constraint(lessThanOrEqualToSystemSpacingAfter anchor: NSLayoutXAxisAnchor, multiplier: CGFloat) -> NSLayoutConstraint
//      }
//      extension NSLayoutYAxisAnchor {
//          @available(iOS 11.0, *)
//          open func constraint(equalToSystemSpacingBelow anchor: NSLayoutYAxisAnchor, multiplier: CGFloat) -> NSLayoutConstraint
//          @available(iOS 11.0, *)
//          open func constraint(greaterThanOrEqualToSystemSpacingBelow anchor: NSLayoutYAxisAnchor, multiplier: CGFloat) -> NSLayoutConstraint
//          @available(iOS 11.0, *)
//          open func constraint(lessThanOrEqualToSystemSpacingBelow anchor: NSLayoutYAxisAnchor, multiplier: CGFloat) -> NSLayoutConstraint
//      }
