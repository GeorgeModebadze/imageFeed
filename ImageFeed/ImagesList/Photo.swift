import Foundation

public enum PhotoModels {
    public enum Error: Swift.Error {
        case missingCreationDate
    }
    
    public struct Photo {
        public let id: String
        public let size: CGSize
        public let createdAt: Date?
        public let welcomeDescription: String?
        public let thumbImageURL: String
        public let largeImageURL: String
        public var isLiked: Bool
        
        public init(
            id: String,
            size: CGSize,
            createdAt: Date?,
            welcomeDescription: String?,
            thumbImageURL: String,
            largeImageURL: String,
            isLiked: Bool
        ) {
            self.id = id
            self.size = size
            self.createdAt = createdAt
            self.welcomeDescription = welcomeDescription
            self.thumbImageURL = thumbImageURL
            self.largeImageURL = largeImageURL
            self.isLiked = isLiked
        }
        
        public func requireCreatedAt() throws -> Date {
            guard let date = createdAt else {
                throw Error.missingCreationDate
            }
            return date
        }
    }
}


