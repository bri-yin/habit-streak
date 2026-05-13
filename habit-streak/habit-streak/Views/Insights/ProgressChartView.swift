//
//  ProgressChartView.swift
//  habit-streak
//
//  PRD §5.4 — bar chart of completion percentage per day (Swift Charts).
//

import Charts
import SwiftUI

private struct DailyRatioPoint: Identifiable {
    let id: Date
    let date: Date
    let ratio: Double
}

enum ProgressChartGranularity: Equatable {
    case day
    case month
}

struct ProgressChartView: View {
    var dailyRatios: [(date: Date, ratio: Double)]
    var granularity: ProgressChartGranularity = .day

    private var points: [DailyRatioPoint] {
        dailyRatios.map { DailyRatioPoint(id: $0.date, date: $0.date, ratio: $0.ratio) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily completion")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)

            Chart(points) { item in
                BarMark(
                    x: .value("Day", item.date, unit: granularity == .day ? .day : .month),
                    y: .value("Percent", item.ratio)
                )
                .foregroundStyle(AppColor.accentGreen)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: granularity == .day ? .day : .month)) { _ in
                    AxisTick()
                    AxisValueLabel(format: granularity == .day ? .dateTime.month().day() : .dateTime.month(.abbreviated), centered: true)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(Int(v))%")
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                }
            }
            .applyIf(granularity == .day) { view in
                view.chartScrollableAxes(.horizontal)
            }
            .frame(height: 200)
            .accessibilityLabel("Progress chart by day")
        }
    }
}

private extension View {
    @ViewBuilder
    func applyIf<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
