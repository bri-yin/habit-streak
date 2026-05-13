//
//  FrequencySegmentedControl.swift
//  habit-streak
//
//  PRD §5.2 — Daily / Weekly / Monthly frequency control.
//

import SwiftUI

struct FrequencySegmentedControl: View {
    @Binding var selection: FrequencyMode

    var body: some View {
        Picker("Frequency", selection: $selection) {
            Text("Daily").tag(FrequencyMode.daily)
            Text("Weekly").tag(FrequencyMode.weekly)
            Text("Monthly").tag(FrequencyMode.monthly)
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Frequency")
    }
}
