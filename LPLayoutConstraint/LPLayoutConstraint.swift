//
//  LPLayoutConstraint.swift
//  LPLayoutConstraint
//
//  Created by pengli on 2019/8/6.
//  Copyright © 2019 pengli. All rights reserved.
//

import UIKit

extension UIView {
    public var lp: LPLayoutConstraint { return LPLayoutConstraint(self) }
}
public protocol LPLayoutAnchor {}
extension UIView: LPLayoutAnchor {}
extension NSLayoutXAxisAnchor: LPLayoutAnchor {}
extension NSLayoutYAxisAnchor: LPLayoutAnchor {}
extension NSLayoutDimension: LPLayoutAnchor {}
extension CGSize: LPLayoutAnchor {}

public struct LPLayoutConstraint {
    private let view: UIView
    init(_ view: UIView) { self.view = view }
    
    public func constraints(_ closure: (LPMarker) -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let marker = LPMarker(view)
        closure(marker)
        if marker.allConstraints.count > 0 { NSLayoutConstraint.activate(marker.allConstraints) }
    }
    
    public var top: NSLayoutYAxisAnchor { return view.topAnchor }
    public var bottom: NSLayoutYAxisAnchor { return view.bottomAnchor }
    public var leading: NSLayoutXAxisAnchor { return view.leadingAnchor }
    public var trailing: NSLayoutXAxisAnchor { return view.trailingAnchor }
    public var centerX: NSLayoutXAxisAnchor { return view.centerXAnchor }
    public var centerY: NSLayoutYAxisAnchor { return view.centerYAnchor }
    public var width: NSLayoutDimension { return view.widthAnchor }
    public var height: NSLayoutDimension { return view.heightAnchor }
    public var topSafe: NSLayoutYAxisAnchor {
        guard #available(iOS 11.0, *) else { return view.topAnchor }; return view.safeAreaLayoutGuide.topAnchor
    }
    public var bottomSafe: NSLayoutYAxisAnchor {
        guard #available(iOS 11.0, *) else { return view.bottomAnchor }; return view.safeAreaLayoutGuide.bottomAnchor
    }
}

public class LPMarker {
    let view: UIView
    init(_ view: UIView) { self.view = view }
    
    public var top: LPMarker { return add(.top) }
    public var bottom: LPMarker { return add(.bottom) }
    public var leading: LPMarker { return add(.leading) }
    public var trailing: LPMarker { return add(.trailing) }
    public var centerX: LPMarker { return add(.centerX) }
    public var centerY: LPMarker { return add(.centerY) }
    public var width: LPMarker { return add(.width) }
    public var height: LPMarker { return add(.height) }
    public var edges: LPMarker { return add(.edges) }
    public var size: LPMarker { return add(.size) }
    
    @discardableResult
    public func equal(to anchor: LPLayoutAnchor, constant: CGFloat = 0) -> [NSLayoutConstraint] {
        return equal(to: anchor, constant: constant, priority: nil, type: .equal)
    }
    
    @discardableResult
    public func greaterOrEqual(to anchor: LPLayoutAnchor, constant: CGFloat = 0) -> [NSLayoutConstraint] {
        return equal(to: anchor, constant: constant, priority: nil, type: .greater)
    }
    
    @discardableResult
    public func lessOrEqual(to anchor: LPLayoutAnchor, constant: CGFloat = 0) -> [NSLayoutConstraint] {
        return equal(to: anchor, constant: constant, priority: nil, type: .less)
    }
    
    @discardableResult
    public func equal(toConstant: CGFloat, priority: Float? = nil) -> [NSLayoutConstraint] {
        return equal(to: nil, constant: toConstant, priority: priority, type: .equal)
    }
    
    @discardableResult
    public func greaterOrEqual(toConstant: CGFloat) -> [NSLayoutConstraint] {
        return equal(to: nil, constant: toConstant, priority: nil, type: .greater)
    }
    
    @discardableResult
    public func lessOrEqual(toConstant: CGFloat) -> [NSLayoutConstraint] {
        return equal(to: nil, constant: toConstant, priority: nil, type: .less)
    }
    
    private func equal(to otherAnchor: LPLayoutAnchor?, constant: CGFloat, priority: Float?, type: LPConstraintType) -> [NSLayoutConstraint] {
        let anchor = otherAnchor ?? view.superview
        assert(anchor != nil, "superview is nil.")
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
    
    public func update(constant: CGFloat) {
        guard let superview = view.superview else { return assert(false, "superview is nil.") }
        func update(with attr: NSLayoutConstraint.Attribute, constant: CGFloat) {
            let block: (NSLayoutConstraint) -> Bool = {
                if $0.firstAttribute == attr {
                    if let first = $0.firstItem as? UIView, first == self.view { return true }
                    if let second = $0.secondItem as? UIView, second == self.view { return true }
                }
                return false
            }
            if let index = view.constraints.firstIndex(where: block) {
                view.constraints[index].constant = constant
            } else if let index = superview.constraints.firstIndex(where: block) {
                superview.constraints[index].constant = constant
            } else {
                assert(false, "constraint(\(attr.rawValue)) not found.")
            }
        }
        attributes.forEach {
            switch $0 {
            case .top:
                update(with: .top, constant: constant)
            case .bottom:
                update(with: .bottom, constant: -constant)
            case .leading:
                update(with: .leading, constant: constant)
            case .trailing:
                update(with: .trailing, constant: -constant)
            case .centerX:
                update(with: .centerX, constant: constant)
            case .centerY:
                update(with: .centerY, constant: constant)
            case .width:
                update(with: .width, constant: constant)
            case .height:
                update(with: .height, constant: constant)
            case .edges:
                update(with: .top, constant: constant)
                update(with: .bottom, constant: -constant)
                update(with: .leading, constant: constant)
                update(with: .trailing, constant: -constant)
            case .size:
                update(with: .width, constant: constant)
                update(with: .height, constant: constant)
            }
        }
        attributes.removeAll()
    }
    
    private enum LPAttributes { case top, bottom, leading, trailing, centerX, centerY, width, height, edges, size }
    private var attributes = Set<LPAttributes>()
    private func add(_ attr: LPAttributes) -> Self { attributes.insert(attr); return self }
    fileprivate var allConstraints: [NSLayoutConstraint] = []
}

private enum LPConstraintType {
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
