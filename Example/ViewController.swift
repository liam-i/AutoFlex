//
//  ViewController.swift
//  AutoLayout
//
//  Created by Liam on 12/03/2021.
//  Copyright (c) 2021 Liam. All rights reserved.
//

import UIKit
import LPAutoLayout

class ViewController: UIViewController {
    private lazy var label = makeLabel(title: "演示 constant 和 multiplier 的使用", border: .red)
    private lazy var label2 = makeLabel(title: "演示 constant 和 multiplier 的使用（size是label.size的0.5倍）", border: .blue)

    private lazy var label3 = makeLabel(title: "演示 constant 和 Priority 的使用（width:250）", border: .red)
    private lazy var label4 = makeLabel(title: "演示 constant 和 Priority 的使用（width被压缩）", border: .blue)

    deinit {
        #if DEBUG
        print("👍👍👍 AutoLayoutViewController is released.")
        #endif
    }

    private lazy var constantValue: CGFloat = 50
//    private weak var constraintLeading: Constraint?
    private weak var constraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        makeConstraints()
    }

    private func makeConstraints() {
        label.lp.constraints {
            $0.top.equal(to: view.lp.safeLayout, options: .constant(20))
            $0.leading.trailing.equal(to: view, options: .constant(20))
            $0.centerX.equal(to: view)
            constraint = $0.height.equal(toOptions: .constant(constantValue)).first
//            $0.height.equal(to: label.widthAnchor, options: .multiplier(0.7))
        }
        label2.lp.constraints {
            $0.top.equal(to: label.bottomAnchor, options: .constant(20))
            $0.leading.equal(to: label)
            $0.size.equal(to: label, options: .multiplier(0.5))
        }

        label3.lp.constraints {
            $0.top.equal(to: label2.bottomAnchor, options: .constant(50))
            $0.leading.equal(to: label)
            $0.width.equal(toOptions: .constant(250))
        }
        label4.lp.constraints {
            $0.top.equal(to: label3)
            $0.trailing.equal(to: view.trailingAnchor, constant: 20)
            if let constraint = $0.leading.equal(to: label3.trailingAnchor, constant: 10).first {
                // 因为 label4.width.priority 小于 label3.width.priority 所以 label4.width 会被压缩
                $0.width.equal(toOptions: .constant(250), .priority(constraint.advancedPriority(by: -1)))
            } else {
                assertionFailure()
            }
        }
    }

    private func makeLabel(title: String, border: UIColor) -> UILabel {
        let label = UILabel()
        label.text = title
        label.numberOfLines = 0
        label.layer.borderColor = border.cgColor
        label.layer.borderWidth = 2
        view.addSubview(label)
        return label
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        constantValue += 10
//        constraintLeading?.update(offset: constantValue)
        constraint?.constant = constantValue
    }
}
