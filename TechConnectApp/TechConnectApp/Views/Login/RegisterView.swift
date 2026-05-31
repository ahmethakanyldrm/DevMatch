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
    @State private var gender: Gender = .male
    @State private var preferredGender: PreferredGender = .everyone
    
    // Tech Stack Input
    @State private var newTechText = ""
    
    // Status states
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.08, green: 0.09, blue: 0.12)
                .ignoresSafeArea()
            
            // Faint subtle background ambient light
            Circle()
                .fill(Color.purple.opacity(0.04))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: -80, y: -100)
            
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
                    
                    Text("\(Localization.string("signup_title", lang: dataService.appLanguage)) (\(step)/3)")
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
                                Text(step == 3 ? Localization.string("complete_register", lang: dataService.appLanguage) : Localization.string("continue_btn", lang: dataService.appLanguage))
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(14)
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
                Text(Localization.string("display_name", lang: dataService.appLanguage))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                TextField("", text: $displayName, prompt: Text(Localization.string("example_name", lang: dataService.appLanguage)).foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(Localization.string("email_address", lang: dataService.appLanguage))
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
                Text(Localization.string("password", lang: dataService.appLanguage))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                SecureField("", text: $password, prompt: Text("••••••••").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(Localization.string("github_username_verify", lang: dataService.appLanguage))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                TextField("", text: $githubUsername, prompt: Text(Localization.string("username_placeholder", lang: dataService.appLanguage)).foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
                
                Text(Localization.string("github_required_warning", lang: dataService.appLanguage))
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
                Text(Localization.string("role", lang: dataService.appLanguage))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                TextField("", text: $role, prompt: Text(Localization.string("example_role", lang: dataService.appLanguage)).foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
            }
            
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(Localization.string("sector", lang: dataService.appLanguage))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.purple)
                    
                    Picker("", selection: $sector) {
                        ForEach(Sector.allCases, id: \.self) { item in
                            Text(item.displayName(lang: dataService.appLanguage)).tag(item)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(Localization.string("experience", lang: dataService.appLanguage)) (\(experienceYears) \(Localization.string("stepper_label", lang: dataService.appLanguage)))")
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
                Text(Localization.string("city", lang: dataService.appLanguage))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                TextField("", text: $city, prompt: Text("İstanbul").foregroundColor(.white.opacity(0.35)))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(Localization.string("gender", lang: dataService.appLanguage))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                
                Picker("", selection: $gender) {
                    ForEach(Gender.allCases, id: \.self) { item in
                        Text(item.displayName(lang: dataService.appLanguage)).tag(item)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Toggle(isOn: $isRemote) {
                Text(Localization.string("work_remotely", lang: dataService.appLanguage))
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
                Text(Localization.string("tech_stack", lang: dataService.appLanguage))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                
                HStack {
                    TextField("", text: $newTechText, prompt: Text(Localization.string("add_tech_placeholder", lang: dataService.appLanguage)).foregroundColor(.white.opacity(0.35)))
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
                Text(Localization.string("matching_goal", lang: dataService.appLanguage))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.purple)
                
                Picker("", selection: $lookingFor) {
                    ForEach(LookingFor.allCases, id: \.self) { item in
                        Text(item.displayName(lang: dataService.appLanguage)).tag(item)
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
                errorMessage = Localization.string("fill_all_info_error", lang: dataService.appLanguage)
                return
            }
            withAnimation { step = 2 }
        } else if step == 2 {
            if role.isEmpty || city.isEmpty {
                errorMessage = Localization.string("fill_role_city_error", lang: dataService.appLanguage)
                return
            }
            withAnimation { step = 3 }
        } else if step == 3 {
            if techStack.isEmpty {
                errorMessage = Localization.string("add_at_least_one_tech_error", lang: dataService.appLanguage)
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
                photoNames: ["person.fill"], // default
                gender: gender,
                preferredGender: preferredGender
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
