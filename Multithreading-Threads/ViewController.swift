//
//  ViewController.swift
//  Multithreading-Threads
//
//  Created by ruslan on 16.11.2021.
//

import UIKit

class ViewController: UIViewController {
    
    let bakery = Bakery()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bakery.startBaking()
    }
}
