import SwiftUI

struct ChatDetailView: View {
    var match: Match
    @StateObject private var dataService = MockDataService.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var messageText = ""
    @State private var showCoffeeChatSheet = false
    @State private var proposedTime = Date()
    @State private var activeRequests: [CoffeeChatRequest] = []
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.96, green: 0.96, blue: 0.98)
    }
    
    private var inputBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.08)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack {
                // Header details
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(match.profile.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(match.profile.role)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    // Coffee Chat Schedule button
                    Button(action: {
                        showCoffeeChatSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "cup.and.saucer.fill")
                            Text(Localization.string("coffee_chat_invite", lang: dataService.appLanguage))
                                .fontWeight(.semibold)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(colorScheme == .dark ? Color.white.opacity(0.03) : Color.black.opacity(0.02))
                
                // Messages Scroll List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Show active coffee chat requests if any
                            ForEach(activeRequests) { req in
                                CoffeeChatCard(request: req)
                                    .padding(.horizontal, 20)
                            }
                            
                            let messages = dataService.messagesByMatch[match.id] ?? []
                            ForEach(messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.senderId == dataService.currentUser.id
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.vertical, 15)
                    }
                    .onAppear {
                        let messages = dataService.messagesByMatch[match.id] ?? []
                        if let lastId = messages.last?.id {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                    .onChange(of: dataService.messagesByMatch[match.id]) { _ in
                        let messages = dataService.messagesByMatch[match.id] ?? []
                        if let lastId = messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Bottom input bar
                HStack(spacing: 12) {
                    TextField(Localization.string("chat_placeholder", lang: dataService.appLanguage), text: $messageText)
                        .font(.system(size: 15))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(inputBackgroundColor)
                        .foregroundColor(.primary)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(borderColor, lineWidth: 1)
                        )
                    
                    Button(action: {
                        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        dataService.sendMessage(matchId: match.id, content: messageText)
                        messageText = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.8))
            }
            
            // Propose Coffee Chat Sheet
            if showCoffeeChatSheet {
                CoffeeChatSetupSheet(
                    showSheet: $showCoffeeChatSheet,
                    proposedTime: $proposedTime,
                    onSubmit: {
                        dataService.requestCoffeeChat(matchId: match.id, proposedTime: proposedTime)
                        // Add mock pending request locally
                        let mockRequest = CoffeeChatRequest(
                            id: UUID(),
                            matchId: match.id,
                            requesterId: dataService.currentUser.id,
                            proposedTime: proposedTime,
                            status: .pending
                        )
                        activeRequests.append(mockRequest)
                        showCoffeeChatSheet = false
                    }
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Load existing requests for this match
            activeRequests = dataService.coffeeChatRequests.filter { $0.matchId == match.id }
        }
    }
}

// Message bubble view
struct MessageBubble: View {
    var message: Message
    var isCurrentUser: Bool
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var dataService = MockDataService.shared
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        isCurrentUser ?
                        AnyView(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        ) :
                        AnyView(
                            LinearGradient(
                                colors: colorScheme == .dark ? [Color.white.opacity(0.12), Color.white.opacity(0.08)] : [Color.black.opacity(0.06), Color.black.opacity(0.04)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isCurrentUser ? Color.clear : (colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05)), lineWidth: 1)
                    )
                
                Text(formatDate(message.sentAt))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal, 16)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// Coffee Chat Invite Status Card component
struct CoffeeChatCard: View {
    var request: CoffeeChatRequest
    @StateObject private var dataService = MockDataService.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .padding(10)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(Localization.string("coffee_chat_title", lang: dataService.appLanguage))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(formatProposedTime(request.proposedTime))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Status badge
                Text(request.status.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(colorScheme == .dark ? Color.white.opacity(0.06) : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.0 : 0.05), radius: 5, y: 2)
    }
    
    private func formatProposedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: dataService.appLanguage.rawValue)
        formatter.dateFormat = "d MMMM yyyy, EEEE HH:mm"
        return formatter.string(from: date)
    }
}

// Coffee Chat scheduling custom dialog sheet
struct CoffeeChatSetupSheet: View {
    @Binding var showSheet: Bool
    @Binding var proposedTime: Date
    var onSubmit: () -> Void
    
    @StateObject private var dataService = MockDataService.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    showSheet = false
                }
            
            VStack(spacing: 20) {
                Text(Localization.string("coffee_chat_plan", lang: dataService.appLanguage))
                    .font(.headline)
                    .foregroundColor(.white)
                
                DatePicker(Localization.string("date_and_time", lang: dataService.appLanguage), selection: $proposedTime, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.wheel)
                    .colorScheme(.dark)
                    .labelsHidden()
                
                HStack(spacing: 15) {
                    Button(action: {
                        showSheet = false
                    }) {
                        Text(Localization.string("cancel", lang: dataService.appLanguage))
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        onSubmit()
                    }) {
                        Text(Localization.string("send_invite", lang: dataService.appLanguage))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(24)
            .background(Color(red: 0.1, green: 0.1, blue: 0.15))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 30)
        }
    }
}
