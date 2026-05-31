import SwiftUI

struct LoginView: View {
    @StateObject private var dataService = MockDataService.shared
    @State private var startAnimation = false
    @State private var showPanel = false
    @Binding var isLoggedIn: Bool
    
    // Email / Password Form states
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showRegisterSheet = false
    
    // Keyboard Focus state for responsiveness
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Clean professional dark background
            Color(red: 0.08, green: 0.09, blue: 0.12)
                .ignoresSafeArea()
            
            // Faint subtle background ambient light
            glowingAmbientShapes
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: isFieldFocused ? 15 : 30) {
                    Spacer().frame(height: isFieldFocused ? 10 : 40)
                    
                    // Brand Section
                    brandSection
                    
                    // Login Panel
                    if showPanel {
                        loginPanelCard
                    }
                    
                    // Terms and Conditions
                    if !isFieldFocused {
                        termsAndConditionsSection
                            .transition(.opacity)
                    }
                }
            }
            .onTapGesture {
                isFieldFocused = false
            }
        }
        .sheet(isPresented: $showRegisterSheet) {
            RegisterView(isLoggedIn: $isLoggedIn)
        }
    }
    
    // MARK: - Subviews
    
    private var glowingAmbientShapes: some View {
        Circle()
            .fill(Color.purple.opacity(0.04))
            .frame(width: 300, height: 300)
            .blur(radius: 100)
            .offset(x: -60, y: -100)
    }
    
    private var brandSection: some View {
        VStack(spacing: isFieldFocused ? 4 : 15) {
            if !isFieldFocused {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 80, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    Image(systemName: "heart.text.square.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                        .foregroundColor(.indigo)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            Text("DevMatch")
                .font(.system(size: isFieldFocused ? 26 : 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if !isFieldFocused {
                Text("Connect. Code. Collaborate.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .animation(.spring(), value: isFieldFocused)
    }
    
    private var emailField: some View {
        HStack {
            Image(systemName: "envelope.fill")
                .foregroundColor(.purple)
                .frame(width: 30)
            TextField("", text: $email, prompt: Text(Localization.string("email_address", lang: dataService.appLanguage)).foregroundColor(.white.opacity(0.4)))
                .foregroundColor(.white)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .focused($isFieldFocused)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
    
    private var passwordField: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundColor(.purple)
                .frame(width: 30)
            SecureField("", text: $password, prompt: Text(Localization.string("password", lang: dataService.appLanguage)).foregroundColor(.white.opacity(0.4)))
                .foregroundColor(.white)
                .focused($isFieldFocused)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var errorMessageView: some View {
        if !errorMessage.isEmpty {
            Text(errorMessage)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
                .transition(.opacity)
        }
    }
    
    private var loginButton: some View {
        Button(action: handleLogin) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(Localization.string("login_title", lang: dataService.appLanguage))
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.indigo)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
    
    private var signUpLink: some View {
        HStack(spacing: 5) {
            Text(Localization.string("dont_have_account", lang: dataService.appLanguage))
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            
            Button(action: {
                showRegisterSheet = true
            }) {
                Text(Localization.string("signup_title", lang: dataService.appLanguage))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.purple)
            }
        }
        .padding(.top, 10)
    }
    
    private var loginPanelCard: some View {
        VStack(spacing: isFieldFocused ? 10 : 16) {
            Text(Localization.string("login_with_email", lang: dataService.appLanguage))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            emailField
            passwordField
            errorMessageView
            loginButton
            signUpLink
            
            HStack {
                Color.white.opacity(0.12)
                    .frame(height: 1)
                Text(Localization.string("or_text", lang: dataService.appLanguage))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                Color.white.opacity(0.12)
                    .frame(height: 1)
            }
            .padding(.vertical, 2)
            
            // Social Login Button (GitHub Only)
            Button(action: handleGithubLogin) {
                HStack(spacing: 10) {
                    Image("github_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text(Localization.string("login_github", lang: dataService.appLanguage))
                        .font(.system(size: 15, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(red: 0.15, green: 0.15, blue: 0.18))
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
            }
        }
        .padding(isFieldFocused ? 16 : 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .background(VisualEffectBlur(material: .systemUltraThinMaterialDark))
                .clipShape(RoundedRectangle(cornerRadius: 24))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .clear, .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .padding(.horizontal, 24)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var termsAndConditionsSection: some View {
        Text(Localization.string("login_terms", lang: dataService.appLanguage))
            .font(.caption2)
            .foregroundColor(.white.opacity(0.4))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
    }
    
    private func handleLogin() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = Localization.string("fill_all_fields_error", lang: dataService.appLanguage)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let response = try await APIService.shared.login(email: email, password: password)
                await dataService.fetchAllData()
                await MainActor.run {
                    SubscriptionManager.shared.identifyUser(userId: response.profile.id)
                    isLoading = false
                    withAnimation {
                        isLoggedIn = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleGithubLogin() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let response = try await APIService.shared.login(email: "ahmet@devmatch.com", password: "")
                await dataService.fetchAllData()
                await MainActor.run {
                    SubscriptionManager.shared.identifyUser(userId: response.profile.id)
                    isLoading = false
                    withAnimation {
                        isLoggedIn = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
