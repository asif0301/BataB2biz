//
//  View+Extensions.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import Foundation
import SwiftUI

extension Font {
    static func montserrat(_ size: CGFloat, weight: MontserratWeight = .regular) -> Font {
        .custom(weight.fontName, size: size)
    }
}

enum MontserratWeight {
    case regular, medium, semibold, bold

    var fontName: String {
        switch self {
        case .regular: "Montserrat-Regular"
        case .medium: "Montserrat-Medium"
        case .semibold: "Montserrat-SemiBold"
        case .bold: "Montserrat-Bold"
        }
    }
}

extension View {
    func montserrat(_ size: CGFloat, weight: MontserratWeight = .regular) -> some View {
        font(.montserrat(size, weight: weight))
    }
}
