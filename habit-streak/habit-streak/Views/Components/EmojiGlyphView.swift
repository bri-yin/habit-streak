//
//  EmojiGlyphView.swift
//  habit-streak
//
//  PRD §3 — Full-color emoji in Lists. UILabel needs a real intrinsic size or SwiftUI
//  can collapse it to a tiny box (replacement “?” glyph). PRD §5.1 / §5.3.
//

import SwiftUI
import UIKit

private final class EmojiIntrinsicLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        guard let text, let font, !text.isEmpty else {
            return CGSize(width: 28, height: 28)
        }
        let maxSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = (text as NSString).boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        let w: CGFloat = max(28, ceil(rect.width) + 4)
        let h: CGFloat = max(28, ceil(rect.height) + 4)
        return CGSize(width: w, height: h)
    }
}

struct EmojiGlyphView: UIViewRepresentable {
    var text: String
    var fontSize: CGFloat

    func makeUIView(context: Context) -> UILabel {
        let label: EmojiIntrinsicLabel = EmojiIntrinsicLabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.backgroundColor = .clear
        label.clipsToBounds = false
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        let trimmed: String = text.trimmingCharacters(in: .whitespacesAndNewlines)
        uiView.text = trimmed.isEmpty ? "⭐️" : trimmed
        uiView.font = UIFont.systemFont(ofSize: fontSize)
        uiView.invalidateIntrinsicContentSize()
    }
}
