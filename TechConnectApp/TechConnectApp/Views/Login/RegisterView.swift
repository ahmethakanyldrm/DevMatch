import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataService = MockDataService.shared
    @Binding var isLoggedIn: Bool
    
    // Page steps
    @State private var step = 1
    
    // Fields
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var githubUsername = ""
    @State private var role = "Yazılım Geliştirici"
    @State private var experienceYears = 1
    @State private var sector: Sector = .startup
    @State private var lookingFor: LookingFor = .collaboration
    @State private var city = "İstanbul"
    @State private var isRemote = true
    @State private var techStack: [String] = []
    
    // Tech Stack Input
    @State private var newTechText = ""
    
    // Status states
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.02, green: 0.02, blue: 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glowing shapes
            Circle()
                .fill(Color.purple.opacity(0.25))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -120, y: -150)
            
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .offset(x: 120, y: 150)
            
            VStack {
                // Header
                HStack {
                    Button(action: {
                        if step > 1 {
                            withAnimation { step -= 1 }
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(dataService.appLanguage == .turkish ? "Kayıt Ol (\(step)/3)" : "Sign Up (\(step)/3)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty spacer to balance header layout
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                // Form Container
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if step == 1 {
                            stepOneCredentials
                        } else if step == 2 {
                            stepTwoProfessional
                        } else {
                            stepThreeTechAndSubmit
                        }
                    }
                    .padding(20)
                }
                
                // Bottom Button
                VStack(spacing: 12) {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                    }
                    
                    Button(action: handleNextStep) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(step == 3 ? (dataService.appLanguage == .turkish ? "Kaydı Tamamla" : "Complete Register") : (dataService.appLanguage == .turkish ? "İlerle" : "Continue"))
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Step 1 View: Basic Credentials and GitHub User
    private var stepOneCredentials: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(dataService.appLanguage == .turkish ? "Görünen İsim" : "Display Name")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                TextField("", text: $displayName, prompt: Text(dataService.appLanguage == .turkish ? "Örn: Ahmet" : "e.g. Ahmet").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dataService.appLanguage == .turkish ? "E-posta Adresi" : "Email Address")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                TextField("", text: $email, prompt: Text("example@tech.com").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dataService.appLanguage == .turkish ? "Şifre" : "Password")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                SecureField("", text: $password, prompt: Text("••••••••").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dataService.appLanguage == .turkish ? "GitHub Kullanıcı Adı (IT Doğrulaması)" : "GitHub Username (IT Verification)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                TextField("", text: $githubUsername, prompt: Text(dataService.appLanguage == .turkish ? "Kullanıcı adınız" : "Your username").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
                
                Text(dataService.appLanguage == .turkish ? "⚠️ Platformumuz yalnızca bilişim ve teknoloji çalışanlarına açık olduğu için geçerli bir GitHub hesabı gerekmektedir." : "⚠️ Since our platform is only open to tech and IT professionals, a valid GitHub account is required.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1.5))
    }
    
    // Step 2 View: Professional details
    private var stepTwoProfessional: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(dataService.appLanguage == .turkish ? "Rol / Ünvan" : "Role / Title")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                TextField("", text: $role, prompt: Text(dataService.appLanguage == .turkish ? "Örn: iOS Geliştirici" : "e.g. iOS Developer").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
            }
            
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(dataService.appLanguage == .turkish ? "Sektör" : "Sector")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.purple)
                    
                    Picker("", selection: $sector) {
                        ForEach(Sector.allCases, id: \.self) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(dataService.appLanguage == .turkish ? "Deneyim" : "Experience") (\(experienceYears) \(dataService.appLanguage == .turkish ? "Yıl" : "Years"))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.purple)
                    
                    Stepper("", value: $experienceYears, in: 0...45)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(12)
                        .labelsHidden()
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dataService.appLanguage == .turkish ? "Şehir" : "City")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                TextField("", text: $city, prompt: Text("İstanbul").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
            }
            
            Toggle(isOn: $isRemote) {
                Text(dataService.appLanguage == .turkish ? "Uzaktan Çalışıyorum (Remote)" : "I work Remotely")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .tint(.purple)
            .padding(.vertical, 6)
        }
        .padding(20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1.5))
    }
    
    // Step 3 View: Tech Stack & Submit
    private var stepThreeTechAndSubmit: some View {
        VStack(spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text(dataService.appLanguage == .turkish ? "Teknoloji Yığınım" : "My Tech Stack")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                
                HStack {
                    TextField("", text: $newTechText, prompt: Text(dataService.appLanguage == .turkish ? "Teknoloji ekle (Golang vb)" : "Add technology (e.g. Swift)").foregroundColor(.white.opacity(0.35)))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(10)
                    
                    Button(action: {
                        let cleaned = newTechText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !cleaned.isEmpty && !techStack.contains(cleaned) {
                            techStack.append(cleaned)
                            newTechText = ""
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                }
                
                // Tags wrapping
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                    ForEach(techStack, id: \.self) { tech in
                        HStack(spacing: 6) {
                            Text(tech)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                techStack.removeAll(where: { $0 == tech })
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.purple.opacity(0.35))
                        .cornerRadius(8)
                    }
                }
                .padding(.top, 5)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dataService.appLanguage == .turkish ? "Eşleşme Hedefiniz" : "Matching Goal")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                
                Picker("", selection: $lookingFor) {
                    ForEach(LookingFor.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1.5))
    }
    
    private func handleNextStep() {
        errorMessage = ""
        
        if step == 1 {
            if displayName.isEmpty || email.isEmpty || password.isEmpty || githubUsername.isEmpty {
                errorMessage = dataService.appLanguage == .turkish ? "Lütfen tüm bilgileri doldurun." : "Please fill in all information."
                return
            }
            withAnimation { step = 2 }
        } else if step == 2 {
            if role.isEmpty || city.isEmpty {
                errorMessage = dataService.appLanguage == .turkish ? "Lütfen rol ve şehir alanlarını doldurun." : "Please fill in role and city fields."
                return
            }
            withAnimation { step = 3 }
        } else if step == 3 {
            if techStack.isEmpty {
                errorMessage = dataService.appLanguage == .turkish ? "Lütfen en az bir teknoloji ekleyin." : "Please add at least one technology."
                return
            }
            
            // Execute signup API
            isLoading = true
            let req = RegisterRequestSwift(
                email: email,
                password: password,
                displayName: displayName,
                githubUsername: githubUsername,
                role: role,
                experienceYears: experienceYears,
                sector: sector,
                lookingFor: lookingFor,
                city: city,
                isRemote: isRemote,
                techStack: techStack,
                photoNames: ["person.fill"] // default
            )
            
            Task {
                do {
                    let response = try await APIService.shared.register(req: req)
                    await dataService.fetchAllData()
                    await MainActor.run {
                        SubscriptionManager.shared.identifyUser(userId: response.profile.id)
                        isLoading = false
                        withAnimation {
                            isLoggedIn = true
                            dismiss()
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
}
