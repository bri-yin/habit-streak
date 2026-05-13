//
//  Enums.swift
//  habit-streak
//

import Foundation

enum FrequencyMode: String, Codable {
    case daily
    case weekly
    case monthly
}

enum WeekDay: Int, Codable, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

enum WeekStartDay: String, Codable, CaseIterable {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}
