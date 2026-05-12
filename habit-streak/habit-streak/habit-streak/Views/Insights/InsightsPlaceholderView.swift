//
//  InsightsPlaceholderView.swift
//  habit-streak
//
//  PRD §5.4 — full Insights deferred; placeholder until that section ships.
//

import SwiftUI

struct InsightsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.bgPrimary.ignoresSafeArea()
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        Text("Settings")
                            .foregroundStyle(AppColor.textPrimary)
                            .navigationTitle("Settings")
                            .toolbarBackground(AppColor.bgPrimary, for: .navigationBar)
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .accessibilityLabel("Settings")
                }
                ToolbarItem(placement: .principal) {
                    Text("Insights")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Color.clear.frame(width: 28, height: 28)
                }
            }
            .toolbarBackground(AppColor.bgPrimary, for: .navigationBar)
        }
    }
}
