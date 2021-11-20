//
//  Bakery.swift
//  Multithreading-Threads
//
//  Created by ruslan on 18.11.2021.
//

// Необходимо создать два сабкласса Thread. Один из них будет порождающим потоком, а второй рабочим.
// Порождающий поток должен каждые 2 секунды создавать новый экземпляр структуры Bread используя метод make()
// Созданный экземпляр он должен положить в хранилище, работающее по принципу LIFO.
// (хранилище нужно создать самостоятельно)
// Выполнение порождающего потока должно длиться 20 секунд.
// Хранилище для "хлеба" должно быть потокобезопасно.
// Рабочий поток должен ожидать появления экземпляров структуры Bread в хранилище.
// При его появлении рабочий поток забирает один "хлеб" из хранилища и вызывает метод bake().
// Также он поступает и с другими экземплярами если они есть в хранилище.
// Если нет, то снова приостанавливается в ожидании.
// Во время того, как рабочий поток "печет хлеб" порождающий поток продолжает выполнение и
// при срабатывании таймера должен также положить новую сущность Bread в хранилище.
// После окончания выполнения порождающего потока рабочий поток обрабатывает экземпляры Bread,
// оставшиеся в хранилище, и тоже заканчивает свое выполнение.
// Добавьте также в плейграунд код, создающий экземпляры этих потоков и запускающий их выполнение.

import Foundation

final class Bakery {
    
    private(set) var breadBasket = Basket()
    private let conditionVar = NSCondition()
    private var isFinished = false
    private var workerThread = WorkerThread()
    private var producerThread = ProducerThread()
    
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
                print("WAITING...\n")
            }

            if breadBasket.array.count > 0 {
                let bread = breadBasket.take()
                bread.bake()
                print("TOOK a \(bread.breadType) bread")
                print("Basket: \(breadBasket.array.count)\n")
                needToBake -= 1
            } else if breadBasket.array.count == 0 {
                conditionVar.wait()
                print("WAITING...\n")
            }
            conditionVar.unlock()
        }
        print("WORKER THREAD IS DONE!\n")
    }
    
    @objc func producerThreadAction() {
        var needToMake = 10
        let timer = Timer(timeInterval: 2.0, repeats: true) { timer in
            if needToMake != 0 {
                
                let bread = Bread.make()
                self.breadBasket.put(bread)
                needToMake -= 1
                print("PUT a \(bread.breadType) bread at \(CurrentTime.currentTime())")
                print("Basket: \(self.breadBasket.array.count)\n")
                
                self.isFinished = true
                self.conditionVar.signal()
                print("SIGNAL\n")
            } else {
                
                print("PRODUCER THREAD IS DONE!\n")
                timer.invalidate()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
    }
}
