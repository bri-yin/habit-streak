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
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        if #available(iOS 26.0, *) {
            content()
                .padding(contentPadding)
                .glassEffect(.regular, in: shape)
        } else {
            content()
                .padding(contentPadding)
                .background(.ultraThinMaterial)
                .clipShape(shape)
                .overlay(shape.stroke(Color.white.opacity(0.10), lineWidth: 1))
        }
    }
}

