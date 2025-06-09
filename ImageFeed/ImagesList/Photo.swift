import Foundation

enum PhotoError: Error {
    case missingCreationDate
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    func requireCreatedAt() throws -> Date {
        guard let date = createdAt else {
            throw PhotoError.missingCreationDate
        }
        return date
    }
}


