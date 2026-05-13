//
//  Templates.swift
//  habit-streak
//
//  PRD §5.3 — habit library templates (initial set).
//

import Foundation

enum HabitTemplateCategory: String, CaseIterable, Identifiable {
    case popular
    case health
    case fitness
    case mindfulness
    case productivity
    case finance
    case breakBad

    var id: String { rawValue }

    var chipTitle: String {
        switch self {
        case .popular: return "⭐ Popular"
        case .health: return "🌿 Health & Nutrition"
        case .fitness: return "💪 Fitness"
        case .mindfulness: return "🧘 Mindfulness"
        case .productivity: return "🚀 Productivity"
        case .finance: return "💰 Finance"
        case .breakBad: return "🚫 Break bad habits"
        }
    }

    var sectionHeading: String {
        switch self {
        case .popular: return "Popular"
        case .health: return "Health & Nutrition"
        case .fitness: return "Fitness"
        case .mindfulness: return "Mindfulness"
        case .productivity: return "Productivity"
        case .finance: return "Finance"
        case .breakBad: return "Break bad habits"
        }
    }

    var sectionSubheading: String {
        switch self {
        case .popular: return "Great starting points for your streak."
        case .health: return "Fuel your body and mind."
        case .fitness: return "Move a little every day."
        case .mindfulness: return "Slow down and reset."
        case .productivity: return "Build momentum on what matters."
        case .finance: return "Small steps toward financial calm."
        case .breakBad: return "Replace habits with intention."
        }
    }
}

struct HabitTemplate: Identifiable, Equatable {
    let id: String
    let category: HabitTemplateCategory
    let emoji: String
    let name: String
    let description: String
    let frequency: FrequencyMode
    let weekdays: Set<WeekDay>
    let countPerPeriod: Int

    func toPrefill() -> HabitCreationPrefill {
        HabitCreationPrefill(
            name: name,
            emoji: emoji,
            frequency: frequency,
            weekdays: weekdays,
            countPerPeriod: countPerPeriod
        )
    }
}

enum HabitTemplateLibrary {
    static let all: [HabitTemplate] = [
        // Popular (PRD §9 / §5.3)
        HabitTemplate(id: "pop_gym", category: .popular, emoji: "🏋️", name: "Gym Workout", description: "Strength or cardio sessions.", frequency: .daily, weekdays: [.monday, .wednesday, .friday], countPerPeriod: 1),
        HabitTemplate(id: "pop_water", category: .popular, emoji: "💧", name: "Drink Enough Water", description: "Stay hydrated all day.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "pop_sleep", category: .popular, emoji: "😴", name: "7h Sleep", description: "Protect your rest window.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "pop_read", category: .popular, emoji: "📖", name: "Read a Book", description: "Even a few pages count.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "pop_meditation", category: .popular, emoji: "🧘", name: "Meditation", description: "Quiet the noise for a few minutes.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "pop_steps", category: .popular, emoji: "👣", name: "10k Steps", description: "Move toward a daily step goal.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "pop_eat", category: .popular, emoji: "🥦", name: "Eat Healthier", description: "One better meal choice today.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "pop_social", category: .popular, emoji: "📵", name: "Social Media Limit", description: "Mindful screen time boundaries.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),

        // Health & Nutrition
        HabitTemplate(id: "hn_veg", category: .health, emoji: "🥗", name: "Eat Vegetables", description: "Add greens to one meal.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "hn_vitd", category: .health, emoji: "☀️", name: "Vitamin D Walk", description: "Short walk in daylight.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "hn_fast", category: .health, emoji: "⏱️", name: "Intermittent Fast", description: "Stick to your eating window.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "hn_sugar", category: .health, emoji: "🍎", name: "Fruit Snack", description: "Swap processed sugar for fruit.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "hn_cook", category: .health, emoji: "🍳", name: "Cook at Home", description: "Homemade beats takeout.", frequency: .weekly, weekdays: Set(WeekDay.allCases), countPerPeriod: 5),
        HabitTemplate(id: "hn_salad", category: .health, emoji: "🥬", name: "Salad a Day", description: "Fresh bowl once per day.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),

        // Fitness
        HabitTemplate(id: "fit_run", category: .fitness, emoji: "🏃", name: "Morning Run", description: "Cardio to start the day.", frequency: .daily, weekdays: [.tuesday, .thursday, .saturday], countPerPeriod: 1),
        HabitTemplate(id: "fit_push", category: .fitness, emoji: "💪", name: "Pushups", description: "Quick strength set.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "fit_stretch", category: .fitness, emoji: "🤸", name: "Stretching", description: "Loosen up for five minutes.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "fit_yoga", category: .fitness, emoji: "🧘‍♀️", name: "Yoga Flow", description: "Balance mobility and breath.", frequency: .weekly, weekdays: Set(WeekDay.allCases), countPerPeriod: 3),
        HabitTemplate(id: "fit_walk", category: .fitness, emoji: "🚶", name: "Walk 20 Minutes", description: "Low-impact movement break.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "fit_bike", category: .fitness, emoji: "🚴", name: "Bike Ride", description: "Pedal for fun or commute.", frequency: .weekly, weekdays: Set(WeekDay.allCases), countPerPeriod: 2),

        // Mindfulness
        HabitTemplate(id: "mind_journal", category: .mindfulness, emoji: "📓", name: "Journal", description: "Three lines of gratitude.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "mind_breath", category: .mindfulness, emoji: "🌬️", name: "Breathwork", description: "Box breathing for calm.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "mind_nature", category: .mindfulness, emoji: "🌳", name: "Nature Time", description: "Touch grass, literally.", frequency: .weekly, weekdays: Set(WeekDay.allCases), countPerPeriod: 2),
        HabitTemplate(id: "mind_music", category: .mindfulness, emoji: "🎵", name: "Listen Mindfully", description: "One album, no skipping.", frequency: .weekly, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "mind_phone", category: .mindfulness, emoji: "📴", name: "Phone-Free Hour", description: "Disconnect to reconnect.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),

        // Productivity (PRD list + extras)
        HabitTemplate(id: "prod_plan", category: .productivity, emoji: "📅", name: "Plan Your Day", description: "Top three priorities on paper.", frequency: .daily, weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday], countPerPeriod: 1),
        HabitTemplate(id: "prod_deep", category: .productivity, emoji: "💻", name: "Deep Work", description: "Focused block without pings.", frequency: .daily, weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday], countPerPeriod: 1),
        HabitTemplate(id: "prod_bed", category: .productivity, emoji: "🛏️", name: "Make Bed", description: "Win the first minute of the day.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "prod_wake", category: .productivity, emoji: "⏰", name: "Wake Up at Consistent Time", description: "Same alarm, same rise.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "prod_prep", category: .productivity, emoji: "✍️", name: "Prepare for Tomorrow", description: "Set out clothes or bag tonight.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "prod_screen", category: .productivity, emoji: "💻", name: "No Screen 1h Before Bed", description: "Wind down without blue light.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "prod_inbox", category: .productivity, emoji: "📥", name: "Inbox Zero", description: "Process email once a day.", frequency: .daily, weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday], countPerPeriod: 1),

        // Finance
        HabitTemplate(id: "fin_track", category: .finance, emoji: "📊", name: "Track Spending", description: "Log purchases in your app.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "fin_save", category: .finance, emoji: "🏦", name: "Save a Little", description: "Automate or manual micro-save.", frequency: .weekly, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "fin_sub", category: .finance, emoji: "📺", name: "Review Subscriptions", description: "Cut unused recurring charges.", frequency: .monthly, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "fin_budget", category: .finance, emoji: "🧾", name: "Weekly Budget Check", description: "15 minutes with your numbers.", frequency: .weekly, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "fin_invest", category: .finance, emoji: "📈", name: "Read Market Notes", description: "Stay informed, stay calm.", frequency: .weekly, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),

        // Break bad habits (PRD)
        HabitTemplate(id: "bad_junk", category: .breakBad, emoji: "🍟", name: "No Junk Food", description: "Choose whole foods today.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "bad_sugar", category: .breakBad, emoji: "🍬", name: "Sugar Resist", description: "Skip the extra sweet bite.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "bad_alc", category: .breakBad, emoji: "🚫", name: "Alcohol Free", description: "Clear mind, clear week.", frequency: .weekly, weekdays: Set(WeekDay.allCases), countPerPeriod: 7),
        HabitTemplate(id: "bad_smoke", category: .breakBad, emoji: "🚭", name: "No Smoking", description: "One craving at a time.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "bad_snooze", category: .breakBad, emoji: "⏰", name: "No Snooze", description: "Feet on the floor on alarm one.", frequency: .daily, weekdays: Set(WeekDay.allCases), countPerPeriod: 1),
        HabitTemplate(id: "bad_out", category: .breakBad, emoji: "🍽️", name: "No Eating Out", description: "Home cooking wins today.", frequency: .weekly, weekdays: Set(WeekDay.allCases), countPerPeriod: 5),
    ]

    static func templates(in category: HabitTemplateCategory) -> [HabitTemplate] {
        all.filter { $0.category == category }
    }

    static func search(_ query: String) -> [HabitTemplate] {
        let q: String = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return all }
        return all.filter {
            $0.name.lowercased().contains(q) || $0.description.lowercased().contains(q)
        }
    }
}
