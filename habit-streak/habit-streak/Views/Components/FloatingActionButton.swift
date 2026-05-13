//
//  FloatingActionButton.swift
//  habit-streak
//
//  PRD §5.1 / §12 — FAB (+) bottom-trailing.
//

import SwiftUI

struct FloatingActionButton: View {
    var accessibilityLabelText: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColor.bgPrimary)
                .frame(width: 56, height: 56)
                .background(Circle().fill(AppColor.textPrimary))
        }
        .buttonStyle(.plain)
        .shadow(color: Color.black.opacity(0.35), radius: 12, y: 6)
        .accessibilityLabel(accessibilityLabelText)
    }
}
