//
//  LiquidGlass.swift
//  habit-streak
//
//  Shared helpers for Apple's native Liquid Glass (iOS 26+) with pre-26 fallbacks,
//  so icons, toggles, chips, and gesture-driven surfaces share one consistent look.
//

import SwiftUI

extension View {
    /// Applies native Liquid Glass clipped to `shape` on iOS 26+, falling back to a
    /// solid `fallback` fill on earlier systems.
    ///
    /// - Parameters:
    ///   - shape: The clip/effect shape (e.g. `Capsule()`, `Circle()`).
    ///   - interactive: When `true`, the glass reacts to touch/drag with the live
    ///     Liquid Glass deformation — used for tappable icons and gesture surfaces.
    ///   - tint: Optional tint, typically used to mark a selected control.
    ///   - fallback: The fill used on iOS 25 and earlier (`.clear` for an unselected control).
    @ViewBuilder
    func liquidGlass<S: Shape>(
        in shape: S,
        interactive: Bool = false,
        tint: Color? = nil,
        fallback: Color
    ) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(LiquidGlass.make(interactive: interactive, tint: tint), in: shape)
        } else {
            background(shape.fill(fallback))
        }
    }
}

enum LiquidGlass {
    @available(iOS 26.0, *)
    static func make(interactive: Bool, tint: Color?) -> Glass {
        var glass: Glass = .regular
        if let tint {
            glass = glass.tint(tint)
        }
        if interactive {
            glass = glass.interactive()
        }
        return glass
    }
}
