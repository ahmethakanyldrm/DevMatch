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
        let startPoint: UnitPoint = startAnimation ? .topLeading : .bottomTrailing
        let endPoint: UnitPoint = startAnimation ? .bottomTrailing : .topLeading
        
        return ZStack {
            // Dark futuristic gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.02, green: 0.02, blue: 0.05)
                ],
                startPoint: startPoint,
                endPoint: endPoint
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                    startAnimation.toggle()
                }
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    showPanel = true
                }
            }
            
            // Glowing ambient shapes
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
        Group {
            Circle()
                .fill(Color.purple.opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: startAnimation ? -100 : 100, y: startAnimation ? -200 : 200)
            
            Circle()
                .fill(Color.blue.opacity(0.25))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .offset(x: startAnimation ? 120 : -120, y: startAnimation ? 180 : -180)
        }
    }
    
    private var brandSection: some View {
        VStack(spacing: isFieldFocused ? 4 : 15) {
            if !isFieldFocused {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.07))
                        .frame(width: 90, height: 90)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    
                    Image(systemName: "heart.text.square.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            Text("DevMatch")
                .font(.system(size: isFieldFocused ? 26 : 38, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
            
            if !isFieldFocused {
                Text("Connect. Code. Collaborate.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray.opacity(0.8))
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
            TextField("", text: $email, prompt: Text(dataService.appLanguage == .turkish ? "E-posta Adresi" : "Email Address").foregroundColor(.white.opacity(0.4)))
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
            SecureField("", text: $password, prompt: Text(dataService.appLanguage == .turkish ? "Şifre" : "Password").foregroundColor(.white.opacity(0.4)))
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
                    Text(dataService.appLanguage == .turkish ? "Giriş Yap" : "Log In")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
    }
    
    private var signUpLink: some View {
        HStack(spacing: 5) {
            Text(dataService.appLanguage == .turkish ? "Hesabınız yok mu?" : "Don't have an account?")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            
            Button(action: {
                showRegisterSheet = true
            }) {
                Text(dataService.appLanguage == .turkish ? "Kayıt Ol" : "Sign Up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.purple)
            }
        }
        .padding(.top, 10)
    }
    
    private var loginPanelCard: some View {
        VStack(spacing: isFieldFocused ? 10 : 16) {
            Text(dataService.appLanguage == .turkish ? "E-posta ile Giriş Yap" : "Login with Email")
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
                Text(dataService.appLanguage == .turkish ? "veya" : "or")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                Color.white.opacity(0.12)
                    .frame(height: 1)
            }
            .padding(.vertical, 2)
            
            // Social Login Buttons Stack (Horizontal)
            HStack(spacing: 12) {
                // GitHub Login Button
                Button(action: handleGithubLogin) {
                    HStack {
                        Image(systemName: "terminal.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("GitHub")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.13))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                
                // Apple Login Button
                Button(action: handleAppleLogin) {
                    HStack {
                        Image(systemName: "applelogo")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Apple")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                }
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
            errorMessage = dataService.appLanguage == .turkish ? "Lütfen tüm alanları doldurun." : "Please fill in all fields."
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
    
    private func handleAppleLogin() {
        performSocialLogin(provider: "Apple")
    }
    
    private func handleGithubLogin() {
        performSocialLogin(provider: "GitHub")
    }
    
    private func performSocialLogin(provider: String) {
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
