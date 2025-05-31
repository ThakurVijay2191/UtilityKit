//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Apple on 31/05/25.
//

import SwiftUI

struct ToastConfig: Identifiable{
    var id: String = UUID().uuidString
    var symbol: ImageResource?
    var text: String
    var shape: AnyShape = .init(.capsule)
    var animation: Animation = .snappy(duration: 0.35, extraBounce: 0.1)
    
}

enum ToastDuration: TimeInterval {
    case short = 2.0   // 2 seconds
    case medium = 4.0  // 4 seconds
    case long = 6.0    // 6 seconds
}

struct ToastsView: View {
    @State private var isToastPresented: Bool = false
    @State private var toasts: [ToastConfig] = []
    @State private var isTapped: Bool = false
    var body: some View {
        Button("Show Toasts") {
            withAnimation(.snappy(duration: 0.35)) {
                let config = ToastConfig(text: "This is toast", shape: .init(.capsule))
                withAnimation(config.animation) {
                    toasts.insert(config, at: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.red)
        .overlay{
            if isTapped {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.35, extraBounce: 0.1)) {
                            isTapped.toggle()
                        }
                    }
            }
        }
        .overlay(alignment: .bottom) {
            if toasts.count > 0 {
                let isZStack = !isTapped
                let layout = isTapped ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(ZStackLayout())
                ViewThatFits {
                    layout {
                        ForEach(Array(toasts.enumerated()), id: \.element.id) { index, toast in
                            Capsule()
                                .fill(.white)
                                .frame(height: 50)
                                .scaleEffect(isZStack ? scale(for: index) : 1)
                                .offset(y: isZStack ? offset(for: index) : 0)
                                .zIndex(isZStack ? Double(toasts.count - index) : 0)
                                .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                                .onTapGesture {
                                    withAnimation(toast.animation) {
                                        isTapped.toggle()
                                    }
                                }
                        }
                    }
                    
                    ScrollView {
                        layout {
                            ForEach(toasts) { toast in
                                Button{
                                    withAnimation(toast.animation) {
                                        isTapped.toggle()
                                    }
                                    
                                } label: {
                                    Capsule()
                                        .fill(.white)
                                        .frame(height: 50)
                                        .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .scrollClipDisabled()
                    .scrollIndicators(.hidden)
                }
                .padding()
            }
        }
    }
    
    // Helper functions to calculate offset and scale for stacking effect
    private func offset(for index: Int) -> CGFloat {
        // Show offset for first 3, rest stack at same height
        if index < 3 {
            return CGFloat(index) * -15  // each step is 15pt higher than the next
        } else {
            return -30  // clip rest behind top 3
        }
    }

    private func scale(for index: Int) -> CGFloat {
        if index == 0 { return 1 }
        if index == 1 { return 0.9 }
        if index == 2 { return 0.8 }
        return 0.8
    }
    
    func removeToast(_ toast: ToastConfig) {
        toasts.removeAll { $0.id == toast.id }
    }
}

#Preview {
    ToastsView()
}
