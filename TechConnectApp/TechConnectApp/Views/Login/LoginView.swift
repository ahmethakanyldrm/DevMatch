import SwiftUI

struct LoginView: View {
    @State private var startAnimation = false
    @State private var showPanel = false
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        ZStack {
            // Dark futuristic gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.02, green: 0.02, blue: 0.05)
                ],
                startPoint: startAnimation ? .topLeading : .bottomTrailing,
                endPoint: startAnimation ? .bottomTrailing : .topLeading
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
            
            VStack(spacing: 35) {
                Spacer()
                
                // Brand Section
                VStack(spacing: 15) {
                    ZStack {
                        // Glassmorphic background for the logo
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.07))
                            .frame(width: 90, height: 90)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                        
                        // Heart + Code symbol mockup
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
                    
                    Text("TechConnect")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    Text("Connect. Code. Collaborate.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
                Spacer()
                
                // Login Buttons Box (Glassmorphic Panel)
                if showPanel {
                    VStack(spacing: 18) {
                        Text("Profesyonel eşleşmeye başlamak için giriş yapın.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        
                        // GitHub Login Button
                        Button(action: {
                            withAnimation {
                                isLoggedIn = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "terminal.fill")
                                    .font(.title2)
                                Text("GitHub ile Giriş Yap")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.85), Color(red: 0.1, green: 0.1, blue: 0.15)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // Apple Login Button
                        Button(action: {
                            withAnimation {
                                isLoggedIn = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .font(.title2)
                                Text("Apple ile Giriş Yap")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(14)
                        }
                        
                        // Guest Mode (For demonstration)
                        Button(action: {
                            withAnimation {
                                isLoggedIn = true
                            }
                        }) {
                            Text("Misafir Olarak Keşfet")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.purple.opacity(0.9))
                        }
                        .padding(.top, 10)
                    }
                    .padding(24)
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
                
                // Terms and Conditions
                Text("Giriş yaparak, Kullanım Şartları ve Gizlilik Politikası'nı kabul etmiş olursunuz.")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
