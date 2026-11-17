import Foundation
@testable import Lab01UIKit

enum TestData {

    static let users = [
        User(id: 1, name: "Leanne Graham", username: "Bret", email: "sincere@april.biz"),
        User(id: 2, name: "Ervin Howell", username: "Antonette", email: "shanna@melissa.tv")
    ]

    static let posts = [
        Post(userId: 1, id: 1, title: "first", body: "a"),
        Post(userId: 1, id: 2, title: "second", body: "b"),
        Post(userId: 2, id: 3, title: "third", body: "c")
    ]

    static var content: FeedContent {
        FeedContent(users: users, posts: posts)
    }
}
