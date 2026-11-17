// https://jsonplaceholder.typicode.com/users
struct User: Decodable {
    let id: Int
    let name: String
    let username: String
    let email: String
}
