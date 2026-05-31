import Foundation
import Combine

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "https://devmatch-u36s.onrender.com"
    private let tokenKey = "techconnect_jwt_token"
    
    private init() {}
    
    // Save token
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    // Get token
    var token: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }
    
    // Clear token
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    
    // Check if logged in
    var isLoggedIn: Bool {
        token != nil
    }
    
    // Helper to make requests
    private func makeRequest<T: Decodable>(
        path: String,
        method: String,
        body: Data? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let jwt = token {
                request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            } else {
                throw URLError(.userAuthenticationRequired)
            }
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            clearToken()
            throw URLError(.userAuthenticationRequired)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMsg = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorMsg["error"] as? String {
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: error])
            }
            throw URLError(.badServerResponse)
        }
        
        // DEBUG: Print raw JSON response
        if let rawString = String(data: data, encoding: .utf8) {
            print("[APIService DEBUG] Raw response for \(path):")
            print(rawString)
        }
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            if let date = dateFormatter.date(from: dateStr) {
                return date
            }
            let isoDecoder = ISO8601DateFormatter()
            isoDecoder.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoDecoder.date(from: dateStr) {
                return date
            }
            let fallbackFormatter = ISO8601DateFormatter()
            if let date = fallbackFormatter.date(from: dateStr) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("[APIService ERROR] Decode error for \(path): \(error)")
            throw error
        }
    }
    
    // Auth Endpoints
    func login(email: String, password: String) async throws -> AuthResponseSwift {
        let payload: [String: String] = [
            "email": email,
            "password": password
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: payload)
        
        let response: AuthResponseSwift = try await makeRequest(
            path: "/api/v1/auth/login",
            method: "POST",
            body: bodyData,
            requiresAuth: false
        )
        saveToken(response.token)
        return response
    }
    
    func register(req: RegisterRequestSwift) async throws -> AuthResponseSwift {
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(req)
        
        let response: AuthResponseSwift = try await makeRequest(
            path: "/api/v1/auth/register",
            method: "POST",
            body: bodyData,
            requiresAuth: false
        )
        saveToken(response.token)
        return response
    }
    
    // Profile Endpoints
    func getMyProfile() async throws -> DeveloperProfile {
        try await makeRequest(path: "/api/v1/profiles/me", method: "GET")
    }
    
    func updateMyProfile(profile: DeveloperProfile) async throws -> DeveloperProfile {
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(profile)
        return try await makeRequest(path: "/api/v1/profiles/me", method: "PUT", body: bodyData)
    }
    
    func uploadPhoto(image: Data) async throws -> DeveloperProfile {
        guard let url = URL(string: "\(baseURL)/api/v1/profiles/me/photo") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let jwt = token {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        } else {
            throw URLError(.userAuthenticationRequired)
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(image)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            clearToken()
            throw URLError(.userAuthenticationRequired)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMsg = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorMsg["error"] as? String {
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: error])
            }
            throw URLError(.badServerResponse)
        }
        
        if let rawString = String(data: data, encoding: .utf8) {
            print("[APIService DEBUG] Raw response for upload photo:")
            print(rawString)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(DeveloperProfile.self, from: data)
    }
    
    func deleteAccount() async throws {
        guard let url = URL(string: "\(baseURL)/api/v1/profiles/me") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let jwt = token {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        } else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            clearToken()
            throw URLError(.userAuthenticationRequired)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMsg = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorMsg["error"] as? String {
                throw NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: error])
            }
            throw URLError(.badServerResponse)
        }
    }
    
    func getDiscoverDeck() async throws -> [DeveloperProfile] {
        try await makeRequest(path: "/api/v1/profiles/discover", method: "GET")
    }
    
    // Swipe Endpoints
    struct SwipePayload: Codable {
        let targetId: UUID
        let direction: String
    }
    
    struct SwipeResponseSwift: Codable {
        let matched: Bool
        let matchId: UUID?
    }
    
    func swipe(targetId: UUID, isLike: Bool) async throws -> SwipeResponseSwift {
        let payload = SwipePayload(targetId: targetId, direction: isLike ? "LIKE" : "PASS")
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(payload)
        return try await makeRequest(path: "/api/v1/swipes", method: "POST", body: bodyData)
    }
    
    // Chat & Matches Endpoints
    func getMatches() async throws -> [Match] {
        try await makeRequest(path: "/api/v1/matches", method: "GET")
    }
    
    func getMessages(matchId: UUID) async throws -> [Message] {
        try await makeRequest(path: "/api/v1/matches/\(matchId)/messages", method: "GET")
    }
    
    func sendMessage(matchId: UUID, content: String) async throws -> Message {
        let payload = ["content": content]
        let bodyData = try JSONSerialization.data(withJSONObject: payload)
        return try await makeRequest(path: "/api/v1/matches/\(matchId)/messages", method: "POST", body: bodyData)
    }
    
    // Coffee Chat Endpoints
    func proposeCoffeeChat(matchId: UUID, proposedTime: Date) async throws -> CoffeeChatRequestSwift {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateStr = formatter.string(from: proposedTime)
        
        let payload: [String: Any] = [
            "matchId": matchId.uuidString,
            "proposedTime": dateStr
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: payload)
        return try await makeRequest(path: "/api/v1/coffee-chats", method: "POST", body: bodyData)
    }
}

// Swift equivalents of DTOs
struct AuthResponseSwift: Codable {
    let token: String
    let profile: DeveloperProfile
}

struct RegisterRequestSwift: Codable {
    let email: String
    let password: String
    let displayName: String
    let githubUsername: String
    let role: String
    let experienceYears: Int
    let sector: Sector
    let lookingFor: LookingFor
    let city: String
    let isRemote: Bool
    let techStack: [String]
    let photoNames: [String]
}

struct CoffeeChatRequestSwift: Codable {
    let id: UUID
    let matchId: UUID
    let requesterId: UUID
    let proposedTime: Date
    let status: String
}
