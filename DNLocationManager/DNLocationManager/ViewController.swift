//
//  ViewController.swift
//  DNLocationManager
//
//  Created by mainone on 16/10/12.
//  Copyright © 2016年 wjn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DNLocationManager.shared.getUserCLLocationAndCity(cllocation: { (cllocation) in
            print(cllocation?.coordinate.latitude, cllocation?.coordinate.longitude)
            }, city: { (city) in
                print(city)
            }, cllocationError: { (error) in
                print("cllocationerror:\(error)")
            }) { (error) in
                print("cityerror:\(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

