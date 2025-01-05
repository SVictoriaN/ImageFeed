import Foundation

enum AuthServiceError: Error {
    case invalidRequest
    case noData
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidRequest:
            return "Не удалось создать запрос"
        case .noData:
            return "Нет данных ответа"
        case .decodingError(_):
            return "Ошибка декодирования: (error.localizedDescription)"
        }
    }
}
