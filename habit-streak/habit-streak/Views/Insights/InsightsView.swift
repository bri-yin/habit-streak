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
    @State private var heatmapWeekOffset: Int = 0

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
            }
            .toolbarBackground(AppColor.bgPrimary, for: .navigationBar)
        }
        .onChange(of: selectedTab) { _, _ in
            periodOffset = 0
        }
    }

    private func handleSwipeToOlder() {
        periodOffset += 1
    }

    private func handleSwipeToNewer() {
        if periodOffset > 0 {
            periodOffset -= 1
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
                        .foregroundStyle(selectedTab == tab ? AppColor.textPrimary : AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .liquidGlass(
                            in: Capsule(),
                            interactive: true,
                            tint: selectedTab == tab ? AppColor.accentBlue : nil,
                            fallback: selectedTab == tab ? AppColor.accentBlue : AppColor.bgTertiary
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
                    .frame(width: 40, height: 40)
                    .liquidGlass(in: Circle(), interactive: true, fallback: AppColor.bgTertiary)
            }
            .buttonStyle(.plain)
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
                    .frame(width: 40, height: 40)
                    .liquidGlass(in: Circle(), interactive: true, fallback: AppColor.bgTertiary)
            }
            .buttonStyle(.plain)
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
        let anchor: Date = store.calendar.date(byAdding: .day, value: -(heatmapWeekOffset * 7), to: Date()) ?? Date()
        let grid: [[Int]] = (try? store.heatmapGrid(weekStartsOn: store.weekStartsOn, anchorDate: anchor)) ?? Array(repeating: Array(repeating: 0, count: 26), count: 7)
        return GlassCard(contentPadding: 16) {
            ActivityHeatmapView(grid: grid, weekStartsOn: store.weekStartsOn)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20).onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                if value.translation.width < 0 {
                    heatmapWeekOffset += 1
                } else if heatmapWeekOffset > 0 {
                    heatmapWeekOffset -= 1
                }
            }
        )
    }

    @ViewBuilder
    private var chartSection: some View {
        let config: (ratios: [(date: Date, ratio: Double)], granularity: ProgressChartGranularity) =
            (selectedTab == .year || selectedTab == .all)
                ? ((try? store.monthlyCompletionRatios(in: currentInterval, habits: allHabits)) ?? [], .month)
                : ((try? store.dailyCompletionRatios(in: currentInterval, habits: allHabits)) ?? [], .day)
        let ratios: [(date: Date, ratio: Double)] = config.ratios
        let granularity: ProgressChartGranularity = config.granularity
        if ratios.isEmpty {
            EmptyView()
        } else {
            GlassCard(contentPadding: 16) {
                ProgressChartView(dailyRatios: ratios, granularity: granularity)
            }
        }
    }
}
