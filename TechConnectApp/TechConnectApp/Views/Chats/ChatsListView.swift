import SwiftUI

struct ChatsListView: View {
    @StateObject private var dataService = MockDataService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Text("Bağlantılarım")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Horizontal Matches list (New Connections)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Yeni Eşleşmeler")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray.opacity(0.8))
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(dataService.matches) { match in
                                    NavigationLink(value: match) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [.purple, .blue],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .frame(width: 70, height: 70)
                                                
                                                Image(systemName: match.profile.photoNames.first ?? "person.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 36, height: 36)
                                                    .foregroundColor(.white)
                                            }
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1.5)
                                            )
                                            
                                            Text(match.profile.displayName.components(separatedBy: " ").first ?? "")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .frame(width: 80)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.vertical, 5)
                    
                    // Vertical Messages List
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if dataService.matches.isEmpty {
                                VStack(spacing: 15) {
                                    Spacer()
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("Henüz Mesaj Yok")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Keşfet ekranından beğendiğin geliştiricilerle eşleşerek sohbeti başlatabilirsin.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                    Spacer()
                                }
                                .padding(.top, 50)
                            } else {
                                ForEach(dataService.matches) { match in
                                    NavigationLink(value: match) {
                                        ChatRowView(match: match)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Divider()
                                        .background(Color.white.opacity(0.08))
                                        .padding(.leading, 85)
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Match.self) { match in
                ChatDetailView(match: match)
            }
        }
    }
}

// Chat Row View component
struct ChatRowView: View {
    var match: Match
    
    var body: some View {
        HStack(spacing: 15) {
            // Profile photo
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 58, height: 58)
                
                Image(systemName: match.profile.photoNames.first ?? "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1.5)
            )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(match.profile.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("14:32") // Mock message time
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Text(match.lastMessage ?? "Henüz mesaj gönderilmedi.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    ChatsListView()
}
