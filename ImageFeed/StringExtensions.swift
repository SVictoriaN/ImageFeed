import Foundation

extension String {
    func toFormattedDate() -> String? {
        let dateFormatter = ISO8601DateFormatter()
        
        guard let date = dateFormatter.date(from: self) else { return nil }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ru_RU")
        outputFormatter.dateFormat = "d MMMM yyyy"
        
        return outputFormatter.string(from: date)
    }
}
