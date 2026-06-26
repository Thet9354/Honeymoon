//
//  OnboardingView.swift
//  Honeymoon
//

import SwiftUI

struct OnboardingView: View {

    var onComplete: () -> Void

    @State private var selectedPage: Int = 0
    @State private var showQuiz: Bool = false

    private struct Page: Identifiable {
        let id: Int
        let systemImage: String
        let title: String
        let subtitle: String
    }

    private let pages: [Page] = [
        Page(
            id: 0,
            systemImage: "heart.circle.fill",
            title: "Welcome to Honeymoon",
            subtitle: "Hand-picked destinations to help you plan the trip of a lifetime, together."
        ),
        Page(
            id: 1,
            systemImage: "hand.draw.fill",
            title: "Swipe to discover",
            subtitle: "Swipe right to love a destination, left to dismiss it. Just like that."
        ),
        Page(
            id: 2,
            systemImage: "bookmark.circle.fill",
            title: "Save your favorites",
            subtitle: "Every place you love is saved to your account so you can revisit them anytime."
        ),
        Page(
            id: 3,
            systemImage: "airplane.circle.fill",
            title: "Ready to begin?",
            subtitle: "Let's find the perfect place for the two of you."
        )
    ]

    var body: some View {
        Group {
            if showQuiz {
                NavigationStack {
                    PreferenceQuizView(mode: .onboarding, onFinish: onComplete)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                infoPages
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showQuiz)
    }

    private var infoPages: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedPage) {
                ForEach(pages) { page in
                    OnboardingPage(
                        systemImage: page.systemImage,
                        title: page.title,
                        subtitle: page.subtitle
                    )
                    .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            actionButton
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private var actionButton: some View {
        let isLastPage = selectedPage == pages.count - 1
        Button {
            if isLastPage {
                showQuiz = true
            } else {
                withAnimation {
                    selectedPage += 1
                }
            }
        } label: {
            Text(isLastPage ? "Personalize" : "Continue")
                .modifier(ButtonModifier())
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
        .environmentObject(PreferenceStore())
}
