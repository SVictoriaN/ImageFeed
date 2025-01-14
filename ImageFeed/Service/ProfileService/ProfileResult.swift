import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String?  
    let lastName: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case username
        case firstName
        case lastName 
        case bio
    }
}



