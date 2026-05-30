import SwiftUI

struct ProfileView: View {
    @StateObject private var dataService = MockDataService.shared
    @State private var displayName = ""
    @State private var role = ""
    @State private var experienceYears = 1
    @State private var sector: Sector = .startup
    @State private var bio = ""
    @State private var lookingFor: LookingFor = .collaboration
    @State private var city = ""
    @State private var isRemote = true
    
    // Tech Stack editing states
    @State private var newTechText = ""
    @State private var showSaveAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Header Avatar
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
                                    .frame(width: 110, height: 110)
                                
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 2)
                            )
                            
                            Text(dataService.currentUser.email)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 15)
                        
                        // Profile Information Section
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Profil Bilgileri")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.horizontal, 4)
                            
                            // Display Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Görünen İsim")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                TextField("İsim", text: $displayName)
                                    .padding()
                                    .background(Color.white.opacity(0.08))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            // Role
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Rol / Ünvan")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                TextField("Örn: Frontend Developer", text: $role)
                                    .padding()
                                    .background(Color.white.opacity(0.08))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            // Sector Picker & Experience Stepper
                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Sektör")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Picker("Sektör", selection: $sector) {
                                        ForEach(Sector.allCases, id: \.self) { sec in
                                            Text(sec.rawValue).tag(sec)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white.opacity(0.08))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Deneyim (\(experienceYears) Yıl)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Stepper("", value: $experienceYears, in: 0...40)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 12)
                                        .background(Color.white.opacity(0.08))
                                        .cornerRadius(12)
                                        .labelsHidden()
                                }
                            }
                            
                            // Looking For Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Ne Arıyorsun?")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Picker("Hedef", selection: $lookingFor) {
                                    ForEach(LookingFor.allCases, id: \.self) { item in
                                        Text(item.rawValue).tag(item)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.08))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            // Bio
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Hakkımda (Maks 300 Karakter)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                TextEditor(text: $bio)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color.white.opacity(0.08))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .colorMultiply(Color.white.opacity(0.95))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Tech Stack Section (Dynamic flow of tags)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Teknoloji Yığınım")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.gray.opacity(0.8))
                            
                            // Input to add technology
                            HStack {
                                TextField("Teknoloji ekle (Örn: Golang)", text: $newTechText)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.08))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                
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
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.purple.opacity(0.35))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.purple.opacity(0.6), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button(action: {
                            // Update current user
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
}

#Preview {
    ProfileView()
}
