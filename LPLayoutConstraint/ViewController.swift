//
//  ViewController.swift
//  LPLayoutConstraint
//
//  Created by pengli on 2019/8/6.
//  Copyright © 2019 pengli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = UILabel()
        v.text = "LPLayoutConstraint"
        v.numberOfLines = 0
        v.backgroundColor = UIColor.red
        view.addSubview(v)
        
        v.lp.constraints {
            $0.top.equal(to: view.lp.topSafe)
            $0.leading.equal(toConstant: 5)
            //$0.trailing.lessOrEqual(toConstant: 5)
            
//            $0.size.equal(toConstant: 50)
            $0.size.equal(to: CGSize(width: 40, height: 80))
        }
        
        v.lp.constraints {
            $0.top.update(constant: 100)
            $0.size.update(constant: 300)
        }
    }
}
