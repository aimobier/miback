//
//  ViewController.swift
//  MiBack
//
//  Created by 荆文征 on 2018/9/3.
//  Copyright © 2018年 com.jwz. All rights reserved.
//

import UIKit

class ViewController: UIViewController,MIBackGestureRecognizerProtocol {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.miBackInitialization()
    }

    func miBackDidBack() {
        
        self.dismiss(animated: true, completion: nil)
    }
}


