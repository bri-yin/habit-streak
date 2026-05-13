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

struct ProgressChartView: View {
    var dailyRatios: [(date: Date, ratio: Double)]

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
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Percent", item.ratio)
                )
                .foregroundStyle(AppColor.accentGreen)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(AppColor.textTertiary)
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day(), centered: true)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(AppColor.textTertiary)
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(Int(v))%")
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                }
            }
            .frame(height: 200)
            .accessibilityLabel("Progress chart by day")
        }
    }
}
