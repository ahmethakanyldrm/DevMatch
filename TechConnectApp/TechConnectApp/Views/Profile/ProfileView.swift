import SwiftUI

struct ProfileView: View {
    @StateObject private var dataService = MockDataService.shared
    @Environment(\.colorScheme) var colorScheme
    
    @State private var displayName = ""
    @State private var role = ""
    @State private var experienceYears = 1
    @State private var sector: Sector = .startup
    @State private var bio = ""
    @State private var lookingFor: LookingFor = .collaboration
    
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
                        
                        // 2. Subscription card
                        premiumSubscriptionCard
                        
                        // 3. Demo control button if pro
                        if dataService.currentUser.subscriptionTier == .pro {
                            demotePlanButton
                        }
                        
                        // 4. Form inputs card
                        profileInformationCard
                        
                        // 5. Tech tags card
                        techStackCard
                        
                        // 6. Save button
                        saveProfileButton
                    }
                }
            }
            .navigationTitle("Profilim")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Başarılı", isPresented: $showSaveAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text("Profil bilgileriniz başarıyla güncellendi.")
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
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var avatarHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: 2)
            )
            
            VStack(spacing: 4) {
                Text(displayName.isEmpty ? "Geliştirici" : displayName)
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
                    Text("TechConnect PRO")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(dataService.currentUser.subscriptionTier == .pro ? "Premium Üyeliğiniz Aktif!" : "Sınırsız eşleşme ve pro filtreler")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
                
                if dataService.currentUser.subscriptionTier == .pro {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Aktif")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.25))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                } else {
                    Button(action: {
                        withAnimation(.spring()) {
                            dataService.currentUser.subscriptionTier = .pro
                        }
                    }) {
                        Text("Yükselt")
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
            withAnimation {
                dataService.currentUser.subscriptionTier = .free
            }
        }) {
            Text("Aboneliği İptal Et (Demo)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.red.opacity(0.8))
        }
        .padding(.top, -15)
    }
    
    @ViewBuilder
    private var profileInformationCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Profil Bilgileri")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Görünen İsim")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField("İsim", text: $displayName)
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
            
            // Role
            VStack(alignment: .leading, spacing: 6) {
                Text("Rol / Ünvan")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField("Örn: Frontend Developer", text: $role)
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
            
            // Sector & Exp
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sektör")
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
                    Text("Deneyim (\(experienceYears) Yıl)")
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
            
            // Looking For
            VStack(alignment: .leading, spacing: 6) {
                Text("Ne Arıyorsun?")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Picker("Hedef", selection: $lookingFor) {
                    ForEach(LookingFor.allCases, id: \.self) { item in
                        Text(item.rawValue).tag(item)
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
            
            // Bio
            VStack(alignment: .leading, spacing: 6) {
                Text("Hakkımda (Maks 300 Karakter)")
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
            Text("Teknoloji Yığınım")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack {
                TextField("Teknoloji ekle (Örn: Golang)", text: $newTechText)
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
            dataService.currentUser.displayName = displayName
            dataService.currentUser.role = role
            dataService.currentUser.experienceYears = experienceYears
            dataService.currentUser.sector = sector
            dataService.currentUser.bio = bio
            dataService.currentUser.lookingFor = lookingFor
            
            showSaveAlert = true
        }) {
            Text("Profili Kaydet")
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
