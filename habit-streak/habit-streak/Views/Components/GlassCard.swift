//
//  GlassCard.swift
//  habit-streak
//
//  Shared "liquid glass" surface for cards/pills (iOS material).
//

import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 16
    var contentPadding: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(contentPadding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
    }
}

