import SwiftUI

struct IncomingLikesView: View {
    @StateObject private var dataService = MockDataService.shared
    @Environment(\.colorScheme) var colorScheme
    
    @State private var incomingLikes: [DeveloperProfile] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showMatchOverlay = false
    @State private var matchedProfile: DeveloperProfile? = nil
    
    private var isPro: Bool {
        dataService.currentUser.subscriptionTier == .pro
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.96, green: 0.96, blue: 0.98)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            // Subtle ambient light
            Circle()
                .fill(Color.purple.opacity(colorScheme == .dark ? 0.04 : 0.02))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -80, y: -50)
            
            VStack(spacing: 0) {
                // Header Title
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Localization.string("likes", lang: dataService.appLanguage))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(Localization.string("likes_desc", lang: dataService.appLanguage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 15)
                .padding(.bottom, 20)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        .scaleEffect(1.2)
                    Spacer()
                } else if !errorMessage.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.amber)
                        Text(errorMessage)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Button(action: fetchLikes) {
                            Text(Localization.string("refresh_deck", lang: dataService.appLanguage))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                } else if incomingLikes.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.purple.opacity(0.4))
                        Text(Localization.string("likes_empty", lang: dataService.appLanguage))
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(Localization.string("likes_empty_desc", lang: dataService.appLanguage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        if !isPro {
                            nonProBanner
                                .padding(.horizontal, 24)
                                .padding(.bottom, 16)
                        }
                        
                        // Likes Grid
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                            ForEach(incomingLikes) { profile in
                                likeCard(profile: profile)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .refreshable {
                        await fetchLikesAsync()
                    }
                }
            }
            
            // Match Overlay
            if showMatchOverlay, let matched = matchedProfile {
                MatchOverlayView(profile: matched) {
                    showMatchOverlay = false
                }
            }
        }
        .onAppear {
            fetchLikes()
        }
    }
    
    // MARK: - Subviews
    
    private var nonProBanner: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 20))
                Text("DEVMATCH PRO")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(Localization.string("likes_blur_message", lang: dataService.appLanguage))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
            
            Button(action: {
                dataService.showLikeLimitPaywall = true
            }) {
                Text(Localization.string("upgrade", lang: dataService.appLanguage))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.purple, .indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .purple.opacity(0.35), radius: 10, y: 5)
    }
    
    private func likeCard(profile: DeveloperProfile) -> some View {
        VStack(spacing: 0) {
            // Photo & Blur Container
            ZStack {
                if isPro {
                    ProfileImageView(photoName: profile.photoNames.first, size: 120)
                        .padding(.top, 16)
                } else {
                    // Blurred representation for free tier
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple.opacity(0.6), .blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .blur(radius: 8)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5)
                    }
                    .frame(width: 120, height: 120)
                }
            }
            .frame(height: 130)
            
            // Profile details
            VStack(spacing: 4) {
                Text(profile.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(profile.role)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if isPro {
                    Text(profile.city)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 12)
            
            // Actions (Only for PRO users)
            if isPro {
                Divider()
                HStack(spacing: 0) {
                    // Pass (Decline) Button
                    Button(action: {
                        handleSwipe(profile: profile, isLike: false)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 44)
                    
                    Divider()
                    
                    // Approve (Accept/Like) Button
                    Button(action: {
                        handleSwipe(profile: profile, isLike: true)
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 44)
                }
            } else {
                Divider()
                // Blurred premium badge lock
                Button(action: {
                    dataService.showLikeLimitPaywall = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 11))
                        Text(Localization.string("upgrade", lang: dataService.appLanguage))
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                }
            }
        }
        .background(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 8, y: 4)
    }
    
    // MARK: - Actions Logic
    
    private func fetchLikes() {
        isLoading = true
        errorMessage = ""
        
        Task {
            await fetchLikesAsync()
        }
    }
    
    private func fetchLikesAsync() async {
        do {
            let likes = try await APIService.shared.getIncomingLikes()
            await MainActor.run {
                self.incomingLikes = likes
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = Localization.localizedError(error, lang: dataService.appLanguage)
                self.isLoading = false
            }
        }
    }
    
    private func handleSwipe(profile: DeveloperProfile, isLike: Bool) {
        // Optimistic UI update
        withAnimation {
            incomingLikes.removeAll(where: { $0.id == profile.id })
        }
        
        Task {
            let matched = await dataService.swipe(profile: profile, isLike: isLike)
            if matched && isLike {
                await MainActor.run {
                    matchedProfile = profile
                    withAnimation(.spring()) {
                        showMatchOverlay = true
                    }
                }
            }
        }
    }
}
