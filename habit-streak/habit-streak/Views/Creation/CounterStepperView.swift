//
//  CounterStepperView.swift
//  habit-streak
//
//  PRD §5.2 — stepper with minus disabled at 1 (PRD §8).
//

import SwiftUI

struct CounterStepperView: View {
    var label: String
    @Binding var value: Int
    var range: ClosedRange<Int>

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            HStack(spacing: 16) {
                Button {
                    if value > range.lowerBound {
                        value -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(value > range.lowerBound ? AppColor.textPrimary : AppColor.textTertiary)
                }
                .buttonStyle(.plain)
                .disabled(value <= range.lowerBound)
                .accessibilityLabel("Decrease count")

                Text("\(value)×")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(minWidth: 44)

                Button {
                    if value < range.upperBound {
                        value += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(value < range.upperBound ? AppColor.textPrimary : AppColor.textTertiary)
                }
                .buttonStyle(.plain)
                .disabled(value >= range.upperBound)
                .accessibilityLabel("Increase count")
            }
        }
        .padding(.vertical, 8)
    }
}
