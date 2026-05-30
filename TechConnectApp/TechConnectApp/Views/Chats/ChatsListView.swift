import SwiftUI

struct ChatsListView: View {
    @StateObject private var dataService = MockDataService.shared
    @Environment(\.colorScheme) var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.96, green: 0.96, blue: 0.98)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Text(Localization.string("connections", lang: dataService.appLanguage))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Horizontal Matches list (New Connections)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(Localization.string("new_matches", lang: dataService.appLanguage))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
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
                                                    .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.08), lineWidth: 1.5)
                                            )
                                            
                                            Text(match.profile.displayName.components(separatedBy: " ").first ?? "")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
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
                        .background(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08))
                        .padding(.vertical, 5)
                    
                    // Vertical Messages List
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if dataService.matches.isEmpty {
                                VStack(spacing: 15) {
                                    Spacer()
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    
                                    Text(Localization.string("no_messages", lang: dataService.appLanguage))
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(Localization.string("no_messages_desc", lang: dataService.appLanguage))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
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
                                        .background(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05))
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
    @StateObject private var dataService = MockDataService.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            // Profile photo
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
                    .frame(width: 58, height: 58)
                
                Image(systemName: match.profile.photoNames.first ?? "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
            }
            .overlay(
                Circle()
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1.5)
            )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(match.profile.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("14:32") // Mock message time
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                let displayLastMessage: String = {
                    let messages = dataService.messagesByMatch[match.id] ?? []
                    if messages.isEmpty {
                        return Localization.string("chat_start_helper", lang: dataService.appLanguage)
                    } else {
                        return messages.last?.content ?? match.lastMessage ?? ""
                    }
                }()
                
                Text(displayLastMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
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
