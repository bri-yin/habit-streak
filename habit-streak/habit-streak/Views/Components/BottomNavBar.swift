//
//  BottomNavBar.swift
//  habit-streak
//
//  PRD §5.1 — custom pill tab bar: Home and Insights.
//

import SwiftUI

enum MainTab: Hashable {
    case home
    case insights
}

struct BottomNavBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 0) {
            tabButton(tab: .home, systemImage: "house.fill", label: "Home")
            tabButton(tab: .insights, systemImage: "chart.bar.fill", label: "Insights")
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func tabButton(tab: MainTab, systemImage: String, label: String) -> some View {
        let isSelected: Bool = selectedTab == tab
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                Text(label)
                    .font(.system(size: 13, weight: .regular))
            }
            .foregroundStyle(isSelected ? AppColor.textPrimary : AppColor.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? AppColor.bgTertiary.opacity(0.55) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
