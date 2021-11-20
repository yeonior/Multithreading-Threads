//
//  Basket.swift
//  Multithreading-Threads
//
//  Created by ruslan on 17.11.2021.
//

import Foundation

// thread safe array with mutex
final class Basket {
    
    private let mutex = NSLock()
    private(set) var array: [Bread] = []
    
    func put(_ object: Bread) {
        mutex.lock(); defer { mutex.unlock() }
        array.append(object)
    }
    
    func take() -> Bread {
        guard array.isEmpty == false else { fatalError("Busket is empty!") }
//        mutex.lock(); defer { mutex.unlock() }
        let lastObject = array.removeLast()
        
        return lastObject
    }
}
