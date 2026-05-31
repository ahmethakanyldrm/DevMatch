import SwiftUI

struct ProfileImageView: View {
    let photoName: String?
    let size: CGFloat
    var useGrayBackgroundForSystem: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    private var isSystemSymbol: Bool {
        guard let name = photoName else { return true }
        // If it does not contain a dot (like .png, .jpg) or a slash, treat it as an SF Symbol name.
        return !name.contains(".") && !name.contains("/")
    }
    
    private var imageUrl: URL? {
        guard let name = photoName, !isSystemSymbol else { return nil }
        if name.lowercased().hasPrefix("http") {
            return URL(string: name)
        }
        // Base backend URL for live server
        return URL(string: "https://devmatch-u36s.onrender.com/uploads/\(name)")
    }
    
    var body: some View {
        Group {
            if isSystemSymbol {
                ZStack {
                    if useGrayBackgroundForSystem {
                        Circle()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Image(systemName: photoName ?? "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.5, height: size * 0.5)
                        .foregroundColor(useGrayBackgroundForSystem ? (colorScheme == .dark ? .white : .primary) : .white)
                }
            } else if let url = imageUrl {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                    case .failure:
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                            Image(systemName: "person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size * 0.5, height: size * 0.5)
                                .foregroundColor(.white)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size * 0.5, height: size * 0.5)
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
