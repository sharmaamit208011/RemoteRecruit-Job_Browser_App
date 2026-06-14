//
//  AppTheme.swift
//  RemoteRecruit
//
//  Created by Amit Sharma on 14/06/26.
//

import SwiftUI

enum AppTheme {
    enum Color {
        static let accent = SwiftUI.Color("AccentColor")
        static let cardBackground = SwiftUI.Color("CardBackground")
        static let primaryText = SwiftUI.Color("PrimaryText")
        static let secondaryText = SwiftUI.Color("SecondaryText")
        static let tagBackground = SwiftUI.Color("TagBackground")
        static let gradientStart = SwiftUI.Color("GradientStart")
        static let gradientEnd = SwiftUI.Color("GradientEnd")
    }

    enum Font {
        static func title() -> SwiftUI.Font { .system(size: 26, weight: .bold, design: .rounded) }
        static func headline() -> SwiftUI.Font { .system(size: 17, weight: .semibold, design: .rounded) }
        static func subheadline() -> SwiftUI.Font { .system(size: 14, weight: .medium, design: .rounded) }
        static func caption() -> SwiftUI.Font { .system(size: 12, weight: .regular, design: .rounded) }
        static func body() -> SwiftUI.Font { .system(size: 15, weight: .regular, design: .rounded) }
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let card: CGFloat = 16
        static let tag: CGFloat = 8
        static let button: CGFloat = 12
    }
}
