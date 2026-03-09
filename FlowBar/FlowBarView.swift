// MARK: - State

enum FlowBarState {
    case collapsed
    case expanded
    case expandedWithTooptip
    case recording
}

import SwiftUI

struct FlowBarView: View {
    
    @State private var state: FlowBarState = .collapsed
    @State private var tooltipTask: Task<Void, Never>?
    
    var body: some View {
        contentView
            .overlay(alignment: .top) {
                if state == .expandedWithTooptip {
                    TooltipView()
                        .fixedSize()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .offset(y: -40)
                }
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if state == .collapsed {
            CollapsedBar()
                .onTapGesture{ expand() }
        } else {
            ExpandedBar(
                isRecording: state == .recording,
                onStop: { collapse() },
                onCancel: { collapse() }
            )
            .onTapGesture {
                if state != .recording {
                    startRecording()
                }
            }
        }
        
    }
    
    // MARK: - Functions
    
    private func expand() {
        state = .expanded
        tooltipTask?.cancel()
        tooltipTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    state = .expandedWithTooptip
                }
            }
        }
    }
    
    private func startRecording() {
        tooltipTask?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            state = .recording
        }
    }
    
    private func collapse() {
        tooltipTask?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            state = .collapsed
        }
    }
}

// MARK: - CollapsedBar

struct CollapsedBar: View {
    
    var body: some View {
        Capsule()
            .fill(Color(.collapsedBackground))
            .frame(width: 40, height: 8)
            .overlay(
                Capsule()
                    .stroke(Color(.collapsedBorder), lineWidth: 1)
            )
    }
}

// MARK: - ExpandedBar

struct ExpandedBar: View {
    let isRecording: Bool
    let onStop: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        HStack {
            if isRecording {
                Button(action: onCancel) {
                    ZStack {
                        Circle()
                            .fill(Color(.cancelBackground))
                            .frame(width: 18, height: 18)
                        
                        Image(.close)
                        
                    }
                }
            }
            
            
            WaveView(isRecording: isRecording)
            
            if isRecording {
                Button(action: onStop) {
                    ZStack {
                        Circle()
                            .fill(Color(.pauseBackground))
                            .frame(width: 18, height: 18)
                        
                        Image(.stop)
                        
                    }
                }
            }
        }
        .padding(.horizontal, isRecording ? 6 : 12)
        .frame(height: 30)
        .background(
            Capsule()
                .fill(Color(.flowBarBackground))
        )
        .overlay(
            Capsule()
                .stroke(Color(.flowBarBorder), lineWidth: 1)
        )
    }
}

// MARK: - TooltipView

struct TooltipView: View {
    
    var body: some View {
        Text("Click to begin dictation")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(height: 30)
            .background(
                Capsule()
                    .fill(Color(.flowBarBackground))
            )
    }
}

// MARK: - WaveView

struct WaveView: View {
    let isRecording: Bool

    @State private var animate = false

    private let barCount = 10
    private let targetHeights: [CGFloat] = [10, 16, 18, 12, 18, 14, 18, 10, 16, 10]
    private let idleHeight: CGFloat = 2

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white)
                    .frame(width: 2, height: animate ? targetHeights[index] : idleHeight)
                    .animation(
                        animate
                            ? .easeInOut(duration: 0.4 + Double(index) * 0.04)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.06)
                            : .easeInOut(duration: 0.15),
                        value: animate
                    )
            }
        }
        .opacity(isRecording ? 1.0 : 0.4)
        .animation(.easeInOut(duration: 0.25), value: isRecording)
        .onChange(of: isRecording) { _, newValue in
            animate = newValue
        }
    }
}

#Preview {
    FlowBarView()
}
