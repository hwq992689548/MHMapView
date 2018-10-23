//
//  ViewController.swift
//  TestMap
//
//  Created by 裴威 on 2018/10/1.
//  Copyright © 2018年 com.xiantian. All rights reserved.
//

import UIKit


class ViewController: UIViewController,MAMapViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    
        let button = UIButton.init(frame: CGRect.init(x: 100, y: 100, width: 100, height: 100))
        button.backgroundColor = UIColor.green
        button.addTarget(self, action: #selector(buttonAction), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
    }
    
    
    @objc func buttonAction(){
        let vcc = MHMapViewController()
        self.navigationController?.pushViewController(vcc, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

