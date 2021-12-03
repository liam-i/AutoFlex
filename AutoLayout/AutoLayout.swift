//
//  LayoutConstraint.swift
//  LayoutConstraint
//
//  Created by Liam on 2019/8/6.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

extension UIView {
    public var lp: LayoutConstraint { LayoutConstraint(self) }
}

public protocol LayoutAnchor {}

extension UIView: LayoutAnchor {}
extension NSLayoutXAxisAnchor: LayoutAnchor {}
extension NSLayoutYAxisAnchor: LayoutAnchor {}
extension NSLayoutDimension: LayoutAnchor {}
extension CGSize: LayoutAnchor {}

public struct LayoutConstraint {
    private let view: UIView

    public init(_ view: UIView) {
        self.view = view
    }

    public func constraints(_ closure: (Marker) -> Void) {
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

public class Marker {
    public let view: UIView

    public init(_ view: UIView) {
        self.view = view
    }

    public var top: Marker { add(.top) }
    public var bottom: Marker { add(.bottom) }
    public var leading: Marker { add(.leading) }
    public var trailing: Marker { add(.trailing) }
    public var centerX: Marker { add(.centerX) }
    public var centerY: Marker { add(.centerY) }
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

    private func equal(to otherAnchor: LayoutAnchor?, constant: CGFloat, priority: Float?, type: ConstraintType) -> [NSLayoutConstraint] {
        let anchor = otherAnchor ?? view.superview

        assert(anchor != nil, "superview is nil.")
        assert(attributes.isEmpty == false, "ambiguous constraints.")

        var constraints: [NSLayoutConstraint] = []
        attributes.forEach {
            switch $0 {
            case .top:
                let toa: NSLayoutYAxisAnchor
                switch anchor {
                case let to as UIView: toa = to.topAnchor
                case let to as NSLayoutYAxisAnchor: toa = to
                default: fatalError("Only be `UIView` or `NSLayoutYAxisAnchor`")
                }
                constraints.append(type.constraint(for: view.topAnchor, to: toa, constant: constant))
            case .bottom:
                let toa: NSLayoutYAxisAnchor
                switch anchor {
                case let to as UIView: toa = to.bottomAnchor
                case let to as NSLayoutYAxisAnchor: toa = to
                default: fatalError("Only be `UIView` or `NSLayoutYAxisAnchor`")
                }
                constraints.append(type.constraint(for: view.bottomAnchor, to: toa, constant: -constant))
            case .leading:
                let toa: NSLayoutXAxisAnchor
                switch anchor {
                case let to as UIView: toa = to.leadingAnchor
                case let to as NSLayoutXAxisAnchor: toa = to
                default: fatalError("Only be `UIView` or `NSLayoutXAxisAnchor`")
                }
                constraints.append(type.constraint(for: view.leadingAnchor, to: toa, constant: constant))
            case .trailing:
                let toa: NSLayoutXAxisAnchor
                switch anchor {
                case let to as UIView: toa = to.trailingAnchor
                case let to as NSLayoutXAxisAnchor: toa = to
                default: fatalError("Only be `UIView` or `NSLayoutXAxisAnchor`")
                }
                constraints.append(type.constraint(for: view.trailingAnchor, to: toa, constant: -constant))
            case .centerX:
                let toa: NSLayoutXAxisAnchor
                switch anchor {
                case let to as UIView: toa = to.centerXAnchor
                case let to as NSLayoutXAxisAnchor: toa = to
                default: fatalError("Only be `UIView` or `NSLayoutXAxisAnchor`")
                }
                constraints.append(type.constraint(for: view.centerXAnchor, to: toa, constant: constant))
            case .centerY:
                let toa: NSLayoutYAxisAnchor
                switch anchor {
                case let to as UIView: toa = to.centerYAnchor
                case let to as NSLayoutYAxisAnchor: toa = to
                default: fatalError("Only be `UIView` or `NSLayoutYAxisAnchor`")
                }
                constraints.append(type.constraint(for: view.centerYAnchor, to: toa, constant: constant))
            case .width:
                let toa: NSLayoutDimension
                switch anchor {
                case let to as UIView: toa = to.widthAnchor
                case let to as NSLayoutDimension: toa = to
                default: fatalError("Only be `UIView` or `NSLayoutDimension`")
                }
                constraints.append(type.constraint(for: view.widthAnchor, to: otherAnchor == nil ? nil : toa, constant: constant, priority: priority))
            case .height:
                let toa: NSLayoutDimension
                switch anchor {
                case let to as UIView: toa = to.heightAnchor
                case let to as NSLayoutDimension: toa = to
                default: fatalError("Only be `UIView` or `NSLayoutDimension`")
                }
                constraints.append(type.constraint(for: view.heightAnchor, to: otherAnchor == nil ? nil : toa, constant: constant, priority: priority))
            case .edges:
                guard let toa = anchor as? UIView else { fatalError("Only be `UIView`") }
                constraints.append(type.constraint(for: view.topAnchor, to: toa.topAnchor, constant: constant))
                constraints.append(type.constraint(for: view.bottomAnchor, to: toa.bottomAnchor, constant: -constant))
                constraints.append(type.constraint(for: view.leadingAnchor, to: toa.leadingAnchor, constant: constant))
                constraints.append(type.constraint(for: view.trailingAnchor, to: toa.trailingAnchor, constant: -constant))
            case .size:
                var lW: NSLayoutDimension? = nil, lH: NSLayoutDimension? = nil
                var cW: CGFloat = constant, cH: CGFloat = constant
                switch anchor {
                case let to as UIView: if otherAnchor != nil { lW = to.widthAnchor; lH = to.heightAnchor }
                case let to as CGSize: cW = to.width; cH = to.height
                case let to as NSLayoutDimension: lW = to; lH = to
                default: fatalError("Only be `UIView` or `CGSize` or `NSLayoutDimension`") }
                constraints.append(type.constraint(for: view.widthAnchor, to: lW, constant: cW, priority: priority))
                constraints.append(type.constraint(for: view.heightAnchor, to: lH, constant: cH, priority: priority))
            }
        }

        attributes.removeAll()
        allConstraints.append(contentsOf: constraints)
        return constraints
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

    fileprivate func activate() {
        assert(allConstraints.isEmpty == false)
        NSLayoutConstraint.activate(allConstraints)
    }

    private func add(_ attr: Attributes) -> Self {
        attributes.insert(attr)
        return self
    }

    private enum Attributes { case top, bottom, leading, trailing, centerX, centerY, width, height, edges, size }
    private var attributes = Set<Attributes>()
    private var allConstraints: [NSLayoutConstraint] = []
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
