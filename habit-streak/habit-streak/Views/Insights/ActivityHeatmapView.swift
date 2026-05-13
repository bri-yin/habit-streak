//
//  ActivityHeatmapView.swift
//  habit-streak
//
//  PRD §5.4 — 7×26 heatmap; intensity buckets 0 / 1–2 / 3–4 / 5+.
//

import SwiftUI

struct ActivityHeatmapView: View {
    var grid: [[Int]]
    var weekStartsOn: WeekStartDay

    private let cellSpacing: CGFloat = 4
    private let cellSize: CGFloat = 12
    private let rows: Int = 7
    private let cols: Int = 26

    private var rowLabels: [String] {
        DateHelpers.weekStripLetters(weekStartsOn: weekStartsOn)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)

            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .trailing, spacing: cellSpacing) {
                    ForEach(0..<rows, id: \.self) { row in
                        Text(row < rowLabels.count ? rowLabels[row] : "")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(AppColor.textSecondary)
                            .frame(width: 16, height: cellSize)
                    }
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(cellSize), spacing: cellSpacing), count: cols),
                        alignment: .leading,
                        spacing: cellSpacing
                    ) {
                        ForEach(0..<(rows * cols), id: \.self) { idx in
                            let row: Int = idx / cols
                            let col: Int = idx % cols
                            let count: Int = (row < grid.count && col < grid[row].count) ? grid[row][col] : 0
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(cellColor(bucket: Self.intensityBucket(count)))
                                .frame(width: cellSize, height: cellSize)
                                .accessibilityLabel("Week column \(col + 1), row \(row + 1), \(count) completions")
                        }
                    }
                }
            }
        }
    }

    /// PRD §5.4 intensity buckets.
    private static func intensityBucket(_ count: Int) -> Int {
        switch count {
        case 0:
            return 0
        case 1...2:
            return 1
        case 3...4:
            return 2
        default:
            return 3
        }
    }

    private func cellColor(bucket: Int) -> Color {
        switch bucket {
        case 0:
            return AppColor.bgTertiary
        case 1:
            return AppColor.accentGreen.opacity(0.35)
        case 2:
            return AppColor.accentGreen.opacity(0.65)
        default:
            return AppColor.accentGreen
        }
    }
}
