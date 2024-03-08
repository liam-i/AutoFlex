//
//  AutoFlex.swift
//  AutoFlex <https://github.com/liam-i/AutoFlex>
//
//  Created by Liam on 2019/8/6.
//  Copyright © 2019 Liam. All rights reserved.
//

#if canImport(UIKit)
import UIKit
public typealias LayoutView = UIView
public typealias LayoutGuide = UILayoutGuide
public typealias LayoutPriority = UILayoutPriority
#else
import AppKit
public typealias LayoutView = NSView
public typealias LayoutGuide = NSLayoutGuide
public typealias LayoutPriority = NSLayoutConstraint.Priority
#endif

// MARK: - AutoFlex
public struct AutoFlex<ExtendedViewType> {
    private let view: ExtendedViewType

    public init(_ view: ExtendedViewType) {
        self.view = view
    }
}

public protocol AutoFlexExtended {
    associatedtype ViewType
    var af: AutoFlex<ViewType> { get }
}

extension AutoFlexExtended {
    public var af: AutoFlex<Self> { AutoFlex(self) }
}

extension LayoutView: AutoFlexExtended {}

extension AutoFlex where ExtendedViewType: LayoutView {
    public func constraints(_ closure: (LayoutMarker<ExtendedViewType>) -> Void) {
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
    public var firstBaseline: NSLayoutYAxisAnchor { view.firstBaselineAnchor }
    public var lastBaseline: NSLayoutYAxisAnchor { view.lastBaselineAnchor }
    public var safeGuide: LayoutGuide { view.safeAreaLayoutGuide }
}

// MARK: - LayoutAnchor
public protocol LayoutAnchor {}

extension LayoutView: LayoutAnchor {}
extension NSLayoutXAxisAnchor: LayoutAnchor {}
extension NSLayoutYAxisAnchor: LayoutAnchor {}
extension NSLayoutDimension: LayoutAnchor {}
extension LayoutGuide: LayoutAnchor {}
extension CGSize: LayoutAnchor {}

// MARK: - LayoutOptions
public enum LayoutOptions {
    case constant(CGFloat)
    /// 只对`NSLayoutDimension(widthAnchor/heightAnchor)`生效
    case multiplier(CGFloat)
    case priority(LayoutPriority)
}

/// 将 Integer 和 Float 的字面量自动转为 UILayoutPriority 类型
/// ```
///     let prioritey: UILayoutPriority = 1000
/// ```
extension LayoutPriority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
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
    public func advancedPriority(by n: Float) -> LayoutPriority {
        LayoutPriority(rawValue: priority.rawValue + n)
    }
}

// MARK: - LayoutMarker
public class LayoutMarker<ViewType> {
    public let view: ViewType

    public init(_ view: ViewType) {
        self.view = view
    }

    private enum Attribute { case top, bottom, leading, trailing, centerX, centerY, center, width, height, edges, size, firstBaseline, lastBaseline }
    private var attributes = Set<Attribute>()
    private var allConstraints: [NSLayoutConstraint] = []
}

extension LayoutMarker where ViewType: LayoutView {
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
    public var firstBaseline: LayoutMarker { add(.firstBaseline) }
    public var lastBaseline: LayoutMarker { add(.lastBaseline) }

    @discardableResult
    public func equal(to anchor: LayoutAnchor, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        equal(to: anchor, info: LayoutOptionsInfo(constant: constant), relation: .equal)
    }

    @discardableResult
    public func equal(to anchor: LayoutAnchor, options: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: anchor, info: LayoutOptionsInfo(options), relation: .equal)
    }

    @discardableResult
    public func equal(toConstant: CGFloat) -> [NSLayoutConstraint] {
        equal(to: nil, info: LayoutOptionsInfo(constant: toConstant), relation: .equal)
    }

    @discardableResult
    public func equal(toOptions: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: nil, info: LayoutOptionsInfo(toOptions), relation: .equal)
    }

    @discardableResult
    public func greaterOrEqual(to anchor: LayoutAnchor, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        equal(to: anchor, info: LayoutOptionsInfo(constant: constant), relation: .greater)
    }

    @discardableResult
    public func greaterOrEqual(to anchor: LayoutAnchor, options: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: anchor, info: LayoutOptionsInfo(options), relation: .greater)
    }

    @discardableResult
    public func greaterOrEqual(toConstant: CGFloat) -> [NSLayoutConstraint] {
        equal(to: nil, info: LayoutOptionsInfo(constant: toConstant), relation: .greater)
    }

    @discardableResult
    public func greaterOrEqual(toOptions: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: nil, info: LayoutOptionsInfo(toOptions), relation: .greater)
    }

    @discardableResult
    public func lessOrEqual(to anchor: LayoutAnchor, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        equal(to: anchor, info: LayoutOptionsInfo(constant: constant), relation: .less)
    }

    @discardableResult
    public func lessOrEqual(to anchor: LayoutAnchor, options: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: anchor, info: LayoutOptionsInfo(options), relation: .less)
    }

    @discardableResult
    public func lessOrEqual(toConstant: CGFloat) -> [NSLayoutConstraint] {
        equal(to: nil, info: LayoutOptionsInfo(constant: toConstant), relation: .less)
    }

    @discardableResult
    public func lessOrEqual(toOptions: LayoutOptions...) -> [NSLayoutConstraint] {
        equal(to: nil, info: LayoutOptionsInfo(toOptions), relation: .less)
    }

    fileprivate func activate() {
        assert(allConstraints.isEmpty == false)
        NSLayoutConstraint.activate(allConstraints)
    }

    private func equal(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> [NSLayoutConstraint] {
        //assert(view.superview != nil, "superview is nil.")

        let constraints = attributes.reduce(into: [NSLayoutConstraint]()) {
            switch $1 {
            case .top:           $0.append(makeTop(to: anchor, info: info, relation: relation))
            case .bottom:        $0.append(makeBottom(to: anchor, info: info, relation: relation))
            case .leading:       $0.append(makeLeading(to: anchor, info: info, relation: relation))
            case .trailing:      $0.append(makeTrailing(to: anchor, info: info, relation: relation))
            case .centerX:       $0.append(makeCenterX(to: anchor, info: info, relation: relation))
            case .centerY:       $0.append(makeCenterY(to: anchor, info: info, relation: relation))
            case .width:         $0.append(makeWidth(to: anchor, info: info, relation: relation))
            case .height:        $0.append(makeHeight(to: anchor, info: info, relation: relation))
            case .center:        $0.append(contentsOf: makeCenter(to: anchor, info: info, relation: relation))
            case .edges:         $0.append(contentsOf: makeEdges(to: anchor, info: info, relation: relation))
            case .size:          $0.append(contentsOf: makeSize(to: anchor, info: info, relation: relation))
            case .firstBaseline: $0.append(makeFirstBaseline(to: anchor, info: info, relation: relation))
            case .lastBaseline:  $0.append(makeLastBaseline(to: anchor, info: info, relation: relation))
            }
        }

        attributes.removeAll()
        allConstraints.append(contentsOf: constraints)
        return constraints
    }

    private func makeTop(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> NSLayoutConstraint {
        relation.constraint(for: view.topAnchor, to: {
            switch anchor ?? view.superview {
            case let to as LayoutView:          return to.topAnchor
            case let to as NSLayoutYAxisAnchor: return to
            case let to as LayoutGuide:         return to.topAnchor
            default: fatalError("Can Only be `LayoutView`、`NSLayoutYAxisAnchor` or `LayoutGuide`")
            }
        }(), info: info)
    }

    private func makeBottom(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> NSLayoutConstraint {
        relation.constraint(for: view.bottomAnchor, to: {
            switch anchor ?? view.superview {
            case let to as LayoutView:          return to.bottomAnchor
            case let to as NSLayoutYAxisAnchor: return to
            case let to as LayoutGuide:         return to.bottomAnchor
            default: fatalError("Can Only be `LayoutView`、`NSLayoutYAxisAnchor` or `LayoutGuide`")
            }
        }(), info: info.negated)
    }

    private func makeLeading(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> NSLayoutConstraint {
        relation.constraint(for: view.leadingAnchor, to: {
            switch anchor ?? view.superview {
            case let to as LayoutView:          return to.leadingAnchor
            case let to as NSLayoutXAxisAnchor: return to
            case let to as LayoutGuide:         return to.leadingAnchor
            default: fatalError("Can Only be `LayoutView`、`NSLayoutXAxisAnchor` or `LayoutGuide`")
            }
        }(), info: info)
    }

    private func makeTrailing(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> NSLayoutConstraint {
        relation.constraint(for: view.trailingAnchor, to: {
            switch anchor ?? view.superview {
            case let to as LayoutView:          return to.trailingAnchor
            case let to as NSLayoutXAxisAnchor: return to
            case let to as LayoutGuide:         return to.trailingAnchor
            default: fatalError("Can Only be `LayoutView`、`NSLayoutXAxisAnchor` or `LayoutGuide`")
            }
        }(), info: info.negated)
    }

    private func makeCenter(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> [NSLayoutConstraint] {
        [makeCenterX(to: anchor, info: info, relation: relation),
         makeCenterY(to: anchor, info: info, relation: relation)]
    }

    private func makeCenterX(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> NSLayoutConstraint {
        relation.constraint(for: view.centerXAnchor, to: {
            switch anchor ?? view.superview {
            case let to as LayoutView:          return to.centerXAnchor
            case let to as NSLayoutXAxisAnchor: return to
            case let to as LayoutGuide:         return to.centerXAnchor
            default: fatalError("Can Only be `LayoutView`、`NSLayoutXAxisAnchor` or `LayoutGuide`")
            }
        }(), info: info)
    }

    private func makeCenterY(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> NSLayoutConstraint {
        relation.constraint(for: view.centerYAnchor, to: {
            switch anchor ?? view.superview {
            case let to as LayoutView:          return to.centerYAnchor
            case let to as NSLayoutYAxisAnchor: return to
            case let to as LayoutGuide:         return to.centerYAnchor
            default: fatalError("Can Only be `LayoutView`、`NSLayoutYAxisAnchor` or `LayoutGuide`")
            }
        }(), info: info)
    }

    private func makeWidth(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> NSLayoutConstraint {
        relation.constraint(for: view.widthAnchor, to: anchor == nil ? nil : {
            switch anchor ?? view.superview {
            case let to as LayoutView:          return to.widthAnchor
            case let to as NSLayoutDimension:   return to
            case let to as LayoutGuide:         return to.widthAnchor
            default: fatalError("Can Only be `LayoutView`、`NSLayoutDimension` or `LayoutGuide`")
            }
        }(), info: info)
    }

    private func makeHeight(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> NSLayoutConstraint {
        relation.constraint(for: view.heightAnchor, to: anchor == nil ? nil : {
            switch anchor ?? view.superview {
            case let to as LayoutView:          return to.heightAnchor
            case let to as NSLayoutDimension:   return to
            case let to as LayoutGuide:         return to.heightAnchor
            default: fatalError("Can Only be `LayoutView`、`NSLayoutDimension` or `LayoutGuide`")
            }
        }(), info: info)
    }

    private func makeEdges(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> [NSLayoutConstraint] {
        let infoNegated = info.negated
        switch anchor ?? view.superview {
        case let to as LayoutView:
            return [relation.constraint(for: view.topAnchor, to: to.topAnchor, info: info),
                    relation.constraint(for: view.bottomAnchor, to: to.bottomAnchor, info: infoNegated),
                    relation.constraint(for: view.leadingAnchor, to: to.leadingAnchor, info: info),
                    relation.constraint(for: view.trailingAnchor, to: to.trailingAnchor, info: infoNegated)]
        case let to as LayoutGuide:
            return [relation.constraint(for: view.topAnchor, to: to.topAnchor, info: info),
                    relation.constraint(for: view.bottomAnchor, to: to.bottomAnchor, info: infoNegated),
                    relation.constraint(for: view.leadingAnchor, to: to.leadingAnchor, info: info),
                    relation.constraint(for: view.trailingAnchor, to: to.trailingAnchor, info: infoNegated)]
        default:
            fatalError("Can Only be `LayoutView` or `LayoutGuide`")
        }
    }

    private func makeSize(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> [NSLayoutConstraint] {
        var toWidthAnchor, toHeightAnchor: NSLayoutDimension?
        var widthInfo = info, heightInfo = info

        switch anchor ?? view.superview {
        case let to as LayoutView:
            if anchor != nil {
                toWidthAnchor = to.widthAnchor
                toHeightAnchor = to.heightAnchor
            }
        case let to as CGSize:
            widthInfo.setConstant(to.width)
            heightInfo.setConstant(to.height)
        case let to as NSLayoutDimension:
            toWidthAnchor = to
            toHeightAnchor = to
        case let to as LayoutGuide:
            toWidthAnchor = to.widthAnchor
            toHeightAnchor = to.heightAnchor
        default:
            fatalError("Can Only be `LayoutView`、`CGSize`、`NSLayoutDimension` or `LayoutGuide`")
        }
        return [relation.constraint(for: view.widthAnchor, to: toWidthAnchor, info: widthInfo),
                relation.constraint(for: view.heightAnchor, to: toHeightAnchor, info: heightInfo)]
    }

    private func makeFirstBaseline(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> NSLayoutConstraint {
        relation.constraint(for: view.firstBaselineAnchor, to: {
            switch anchor ?? view.superview {
            case let to as LayoutView:          return to.firstBaselineAnchor
            case let to as NSLayoutYAxisAnchor: return to
            default: fatalError("Can Only be `LayoutView` or `NSLayoutYAxisAnchor`")
            }
        }(), info: info)
    }

    private func makeLastBaseline(to anchor: LayoutAnchor?, info: LayoutOptionsInfo, relation: Relation) -> NSLayoutConstraint {
        relation.constraint(for: view.lastBaselineAnchor, to: {
            switch anchor ?? view.superview {
            case let to as LayoutView:          return to.lastBaselineAnchor
            case let to as NSLayoutYAxisAnchor: return to
            default: fatalError("Can Only be `LayoutView` or `NSLayoutYAxisAnchor`")
            }
        }(), info: info)
    }

    private func add(_ attr: Attribute) -> Self {
        attributes.insert(attr)
        return self
    }
}

// MARK: - Relation
private enum Relation {
    case equal, greater, less

    func constraint(for anchor: NSLayoutYAxisAnchor, to other: NSLayoutYAxisAnchor, info: LayoutOptionsInfo) -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        switch self {
        case .equal:    constraint = anchor.constraint(equalTo: other, constant: info.constant)
        case .greater:  constraint = anchor.constraint(greaterThanOrEqualTo: other, constant: info.constant)
        case .less:     constraint = anchor.constraint(lessThanOrEqualTo: other, constant: info.constant)
        }
        return constraint.setPriorityIfNeeded(info.priority)
    }

    func constraint(for anchor: NSLayoutXAxisAnchor, to other: NSLayoutXAxisAnchor, info: LayoutOptionsInfo) -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        switch self {
        case .equal:    constraint = anchor.constraint(equalTo: other, constant: info.constant)
        case .greater:  constraint = anchor.constraint(greaterThanOrEqualTo: other, constant: info.constant)
        case .less:     constraint = anchor.constraint(lessThanOrEqualTo: other, constant: info.constant)
        }
        return constraint.setPriorityIfNeeded(info.priority)
    }

    func constraint(for anchor: NSLayoutDimension, to other: NSLayoutDimension?, info: LayoutOptionsInfo) -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        guard let other = other else {
            switch self {
            case .equal:    constraint = anchor.constraint(equalToConstant: info.constant)
            case .greater:  constraint = anchor.constraint(greaterThanOrEqualToConstant: info.constant)
            case .less:     constraint = anchor.constraint(lessThanOrEqualToConstant: info.constant)
            }
            return constraint.setPriorityIfNeeded(info.priority)
        }
        switch self {
        case .equal:    constraint = anchor.constraint(equalTo: other, multiplier: info.multiplier, constant: info.constant)
        case .greater:  constraint = anchor.constraint(greaterThanOrEqualTo: other, multiplier: info.multiplier, constant: info.constant)
        case .less:     constraint = anchor.constraint(lessThanOrEqualTo: other, multiplier: info.multiplier, constant: info.constant)
        }
        return constraint.setPriorityIfNeeded(info.priority)
    }
}

// MARK: - LayoutOptionsInfo
private struct LayoutOptionsInfo {
    private(set) var constant: CGFloat = 0.0
    private(set) var multiplier: CGFloat = 1.0
    private(set) var priority: LayoutPriority?

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

    var negated: LayoutOptionsInfo {
        if constant == 0.0 {
            return self
        }

        var new = self
        new.setConstant(-constant)
        return new
    }
}

extension NSLayoutConstraint {
    fileprivate func setPriorityIfNeeded(_ priority: LayoutPriority?) -> NSLayoutConstraint {
        guard let priority = priority else { return self }
        self.priority = priority
        return self
    }
}
