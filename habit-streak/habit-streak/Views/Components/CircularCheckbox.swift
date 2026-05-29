//
//  CircularCheckbox.swift
//  habit-streak
//
//  PRD §5.1 — circular checkbox with spring animation (PRD §12).
//

import SwiftUI

struct CircularCheckbox: View {
    var isCompleted: Bool
    var accessibilityLabelText: String

    var body: some View {
        ZStack {
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
        .frame(width: 28, height: 28)
        .liquidGlass(
            in: Circle(),
            interactive: true,
            tint: isCompleted ? AppColor.accentGreen : nil,
            fallback: .clear
        )
        .overlay {
            if !isCompleted {
                Circle().strokeBorder(AppColor.textTertiary, lineWidth: 2)
            }
        }
        .scaleEffect(isCompleted ? 1.0 : 0.8)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
        .accessibilityLabel(accessibilityLabelText)
        .accessibilityAddTraits(isCompleted ? .isSelected : [])
    }
}
