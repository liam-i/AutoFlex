//
//  AutoLayout.swift
//  AutoLayout
//
//  Created by Liam on 2019/8/6.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

public protocol AutoLayoutCompatible {
    associatedtype CompatibleAutoLayout
    var lp: CompatibleAutoLayout { get }
}

extension AutoLayoutCompatible {
    public var lp: AutoLayout<Self> { AutoLayout(self) }
}

extension UIView: AutoLayoutCompatible {}

public protocol LayoutAnchor {}

extension UIView: LayoutAnchor {}
extension NSLayoutXAxisAnchor: LayoutAnchor {}
extension NSLayoutYAxisAnchor: LayoutAnchor {}
extension NSLayoutDimension: LayoutAnchor {}
extension UILayoutGuide: LayoutAnchor {}
extension CGSize: LayoutAnchor {}

public struct AutoLayout<ViewType> {
    private let view: ViewType

    public init(_ view: ViewType) {
        self.view = view
    }
}

extension AutoLayout where ViewType: UIView {
    public func constraints(_ closure: (Marker<ViewType>) -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false

        let marker = Marker(view)
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

public class Marker<ViewType> {
    public let view: ViewType

    public init(_ view: ViewType) {
        self.view = view
    }

    private enum Attributes { case top, bottom, leading, trailing, centerX, centerY, center, width, height, edges, size }
    private var attributes = Set<Attributes>()
    private var allConstraints: [NSLayoutConstraint] = []
}

extension Marker where ViewType: UIView {
    public var top: Marker { add(.top) }
    public var bottom: Marker { add(.bottom) }
    public var leading: Marker { add(.leading) }
    public var trailing: Marker { add(.trailing) }
    public var centerX: Marker { add(.centerX) }
    public var centerY: Marker { add(.centerY) }
    public var center: Marker { add(.center) }
    public var width: Marker { add(.width) }
    public var height: Marker { add(.height) }
    public var edges: Marker { add(.edges) }
    public var size: Marker { add(.size) }

    @discardableResult
    public func equal(to anchor: LayoutAnchor, constant: CGFloat = 0) -> [NSLayoutConstraint] {
        equal(to: anchor, constant: constant, priority: nil, type: .equal)
    }

    @discardableResult
    public func greaterOrEqual(to anchor: LayoutAnchor, constant: CGFloat = 0) -> [NSLayoutConstraint] {
        equal(to: anchor, constant: constant, priority: nil, type: .greater)
    }

    @discardableResult
    public func lessOrEqual(to anchor: LayoutAnchor, constant: CGFloat = 0) -> [NSLayoutConstraint] {
        equal(to: anchor, constant: constant, priority: nil, type: .less)
    }

    @discardableResult
    public func equal(toConstant: CGFloat, priority: Float? = nil) -> [NSLayoutConstraint] {
        equal(to: nil, constant: toConstant, priority: priority, type: .equal)
    }

    @discardableResult
    public func greaterOrEqual(toConstant: CGFloat) -> [NSLayoutConstraint] {
        equal(to: nil, constant: toConstant, priority: nil, type: .greater)
    }

    @discardableResult
    public func lessOrEqual(toConstant: CGFloat) -> [NSLayoutConstraint] {
        equal(to: nil, constant: toConstant, priority: nil, type: .less)
    }

    fileprivate func activate() {
        assert(allConstraints.isEmpty == false)
        NSLayoutConstraint.activate(allConstraints)
    }

    private func equal(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> [NSLayoutConstraint] {
        assert(view.superview != nil, "superview is nil.")
        assert(attributes.isEmpty == false, "ambiguous constraints.")

        let constraints = attributes.reduce(into: [NSLayoutConstraint]()) {
            switch $1 {
            case .top:
                $0.append(makeTop(to: anchor, constant: constant, priority: priority, type: type))
            case .bottom:
                $0.append(makeBottom(to: anchor, constant: constant, priority: priority, type: type))
            case .leading:
                $0.append(makeLeading(to: anchor, constant: constant, priority: priority, type: type))
            case .trailing:
                $0.append(makeTrailing(to: anchor, constant: constant, priority: priority, type: type))
            case .centerX:
                $0.append(makeCenterX(to: anchor, constant: constant, priority: priority, type: type))
            case .centerY:
                $0.append(makeCenterY(to: anchor, constant: constant, priority: priority, type: type))
            case .center:
                $0.append(makeCenterX(to: anchor, constant: constant, priority: priority, type: type))
                $0.append(makeCenterY(to: anchor, constant: constant, priority: priority, type: type))
            case .width:
                $0.append(makeWidth(to: anchor, constant: constant, priority: priority, type: type))
            case .height:
                $0.append(makeHeight(to: anchor, constant: constant, priority: priority, type: type))
            case .edges:
                $0.append(contentsOf: makeEdges(to: anchor, constant: constant, priority: priority, type: type))
            case .size:
                $0.append(contentsOf: makeSize(to: anchor, constant: constant, priority: priority, type: type))
            }
        }

        attributes.removeAll()
        allConstraints.append(contentsOf: constraints)
        return constraints
    }

    private func makeTop(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.topAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.topAnchor
            case let to as NSLayoutYAxisAnchor: return to
            case let to as UILayoutGuide:       return to.topAnchor
            default: fatalError("Only be `UIView`、`NSLayoutYAxisAnchor` or `UILayoutGuide`")
            }
        }(), constant: constant)
    }

    private func makeBottom(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.bottomAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.bottomAnchor
            case let to as NSLayoutYAxisAnchor: return to
            case let to as UILayoutGuide:       return to.bottomAnchor
            default: fatalError("Only be `UIView`、`NSLayoutYAxisAnchor` or `UILayoutGuide`")
            }
        }(), constant: -constant)
    }

    private func makeLeading(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.leadingAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.leadingAnchor
            case let to as NSLayoutXAxisAnchor: return to
            case let to as UILayoutGuide:       return to.leadingAnchor
            default: fatalError("Only be `UIView`、`NSLayoutXAxisAnchor` or `UILayoutGuide`")
            }
        }(), constant: constant)
    }

    private func makeTrailing(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.trailingAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.trailingAnchor
            case let to as NSLayoutXAxisAnchor: return to
            case let to as UILayoutGuide:       return to.trailingAnchor
            default: fatalError("Only be `UIView`、`NSLayoutXAxisAnchor` or `UILayoutGuide`")
            }
        }(), constant: -constant)
    }

    private func makeCenterX(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.centerXAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.centerXAnchor
            case let to as NSLayoutXAxisAnchor: return to
            case let to as UILayoutGuide:       return to.centerXAnchor
            default: fatalError("Only be `UIView`、`NSLayoutXAxisAnchor` or `UILayoutGuide`")
            }
        }(), constant: constant)
    }

    private func makeCenterY(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.centerYAnchor, to: {
            switch anchor ?? view.superview {
            case let to as UIView:              return to.centerYAnchor
            case let to as NSLayoutYAxisAnchor: return to
            case let to as UILayoutGuide:       return to.centerYAnchor
            default: fatalError("Only be `UIView`、`NSLayoutYAxisAnchor` or `UILayoutGuide`")
            }
        }(), constant: constant)
    }

    private func makeWidth(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.widthAnchor, to: anchor == nil ? nil : {
            switch anchor ?? view.superview {
            case let to as UIView:            return to.widthAnchor
            case let to as NSLayoutDimension: return to
            case let to as UILayoutGuide:     return to.widthAnchor
            default: fatalError("Only be `UIView`、`NSLayoutDimension` or `UILayoutGuide`")
            }
        }(), constant: constant, priority: priority)
    }

    private func makeHeight(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> NSLayoutConstraint {
        type.constraint(for: view.heightAnchor, to: anchor == nil ? nil : {
            switch anchor ?? view.superview {
            case let to as UIView:            return to.heightAnchor
            case let to as NSLayoutDimension: return to
            case let to as UILayoutGuide:     return to.heightAnchor
            default: fatalError("Only be `UIView`、`NSLayoutDimension` or `UILayoutGuide`")
            }
        }(), constant: constant, priority: priority)
    }

    private func makeEdges(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> [NSLayoutConstraint] {
        switch anchor ?? view.superview {
        case let to as UIView:
            return [type.constraint(for: view.topAnchor, to: to.topAnchor, constant: constant),
                    type.constraint(for: view.bottomAnchor, to: to.bottomAnchor, constant: -constant),
                    type.constraint(for: view.leadingAnchor, to: to.leadingAnchor, constant: constant),
                    type.constraint(for: view.trailingAnchor, to: to.trailingAnchor, constant: -constant)]
        case let to as UILayoutGuide:
            return [type.constraint(for: view.topAnchor, to: to.topAnchor, constant: constant),
                    type.constraint(for: view.bottomAnchor, to: to.bottomAnchor, constant: -constant),
                    type.constraint(for: view.leadingAnchor, to: to.leadingAnchor, constant: constant),
                    type.constraint(for: view.trailingAnchor, to: to.trailingAnchor, constant: -constant)]
        default:
            fatalError("Only be `UIView` or `UILayoutGuide`")
        }
    }

    private func makeSize(to anchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> [NSLayoutConstraint] {
        var toW: NSLayoutDimension?, toH: NSLayoutDimension?
        var valueW: CGFloat = constant, valueH: CGFloat = constant
        switch anchor ?? view.superview {
        case let to as UIView:            if anchor != nil { toW = to.widthAnchor; toH = to.heightAnchor }
        case let to as CGSize:            valueW = to.width;      valueH = to.height
        case let to as NSLayoutDimension: toW = to;               toH = to
        case let to as UILayoutGuide:     toW = to.widthAnchor;   toH = to.heightAnchor
        default: fatalError("Only be `UIView`、`CGSize`、`NSLayoutDimension` or `UILayoutGuide`")
        }
        return [type.constraint(for: view.widthAnchor, to: toW, constant: valueW, priority: priority),
                type.constraint(for: view.heightAnchor, to: toH, constant: valueH, priority: priority)]
    }

    private func add(_ attr: Attributes) -> Self {
        attributes.insert(attr)
        return self
    }
}

private enum ConstraintType {
    case equal, greater, less

    func constraint(for anchor: NSLayoutYAxisAnchor, to other: NSLayoutYAxisAnchor, constant: CGFloat) -> NSLayoutConstraint {
        switch self {
        case .equal:   return anchor.constraint(equalTo: other, constant: constant)
        case .greater: return anchor.constraint(greaterThanOrEqualTo: other, constant: constant)
        case .less:    return anchor.constraint(lessThanOrEqualTo: other, constant: constant)
        }
    }

    func constraint(for anchor: NSLayoutXAxisAnchor, to other: NSLayoutXAxisAnchor, constant: CGFloat) -> NSLayoutConstraint {
        switch self {
        case .equal:   return anchor.constraint(equalTo: other, constant: constant)
        case .greater: return anchor.constraint(greaterThanOrEqualTo: other, constant: constant)
        case .less:    return anchor.constraint(lessThanOrEqualTo: other, constant: constant)
        }
    }

    func constraint(for anchor: NSLayoutDimension, to other: NSLayoutDimension?, constant: CGFloat, priority: Float?) -> NSLayoutConstraint {
        if let other = other {
            switch self {
            case .equal:   return anchor.constraint(equalTo: other, constant: constant)
            case .greater: return anchor.constraint(greaterThanOrEqualTo: other, constant: constant)
            case .less:    return anchor.constraint(lessThanOrEqualTo: other, constant: constant)
            }
        } else {
            switch self {
            case .equal:
                let constraint = anchor.constraint(equalToConstant: constant)
                if let priority = priority {
                    constraint.priority = UILayoutPriority(rawValue: priority)
                }
                return constraint
            case .greater: return anchor.constraint(greaterThanOrEqualToConstant: constant)
            case .less:    return anchor.constraint(lessThanOrEqualToConstant: constant)
            }
        }
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
