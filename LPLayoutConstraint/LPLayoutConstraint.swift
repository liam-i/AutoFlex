//
//  LPLayoutConstraint.swift
//  LPLayoutConstraint
//
//  Created by pengli on 2019/8/6.
//  Copyright © 2019 pengli. All rights reserved.
//

import UIKit

extension UIView {
    var lp: LPLayoutConstraint { return LPLayoutConstraint(self) }
}
protocol LPLayoutAnchor {}
extension UIView: LPLayoutAnchor {}
extension NSLayoutXAxisAnchor: LPLayoutAnchor {}
extension NSLayoutYAxisAnchor: LPLayoutAnchor {}
extension NSLayoutDimension: LPLayoutAnchor {}

struct LPLayoutConstraint {
    let view: UIView
    init(_ view: UIView) { self.view = view }
    
    func constraints(_ closure: (_ make: LPMarker) -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false
        closure(LPMarker(view))
    }
    
    var top: NSLayoutYAxisAnchor { return view.topAnchor }
    var bottom: NSLayoutYAxisAnchor { return view.bottomAnchor }
    var leading: NSLayoutXAxisAnchor { return view.leadingAnchor }
    var trailing: NSLayoutXAxisAnchor { return view.trailingAnchor }
    var centerX: NSLayoutXAxisAnchor { return view.centerXAnchor }
    var centerY: NSLayoutYAxisAnchor { return view.centerYAnchor }
    var width: NSLayoutDimension { return view.widthAnchor }
    var height: NSLayoutDimension { return view.heightAnchor }
    var topMargin: NSLayoutYAxisAnchor { return view.layoutMarginsGuide.topAnchor }
    var bottomMargin: NSLayoutYAxisAnchor { return view.layoutMarginsGuide.bottomAnchor }
    
    class LPMarker {
        let view: UIView
        init(_ view: UIView) { self.view = view }
        
        var top: LPMarker { return add(.top) }
        var bottom: LPMarker { return add(.bottom) }
        var leading: LPMarker { return add(.leading) }
        var trailing: LPMarker { return add(.trailing) }
        var centerX: LPMarker { return add(.centerX) }
        var centerY: LPMarker { return add(.centerY) }
        var width: LPMarker { return add(.width) }
        var height: LPMarker { return add(.height) }
        var edges: LPMarker { return add(.edges) }
        
        @discardableResult
        func equal(to anchor: LPLayoutAnchor, constant: CGFloat = 0) -> [NSLayoutConstraint] {
            return equal(to: anchor, constant: constant, type: .equal, priority: nil)
        }
        
        @discardableResult
        func greaterOrEqual(to anchor: LPLayoutAnchor, constant: CGFloat = 0) -> [NSLayoutConstraint] {
            return equal(to: anchor, constant: constant, type: .greater, priority: nil)
        }
        
        @discardableResult
        func lessOrEqual(to anchor: LPLayoutAnchor, constant: CGFloat = 0) -> [NSLayoutConstraint] {
            return equal(to: anchor, constant: constant, type: .less, priority: nil)
        }
        
        @discardableResult
        func equal(toConstant: CGFloat, priority: Float? = nil) -> [NSLayoutConstraint] {
            return equal(to: nil, constant: toConstant, type: .equal, priority: priority)
        }
        
        @discardableResult
        func greaterOrEqual(toConstant: CGFloat) -> [NSLayoutConstraint] {
            return equal(to: nil, constant: toConstant, type: .greater, priority: nil)
        }
        
        @discardableResult
        func lessOrEqual(toConstant: CGFloat) -> [NSLayoutConstraint] {
            return equal(to: nil, constant: toConstant, type: .less, priority: nil)
        }
        
        private func equal(to otherAnchor: LPLayoutAnchor?, constant: CGFloat, type: LPConstraintType, priority: Float?) -> [NSLayoutConstraint] {
            let anchor = otherAnchor ?? view.superview
            assert(anchor != nil, "superview is nil.")
            var constraints: [NSLayoutConstraint] = []
            attributes.forEach {
                switch $0 {
                case .top:
                    let toAnchor: NSLayoutYAxisAnchor
                    switch anchor {
                    case let view as UIView: toAnchor = view.topAnchor
                    case let anchor as NSLayoutYAxisAnchor: toAnchor = anchor
                    default: fatalError("Only be `UIView` or `NSLayoutYAxisAnchor`")
                    }
                    constraints.append(type.constraint(for: view.topAnchor, to: toAnchor, constant: constant))
                case .bottom:
                    let toAnchor: NSLayoutYAxisAnchor
                    switch anchor {
                    case let view as UIView: toAnchor = view.bottomAnchor
                    case let anchor as NSLayoutYAxisAnchor: toAnchor = anchor
                    default: fatalError("Only be `UIView` or `NSLayoutYAxisAnchor`")
                    }
                    constraints.append(type.constraint(for: view.bottomAnchor, to: toAnchor, constant: -constant))
                case .leading:
                    let toAnchor: NSLayoutXAxisAnchor
                    switch anchor {
                    case let view as UIView: toAnchor = view.leadingAnchor
                    case let anchor as NSLayoutXAxisAnchor: toAnchor = anchor
                    default: fatalError("Only be `UIView` or `NSLayoutXAxisAnchor`")
                    }
                    constraints.append(type.constraint(for: view.leadingAnchor, to: toAnchor, constant: constant))
                case .trailing:
                    let toAnchor: NSLayoutXAxisAnchor
                    switch anchor {
                    case let view as UIView: toAnchor = view.trailingAnchor
                    case let anchor as NSLayoutXAxisAnchor: toAnchor = anchor
                    default: fatalError("Only be `UIView` or `NSLayoutXAxisAnchor`")
                    }
                    constraints.append(type.constraint(for: view.trailingAnchor, to: toAnchor, constant: -constant))
                case .centerX:
                    let toAnchor: NSLayoutXAxisAnchor
                    switch anchor {
                    case let view as UIView: toAnchor = view.trailingAnchor
                    case let anchor as NSLayoutXAxisAnchor: toAnchor = anchor
                    default: fatalError("Only be `UIView` or `NSLayoutXAxisAnchor`")
                    }
                    constraints.append(type.constraint(for: view.centerXAnchor, to: toAnchor, constant: constant))
                case .centerY:
                    let toAnchor: NSLayoutYAxisAnchor
                    switch anchor {
                    case let view as UIView: toAnchor = view.bottomAnchor
                    case let anchor as NSLayoutYAxisAnchor: toAnchor = anchor
                    default: fatalError("Only be `UIView` or `NSLayoutYAxisAnchor`")
                    }
                    constraints.append(type.constraint(for: view.centerYAnchor, to: toAnchor, constant: constant))
                case .width:
                    let toAnchor: NSLayoutDimension
                    switch anchor {
                    case let view as UIView: toAnchor = view.widthAnchor
                    case let anchor as NSLayoutDimension: toAnchor = anchor
                    default: fatalError("Only be `UIView` or `NSLayoutDimension`")
                    }
                    constraints.append(type.constraint(for: view.widthAnchor, to: otherAnchor == nil ? nil : toAnchor, constant: constant, priority: priority))
                case .height:
                    let toAnchor: NSLayoutDimension
                    switch anchor {
                    case let view as UIView: toAnchor = view.heightAnchor
                    case let anchor as NSLayoutDimension: toAnchor = anchor
                    default: fatalError("Only be `UIView` or `NSLayoutDimension`")
                    }
                    constraints.append(type.constraint(for: view.heightAnchor, to: otherAnchor == nil ? nil : toAnchor, constant: constant, priority: priority))
                case .edges:
                    guard let toView = anchor as? UIView else { fatalError("Only be `UIView`") }
                    constraints.append(contentsOf: type.constraintEdge(for: view, to: toView, constant: constant))
                }
            }
            attributes.removeAll()
            NSLayoutConstraint.activate(constraints)
            return constraints
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
            
            func constraintEdge(for view: UIView, to other: UIView, constant: CGFloat) -> [NSLayoutConstraint] {
                switch self {
                case .equal:
                    return [view.topAnchor.constraint(equalTo: other.topAnchor, constant: constant),
                            view.bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -constant),
                            view.leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: constant),
                            view.trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -constant)]
                case .greater:
                    return [view.topAnchor.constraint(greaterThanOrEqualTo: other.topAnchor, constant: constant),
                            view.bottomAnchor.constraint(greaterThanOrEqualTo: other.bottomAnchor, constant: -constant),
                            view.leadingAnchor.constraint(greaterThanOrEqualTo: other.leadingAnchor, constant: constant),
                            view.trailingAnchor.constraint(greaterThanOrEqualTo: other.trailingAnchor, constant: -constant)]
                case .less:
                    return [view.topAnchor.constraint(lessThanOrEqualTo: other.topAnchor, constant: constant),
                            view.bottomAnchor.constraint(lessThanOrEqualTo: other.bottomAnchor, constant: -constant),
                            view.leadingAnchor.constraint(lessThanOrEqualTo: other.leadingAnchor, constant: constant),
                            view.trailingAnchor.constraint(lessThanOrEqualTo: other.trailingAnchor, constant: -constant)]
                }
            }
        }
        
        private enum LPAttributes { case top, bottom, leading, trailing, centerX, centerY, width, height, edges }
        private var attributes = Set<LPAttributes>()
        private func add(_ attr: LPAttributes) -> Self { attributes.insert(attr); return self }
    }
}
