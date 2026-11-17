// https://jsonplaceholder.typicode.com/posts
struct Post: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
