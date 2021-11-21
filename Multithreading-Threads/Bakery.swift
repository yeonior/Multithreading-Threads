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
    
    private var breadBasket = Basket()
    private var breads = 0
    private let conditionVar = NSCondition()
    private var workerThread = WorkerThread()
    private var producerThread = ProducerThread()
    private var breadIsMade = false
    private var threadsAreDone = false {
        didSet {
            workerThread.cancel()
            producerThread.cancel()
            print("THREADS ARE DONE!!!")
        }
    }
    
    init(breads: Int) {
        self.breads = breads
        workerThread = WorkerThread(target: self, selector: #selector(workerThreadAction), object: nil)
        producerThread = ProducerThread(target: self, selector: #selector(producerThreadAction), object: nil)
    }
    
    public func startBaking() {
        workerThread.start()
        producerThread.start()
    }
    
    @objc private func workerThreadAction() {
        var needToBake = breads
        while needToBake != 0 {
            conditionVar.lock()
            
            while !breadIsMade {
                print("WAITING...\n")
                conditionVar.wait()
            }

            if breadBasket.array.count > 0 {
                let bread = breadBasket.take()
                print("TOOK a \(bread.breadType) bread")
                print("Basket: \(breadBasket.array.count)\n")
                bread.bake()
                needToBake -= 1
            } else if breadBasket.array.count == 0 {
                print("WAITING...\n")
                conditionVar.wait()
            }
            conditionVar.unlock()
        }
        print("WORKER THREAD IS DONE!\n")
        threadsAreDone = true
    }
    
    @objc private func producerThreadAction() {
        var needToMake = breads
        let timer = Timer(timeInterval: 0.01, repeats: true) { timer in
            if needToMake != 0 {
                
                let bread = Bread.make()
                self.breadBasket.put(bread)
                needToMake -= 1
                print("PUT a \(bread.breadType) bread at \(CurrentTime.currentTime())")
                print("Basket: \(self.breadBasket.array.count)\n")
                
                self.breadIsMade = true
                self.conditionVar.signal()
            } else {
                print("PRODUCER THREAD IS DONE!\n")
                timer.invalidate()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
    }
}
