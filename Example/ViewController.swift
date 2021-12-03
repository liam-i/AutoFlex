//
//  ViewController.swift
//  AutoLayout
//
//  Created by Liam on 12/03/2021.
//  Copyright (c) 2021 Liam. All rights reserved.
//

import UIKit
import AutoLayout

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let v = UILabel()
        v.text = "AutoLayout"
        v.numberOfLines = 0
        v.backgroundColor = UIColor.red
        view.addSubview(v)

        v.lp.constraints {
            $0.top.equal(to: view.lp.safeLayout.topAnchor)
            $0.leading.equal(toConstant: 5)
            $0.size.equal(to: CGSize(width: 40, height: 80))
        }
    }
}
