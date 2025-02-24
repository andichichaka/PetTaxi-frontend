struct Review: Identifiable, Decodable, Encodable {
    let id: Int
    let comment: String
    var user: User
    let createdAt: String
}
