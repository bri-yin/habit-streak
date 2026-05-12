//
//  ToastView.swift
//  habit-streak
//
//  PRD §5.1 — toast after first completion of the day.
//

import SwiftUI

struct ToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(AppColor.textPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColor.bgSecondary)
            )
            .accessibilityLabel(message)
    }
}
