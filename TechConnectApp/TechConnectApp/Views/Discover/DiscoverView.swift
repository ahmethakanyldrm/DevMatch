import SwiftUI

struct DiscoverView: View {
    @StateObject private var dataService = MockDataService.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var activeProfiles: [DeveloperProfile] = []
    @State private var swipeStates: [UUID: CGFloat] = [:] // Keeps track of translation X for each card
    @State private var showMatchOverlay = false
    @State private var matchedProfile: DeveloperProfile? = nil
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.96, green: 0.96, blue: 0.98)
    }
    
    var body: some View {
        ZStack {
            // Dynamic theme background color
            backgroundColor
                .ignoresSafeArea()
            
            VStack {
                // Custom Header
                HStack {
                    Text(Localization.string("discover", lang: dataService.appLanguage))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        // Reset deck for mock demonstration
                        activeProfiles = dataService.profiles.shuffled()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.purple)
                            .padding(10)
                            .background(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Cards Stack Area
                ZStack {
                    if activeProfiles.isEmpty {
                        // Empty State (No more cards)
                        VStack(spacing: 15) {
                            Image(systemName: "person.3.sequence.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            Text(Localization.string("empty_deck", lang: dataService.appLanguage))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(Localization.string("empty_deck_desc", lang: dataService.appLanguage))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Button(action: {
                                activeProfiles = dataService.profiles
                            }) {
                                Text(Localization.string("refresh_deck", lang: dataService.appLanguage))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [.purple, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                            .padding(.top, 10)
                        }
                        .padding()
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Loop through profiles and render them stacked
                        ForEach(activeProfiles) { profile in
                            let index = activeProfiles.firstIndex(where: { $0.id == profile.id }) ?? 0
                            
                            // Only render top 3 cards for performance
                            if index >= activeProfiles.count - 3 {
                                DeveloperCardView(
                                    profile: profile,
                                    score: dataService.calculateCompatibilityScore(target: profile),
                                    translation: swipeStates[profile.id] ?? 0,
                                    onSwipeLeft: {
                                        swipeCard(profile: profile, right: false)
                                    },
                                    onSwipeRight: {
                                        swipeCard(profile: profile, right: true)
                                    }
                                )
                                .zIndex(Double(index))
                                .offset(y: CGFloat((activeProfiles.count - 1 - index) * -10))
                                .scaleEffect(1 - CGFloat(activeProfiles.count - 1 - index) * 0.03)
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            withAnimation(.interactiveSpring()) {
                                                swipeStates[profile.id] = gesture.translation.width
                                            }
                                        }
                                        .onEnded { gesture in
                                            let threshold: CGFloat = 130
                                            if gesture.translation.width > threshold {
                                                swipeCard(profile: profile, right: true)
                                            } else if gesture.translation.width < -threshold {
                                                swipeCard(profile: profile, right: false)
                                            } else {
                                                withAnimation(.spring()) {
                                                    swipeStates[profile.id] = 0
                                                }
                                            }
                                        }
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .move(edge: (swipeStates[profile.id] ?? 0) > 0 ? .trailing : .leading).combined(with: .opacity)
                                ))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                
                // Bottom control actions
                if !activeProfiles.isEmpty {
                    HStack(spacing: 35) {
                        // Pass Button
                        Button(action: {
                            if let topProfile = activeProfiles.last {
                                swipeCard(profile: topProfile, right: false)
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.red)
                                .frame(width: 64, height: 64)
                                .background(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.red.opacity(0.2), lineWidth: 1.5)
                                )
                        }
                        
                        // Like Button
                        Button(action: {
                            if let topProfile = activeProfiles.last {
                                swipeCard(profile: topProfile, right: true)
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.green)
                                .frame(width: 64, height: 64)
                                .background(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.green.opacity(0.2), lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            
            // Match popup overlay
            if showMatchOverlay, let matched = matchedProfile {
                MatchOverlayView(profile: matched) {
                    showMatchOverlay = false
                }
            }
        }
        .onAppear {
            if activeProfiles.isEmpty {
                activeProfiles = dataService.profiles.shuffled()
            }
        }
    }
    
    private func swipeCard(profile: DeveloperProfile, right: Bool) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            swipeStates[profile.id] = right ? 500 : -500
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Remove the profile from deck
            activeProfiles.removeAll(where: { $0.id == profile.id })
            swipeStates.removeValue(forKey: profile.id)
            
            // Mock matching logic
            if right && Double.random(in: 0...1) > 0.4 {
                matchedProfile = profile
                withAnimation(.spring()) {
                    showMatchOverlay = true
                }
                
                // Add to matches in service
                let newMatch = Match(id: UUID(), profile: profile, matchedAt: Date(), lastMessage: Localization.string("chat_start_helper", lang: dataService.appLanguage))
                dataService.matches.insert(newMatch, at: 0)
                dataService.messagesByMatch[newMatch.id] = []
            }
        }
    }
}

// Developer Card Component
struct DeveloperCardView: View {
    var profile: DeveloperProfile
    var score: Int
    var translation: CGFloat
    var onSwipeLeft: () -> Void
    var onSwipeRight: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var dataService = MockDataService.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Card Photo container
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: colorScheme == .dark ? [
                                Color(red: 0.12, green: 0.12, blue: 0.22),
                                Color(red: 0.08, green: 0.08, blue: 0.15)
                            ] : [
                                Color(red: 0.9, green: 0.9, blue: 0.95),
                                Color(red: 0.85, green: 0.85, blue: 0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Avatar symbol in card background
                VStack {
                    Spacer()
                    Image(systemName: profile.photoNames.first ?? "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 140)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.12) : .black.opacity(0.08))
                    Spacer()
                }
                
                // Match Score Badge at the top-right
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 13))
                            Text("%\(min(score * 8, 100)) \(Localization.string("compatibility", lang: dataService.appLanguage))")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 3)
                    }
                    Spacer()
                }
                .padding(16)
                
                // Custom Like / Nope indicators while dragging
                if translation != 0 {
                    VStack {
                        HStack {
                            if translation > 0 {
                                Text(Localization.string("like", lang: dataService.appLanguage))
                                    .font(.title)
                                    .fontWeight(.black)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.green, lineWidth: 4)
                                    )
                                    .rotationEffect(.degrees(-15))
                                Spacer()
                            } else {
                                Spacer()
                                Text(Localization.string("pass", lang: dataService.appLanguage))
                                    .font(.title)
                                    .fontWeight(.black)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.red, lineWidth: 4)
                                    )
                                    .rotationEffect(.degrees(15))
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 50)
                        Spacer()
                    }
                }
                
                // User details panel
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.displayName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(profile.role) • \(profile.experienceYears) \(Localization.string("stepper_label", lang: dataService.appLanguage))")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray.opacity(0.9))
                        }
                        Spacer()
                        
                        // Sector Badge
                        Text(profile.sector.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.15))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Text(profile.bio)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(3)
                    
                    // Tech stack tag layout
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                            .font(.system(size: 14))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(profile.techStack, id: \.self) { tech in
                                    Text(tech)
                                        .font(.system(size: 12, weight: .semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.purple.opacity(0.25))
                                        .foregroundColor(.purple.opacity(0.95))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    .padding(.top, 4)
                    
                    // Target relationship badge
                    HStack(spacing: 4) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 12))
                        Text("\(Localization.string("target", lang: dataService.appLanguage)): \(profile.lookingFor.rawValue)")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.75))
                }
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.85), .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(24)
            }
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.08), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.35 : 0.15), radius: 15, x: 0, y: 10)
            .rotationEffect(.degrees(Double(translation / 15)))
            .offset(x: translation, y: 0)
        }
    }
}

#Preview {
    DiscoverView()
}
