//
//  TemplateCardView.swift
//  habit-streak
//
//  PRD §5.3 — template row card.
//

import SwiftUI

struct TemplateCardView: View {
    var template: HabitTemplate
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 16) {
                EmojiGlyphView(text: template.emoji, fontSize: 32)
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(template.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(template.description)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.bgSecondary)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(template.name). \(template.description)")
    }
}
