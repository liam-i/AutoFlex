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

    override func viewDidLoad() {
        super.viewDidLoad()

        let v = UILabel()
        v.text = "AutoLayout"
        v.numberOfLines = 0
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.red.cgColor
        view.addSubview(v)

        v.lp.constraints {
            $0.top.equal(to: view.lp.safeLayout)
            $0.leading.equal(toConstant: 5)
            $0.size.equal(to: CGSize(width: 40, height: 80))

//            $0.center.equal(to: view, constant: 100)

//            $0.edges.equal(to: view.lp.safeLayout)
        }
    }
}
