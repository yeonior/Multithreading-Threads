//
//  CurrentTime.swift
//  Multithreading-Threads
//
//  Created by ruslan on 20.11.2021.
//

import Foundation

final class CurrentTime {
    static func currentTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let nanosecond = calendar.component(.nanosecond, from: date)
        return "\(hour):\(minute):\(second):\(nanosecond)"
    }
}
