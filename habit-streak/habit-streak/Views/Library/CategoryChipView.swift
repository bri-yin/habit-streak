//
//  CategoryChipView.swift
//  habit-streak
//
//  PRD §5.3 — horizontal category chips.
//

import SwiftUI

struct CategoryChipView: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .liquidGlass(
                    in: Capsule(),
                    interactive: true,
                    tint: isSelected ? AppColor.accentBlue : nil,
                    fallback: isSelected ? AppColor.accentBlue : AppColor.bgTertiary
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
