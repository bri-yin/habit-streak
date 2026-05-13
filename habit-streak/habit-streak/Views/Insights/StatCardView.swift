//
//  StatCardView.swift
//  habit-streak
//
//  PRD §5.4 — stat grid card.
//

import SwiftUI

struct StatCardView: View {
    var title: String
    var valueText: String

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(AppColor.textSecondary)
                Text(valueText)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title), \(valueText)")
        }
    }
}
