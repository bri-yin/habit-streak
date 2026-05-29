//
//  WeekdayPickerView.swift
//  habit-streak
//
//  PRD §5.2 — seven circular weekday toggles (S M T W T F S order).
//

import SwiftUI

struct WeekdayPickerView: View {
    @Binding var selectedWeekdays: Set<WeekDay>

    private let columns: [WeekDay] = [
        .sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday,
    ]

    private let letters: [String] = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(columns.enumerated()), id: \.element) { index, day in
                weekdayButton(day: day, letter: letters[index])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Weekdays")
    }

    @ViewBuilder
    private func weekdayButton(day: WeekDay, letter: String) -> some View {
        let isOn: Bool = selectedWeekdays.contains(day)
        Button {
            if isOn {
                if selectedWeekdays.count > 1 {
                    selectedWeekdays.remove(day)
                }
            } else {
                selectedWeekdays.insert(day)
            }
        } label: {
            Text(letter)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isOn ? AppColor.textPrimary : AppColor.textSecondary)
                .frame(width: 40, height: 40)
                .liquidGlass(
                    in: Circle(),
                    interactive: true,
                    tint: isOn ? AppColor.accentBlue : nil,
                    fallback: isOn ? AppColor.accentBlue : AppColor.bgTertiary
                )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityLabel(Text(day.accessibilityTitle))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

private extension WeekDay {
    var accessibilityTitle: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}
