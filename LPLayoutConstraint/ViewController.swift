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
        v.text = "ldsjflsdfjdsu5t945utorejterjtgerjg945ut9erut9458u89utgorjgou4598tu45tu45iotg45tj5o4tu3uooujoujolf"
        v.numberOfLines = 0
        v.backgroundColor = UIColor.red
        view.addSubview(v)
        v.lp.constraints {
            $0.top.equal(to: view.lp.topMargin)
            $0.leading.equal(toConstant: 5)
            $0.trailing.lessOrEqual(toConstant: 5)
        }
        
    }
}
