//
//  Bakery.swift
//  Multithreading-Threads
//
//  Created by ruslan on 18.11.2021.
//

import Foundation

final class Bakery {
    
    var breadBasket = Basket()
    let conditionVar = NSCondition()
    var isFinished = false
    var workerThread = WorkerThread()
    var producerThread = ProducerThread()
    
    init() {
        workerThread = WorkerThread(target: self, selector: #selector(workerThreadAction), object: nil)
        producerThread = ProducerThread(target: self, selector: #selector(producerThreadAction), object: nil)
    }
    
    func startBaking() {
        workerThread.start()
        producerThread.start()
    }
    
    @objc func workerThreadAction() {
        
    }
    
    @objc func producerThreadAction() {
        
    }
}
