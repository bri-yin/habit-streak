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
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 4) {
                    barContent
                        .padding(4)
                        .glassEffect(.regular, in: Capsule())
                }
            } else {
                barContent
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private var barContent: some View {
        HStack(spacing: 0) {
            tabButton(tab: .home, systemImage: "house.fill", label: "Home")
            tabButton(tab: .insights, systemImage: "chart.bar.fill", label: "Insights")
        }
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
            .modifier(SelectedTabBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Selected-tab highlight: a native interactive Liquid Glass pill on iOS 26,
/// falling back to a tinted capsule on earlier systems.
private struct SelectedTabBackground: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if isSelected {
                content.glassEffect(.regular.interactive(), in: Capsule())
            } else {
                content
            }
        } else {
            content.background(
                Capsule()
                    .fill(isSelected ? AppColor.bgTertiary.opacity(0.55) : Color.clear)
            )
        }
    }
}
