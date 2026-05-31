import SwiftUI
import RevenueCatUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var dataService = MockDataService.shared
    @Environment(\.colorScheme) var colorScheme
    
    @State private var displayName = ""
    @State private var role = ""
    @State private var experienceYears = 1
    @State private var sector: Sector = .startup
    @State private var bio = ""
    @State private var lookingFor: LookingFor = .collaboration
    
    // Photo selection state
    @State private var selectedItem: PhotosPickerItem? = nil
    
    // RevenueCat sheets
    @State private var showPaywall = false
    @State private var showCustomerCenter = false
    
    // Tech Stack editing states
    @State private var newTechText = ""
    @State private var showSaveAlert = false
    
    // Dynamic Theme Helper colors for Light/Dark mode
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.1) : Color(red: 0.96, green: 0.96, blue: 0.98)
    }
    
    private var inputBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.04) : Color.white
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Avatar Header
                        avatarHeader
                        
                        // 2. Subscription Card (TechConnect PRO)
                        premiumSubscriptionCard
                        
                        // 3. Demo control button if pro
                        if dataService.currentUser.subscriptionTier == .pro {
                            demotePlanButton
                        }
                        
                        // 4. App Settings (Theme & Language) Card
                        settingsCard
                        
                        // 5. Form inputs card
                        profileInformationCard
                        
                        // 6. Tech tags card
                        techStackCard
                        
                        // 7. Save button
                        saveProfileButton
                    }
                }
            }
            .navigationTitle(Localization.string("profile", lang: dataService.appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .alert(Localization.string("success_title", lang: dataService.appLanguage), isPresented: $showSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(Localization.string("profile_saved_desc", lang: dataService.appLanguage))
            }
            .onAppear {
                // Initialize states with current user data
                let user = dataService.currentUser
                displayName = user.displayName
                role = user.role
                experienceYears = user.experienceYears
                sector = user.sector
                bio = user.bio
                lookingFor = user.lookingFor
            }
            .sheet(isPresented: $showPaywall) {
                CustomPaywallView()
            }
            .sheet(isPresented: $showCustomerCenter) {
                CustomerCenterView()
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        do {
                            try await dataService.uploadPhoto(image: data)
                        } catch {
                            print("Error uploading photo: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var avatarHeader: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    ProfileImageView(photoName: dataService.currentUser.photoNames.first, size: 100)
                        .overlay(
                            Circle()
                                .stroke(borderColor, lineWidth: 2)
                        )
                    
                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.purple)
                        .background(Circle().fill(Color.white))
                        .offset(x: 2, y: 2)
                }
            }
            
            VStack(spacing: 4) {
                Text(displayName.isEmpty ? "Developer" : displayName)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(dataService.currentUser.email)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 15)
    }
    
    @ViewBuilder
    private var premiumSubscriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 15) {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .padding(10)
                    .background(Color.yellow.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("DevMatch PRO")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(dataService.currentUser.subscriptionTier == .pro ? Localization.string("pro_desc_active", lang: dataService.appLanguage) : Localization.string("pro_desc_inactive", lang: dataService.appLanguage))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
                
                if dataService.currentUser.subscriptionTier == .pro {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                        Text(Localization.string("active", lang: dataService.appLanguage))
                    }
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.25))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                } else {
                    Button(action: {
                        showPaywall = true
                    }) {
                        Text(Localization.string("upgrade", lang: dataService.appLanguage))
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(color: .yellow.opacity(0.3), radius: 5)
                    }
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.1, blue: 0.28), Color(red: 0.26, green: 0.16, blue: 0.48)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.yellow.opacity(0.35), lineWidth: 1.5)
        )
        .shadow(color: .purple.opacity(0.2), radius: 10, y: 5)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var demotePlanButton: some View {
        Button(action: {
            showCustomerCenter = true
        }) {
            HStack {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                Text(dataService.appLanguage == .turkish ? "Aboneliği Yönet (Customer Center)" : "Manage Subscription")
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.yellow.opacity(0.9))
        }
        .padding(.top, -10)
    }
    
    @ViewBuilder
    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(dataService.appLanguage == .turkish ? "Uygulama Ayarları" : "App Settings")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // Theme Segmented Control
            VStack(alignment: .leading, spacing: 6) {
                Text(Localization.string("theme", lang: dataService.appLanguage))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("Tema", selection: $dataService.appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(dataService.appLanguage == .turkish ? theme.displayName : theme.displayNameEN).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Language Segmented Control
            VStack(alignment: .leading, spacing: 6) {
                Text(Localization.string("language", lang: dataService.appLanguage))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("Dil", selection: $dataService.appLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(20)
        .background(cardBackgroundColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var profileInformationCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(Localization.string("profile_info", lang: dataService.appLanguage))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // Display Name input
            VStack(alignment: .leading, spacing: 6) {
                Text(Localization.string("display_name", lang: dataService.appLanguage))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField(Localization.string("display_name", lang: dataService.appLanguage), text: $displayName)
                    .font(.system(size: 15))
                    .padding()
                    .background(inputBackgroundColor)
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )
            }
            
            // Role input
            VStack(alignment: .leading, spacing: 6) {
                Text(Localization.string("role", lang: dataService.appLanguage))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField(Localization.string("role", lang: dataService.appLanguage), text: $role)
                    .font(.system(size: 15))
                    .padding()
                    .background(inputBackgroundColor)
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )
            }
            
            // Sector & Experience Stepper
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(Localization.string("sector", lang: dataService.appLanguage))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Picker("Sektör", selection: $sector) {
                        ForEach(Sector.allCases, id: \.self) { sec in
                            Text(sec.rawValue).tag(sec)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(inputBackgroundColor)
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(Localization.string("experience", lang: dataService.appLanguage)) (\(experienceYears) \(Localization.string("stepper_label", lang: dataService.appLanguage)))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Stepper("", value: $experienceYears, in: 0...40)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(inputBackgroundColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderColor, lineWidth: 1)
                        )
                        .labelsHidden()
                }
            }
            
            // Looking For Picker
            VStack(alignment: .leading, spacing: 6) {
                Text(Localization.string("what_looking_for", lang: dataService.appLanguage))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("Looking For", selection: $lookingFor) {
                    ForEach(LookingFor.allCases, id: \.self) { item in
                        Text(item.displayName(lang: dataService.appLanguage)).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(inputBackgroundColor)
                .foregroundColor(.primary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                )
            }
            
            // Bio text editor
            VStack(alignment: .leading, spacing: 6) {
                Text(Localization.string("bio", lang: dataService.appLanguage))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                
                TextEditor(text: $bio)
                    .font(.system(size: 15))
                    .frame(height: 100)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(inputBackgroundColor)
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1)
                    )
            }
        }
        .padding(20)
        .background(cardBackgroundColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var techStackCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(Localization.string("tech_stack", lang: dataService.appLanguage))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // Input to add technology
            HStack {
                TextField(Localization.string("add_tech", lang: dataService.appLanguage), text: $newTechText)
                    .font(.system(size: 15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(inputBackgroundColor)
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderColor, lineWidth: 1)
                    )
                
                Button(action: {
                    let cleaned = newTechText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !cleaned.isEmpty && !dataService.currentUser.techStack.contains(cleaned) {
                        dataService.currentUser.techStack.append(cleaned)
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
            
            // Grid of technology tags
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                ForEach(dataService.currentUser.techStack, id: \.self) { tech in
                    HStack(spacing: 6) {
                        Text(tech)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Button(action: {
                            dataService.currentUser.techStack.removeAll(where: { $0 == tech })
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.purple.opacity(0.35), lineWidth: 1)
                    )
                }
            }
        }
        .padding(20)
        .background(cardBackgroundColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var saveProfileButton: some View {
        Button(action: {
            var updatedUser = dataService.currentUser
            updatedUser.displayName = displayName
            updatedUser.role = role
            updatedUser.experienceYears = experienceYears
            updatedUser.sector = sector
            updatedUser.bio = bio
            updatedUser.lookingFor = lookingFor
            
            Task {
                do {
                    try await dataService.saveProfile(profile: updatedUser)
                    await MainActor.run {
                        showSaveAlert = true
                    }
                } catch {
                    print("Failed to save profile: \(error)")
                }
            }
        }) {
            Text(Localization.string("save_profile", lang: dataService.appLanguage))
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
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}

#Preview {
    ProfileView()
}
