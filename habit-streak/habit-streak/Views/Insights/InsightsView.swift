//
//  InsightsView.swift
//  habit-streak
//
//  PRD §5.4 — Insights tab: range tabs, period nav, stats, heatmap, chart, top habits.
//

import SwiftData
import SwiftUI

struct InsightsView: View {
    @Environment(HabitStore.self) private var store: HabitStore

    @Query(sort: [SortDescriptor(\Habit.order)])
    private var allHabits: [Habit]

    @State private var selectedTab: InsightsRangeTab = .week
    @State private var periodOffset: Int = 0

    private var activeHabits: [Habit] {
        allHabits.filter { $0.archivedAt == nil }
    }

    private var currentInterval: DateInterval {
        InsightsPeriod.dateInterval(
            tab: selectedTab,
            offset: periodOffset,
            weekStartsOn: store.weekStartsOn,
            calendar: store.calendar,
            habitsForAll: activeHabits
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.bgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        rangeTabs

                        periodNavigationRow

                        statsRow

                        heatmapSection

                        chartSection

                        TopHabitsView(
                            habits: (try? store.topPerformingHabits(in: currentInterval, habits: allHabits)) ?? [],
                            interval: currentInterval,
                            store: store
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
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
        .onChange(of: selectedTab) { _, _ in
            periodOffset = 0
        }
    }

    private var rangeTabs: some View {
        HStack(spacing: 8) {
            ForEach(InsightsRangeTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(selectedTab == tab ? AppColor.bgPrimary : AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? AppColor.textPrimary : AppColor.bgTertiary)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab == .all ? "All time" : "\(tab.rawValue) range")
                .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
            }
        }
    }

    private var periodNavigationRow: some View {
        HStack {
            Button {
                periodOffset += 1
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }
            .accessibilityLabel("Previous period")

            Spacer()
            Text(InsightsPeriod.rangeLabel(for: currentInterval, tab: selectedTab))
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()

            Button {
                if periodOffset > 0 {
                    periodOffset -= 1
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(periodOffset > 0 ? AppColor.textPrimary : AppColor.textTertiary)
            }
            .disabled(periodOffset == 0)
            .accessibilityLabel("Next period")
        }
    }

    private var statsRow: some View {
        let completions: Int = (try? store.completionCount(in: currentInterval)) ?? 0
        let rate: Double = (try? store.completionRate(in: currentInterval, habits: allHabits)) ?? 0
        return HStack(spacing: 12) {
            StatCardView(title: "Completions", valueText: "\(completions)")
            StatCardView(title: "Completion rate", valueText: "\(Int(rate))%")
        }
    }

    private var heatmapSection: some View {
        let grid: [[Int]] = (try? store.heatmapGrid(weekStartsOn: store.weekStartsOn)) ?? Array(repeating: Array(repeating: 0, count: 26), count: 7)
        return ActivityHeatmapView(grid: grid, weekStartsOn: store.weekStartsOn)
    }

    @ViewBuilder
    private var chartSection: some View {
        let ratios: [(date: Date, ratio: Double)] = (try? store.dailyCompletionRatios(in: currentInterval, habits: allHabits)) ?? []
        if ratios.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                ProgressChartView(dailyRatios: ratios)
                    .frame(minWidth: max(320, CGFloat(ratios.count) * 14))
            }
        }
    }
}
