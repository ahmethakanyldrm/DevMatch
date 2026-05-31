import SwiftUI

struct MatchOverlayView: View {
    var profile: DeveloperProfile
    var onDismiss: () -> Void
    
    @StateObject private var dataService = MockDataService.shared
    @State private var animateScale = false
    
    var body: some View {
        ZStack {
            // Dark transparent background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            // Confetti/Star glow behind
            Circle()
                .fill(Color.purple.opacity(0.4))
                .frame(width: 350, height: 350)
                .blur(radius: 60)
            
            VStack(spacing: 35) {
                // Match Header
                VStack(spacing: 8) {
                    Text(Localization.string("match_title", lang: dataService.appLanguage))
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .tracking(3)
                        .scaleEffect(animateScale ? 1.0 : 0.7)
                        .opacity(animateScale ? 1.0 : 0.0)
                    
                    Text(Localization.string("match_desc", lang: dataService.appLanguage))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Matching circles representation
                HStack(spacing: -30) {
                    // Current User Circle
                    ProfileImageView(photoName: dataService.currentUser.photoNames.first, size: 120)
                        .overlay(Circle().stroke(Color.purple, lineWidth: 3))
                    
                    // Connection Heart Link
                    ZStack {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 50, height: 50)
                            .shadow(color: .pink.opacity(0.5), radius: 8)
                        
                        Image(systemName: "bolt.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .zIndex(1)
                    
                    // Matched User Circle
                    ProfileImageView(photoName: profile.photoNames.first, size: 120)
                        .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                }
                .scaleEffect(animateScale ? 1.0 : 0.6)
                
                // Description
                VStack(spacing: 8) {
                    Text(profile.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(profile.role) at DevMatch")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Interactive Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        onDismiss()
                    }) {
                        Text(Localization.string("match_send_message", lang: dataService.appLanguage))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: .purple.opacity(0.4), radius: 10, y: 5)
                    }
                    
                    Button(action: {
                        onDismiss()
                    }) {
                        Text(Localization.string("match_continue", lang: dataService.appLanguage))
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateScale = true
            }
        }
    }
}

#Preview {
    MatchOverlayView(
        profile: DeveloperProfile(
            displayName: "Merve Yılmaz",
            email: "merve@startup.io",
            role: "Senior iOS Developer",
            experienceYears: 6,
            sector: .startup,
            bio: "",
            lookingFor: .mentor,
            city: "Ankara",
            isRemote: true,
            techStack: [],
            photoNames: ["person.fill"]
        ),
        onDismiss: {}
    )
}
