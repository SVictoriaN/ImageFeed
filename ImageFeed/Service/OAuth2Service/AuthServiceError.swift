import Foundation

enum AuthServiceError: Error {
    case invalidRequest
    case noData
    case decodingError(Error)
    case duplicateRequest
}
