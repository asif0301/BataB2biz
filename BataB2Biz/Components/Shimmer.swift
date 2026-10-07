//
//  Shimmer.swift
//  BataB2Biz
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.55), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: proxy.size.width * 0.55)
                    .rotationEffect(.degrees(18))
                    .offset(x: phase * proxy.size.width * 2)
                }
                .mask(content)
            }
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.15).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

struct SkeletonBlock: View {
    let width: CGFloat?
    let height: CGFloat
    var cornerRadius: CGFloat = 8

    var body: some View {
        Group {
            if let width {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.16))
                    .frame(width: width, height: height)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.16))
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
            }
        }
        .shimmer()
    }
}
