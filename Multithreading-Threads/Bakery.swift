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
        var needToBake = 10
        while needToBake > 0 {
            conditionVar.lock()
            
            while !isFinished {
                conditionVar.wait()
            }

            if breadBasket.array.count > 0 {
                let bread = breadBasket.take()
                bread.bake()
                print("Took a \(bread.breadType) bread")
                print("Basket: \(breadBasket.array.count)\n")
                needToBake -= 1
            } else if breadBasket.array.count == 0 {
                conditionVar.wait()
            }
            conditionVar.unlock()
        }
        print("WORKER THREAD IS DONE!\n")
    }
    
    @objc func producerThreadAction() {
        
    }
}
