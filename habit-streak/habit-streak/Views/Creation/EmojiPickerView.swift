//
//  EmojiPickerView.swift
//  habit-streak
//
//  PRD §5.2 — pick emoji for habit name field companion.
//

import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss

    private static let gridEmojis: [String] = [
        "⭐️", "🔥", "💧", "😴", "📖", "🧘", "👣", "🥦", "📵", "🏋️", "🏃", "♟️",
        "🛏️", "⏰", "✍️", "💻", "📅", "🍟", "🍬", "🚫", "🚭", "🍽️", "💪", "🌿",
        "🚀", "💰", "🧠", "❤️", "🎯", "✅", "🎸", "🐶", "☕️", "🥗", "🚴", "🏊",
    ]

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.bgPrimary.ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Self.gridEmojis, id: \.self) { emoji in
                            Button {
                                selectedEmoji = emoji
                                dismiss()
                            } label: {
                                Text(verbatim: emoji)
                                    .font(.system(size: 32))
                                    .frame(width: 48, height: 48)
                                    .liquidGlass(
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous),
                                        interactive: true,
                                        tint: selectedEmoji == emoji ? AppColor.accentBlue : nil,
                                        fallback: selectedEmoji == emoji ? AppColor.bgTertiary : .clear
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Emoji \(emoji)")
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.bgPrimary, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
        }
    }
}
