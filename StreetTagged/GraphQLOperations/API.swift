//  This file was automatically generated and should not be edited.

import AWSAppSync

public final class SaveUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation SaveUser($id: ID, $username: String, $firstName: String, $lastName: String, $bio: String, $image: String, $location: String) {\n  saveUser(id: $id, username: $username, firstName: $firstName, lastName: $lastName, bio: $bio, image: $image, location: $location) {\n    __typename\n    id\n    username\n    firstName\n    lastName\n    bio\n    image\n    location\n  }\n}"

  public var id: GraphQLID?
  public var username: String?
  public var firstName: String?
  public var lastName: String?
  public var bio: String?
  public var image: String?
  public var location: String?

  public init(id: GraphQLID? = nil, username: String? = nil, firstName: String? = nil, lastName: String? = nil, bio: String? = nil, image: String? = nil, location: String? = nil) {
    self.id = id
    self.username = username
    self.firstName = firstName
    self.lastName = lastName
    self.bio = bio
    self.image = image
    self.location = location
  }

  public var variables: GraphQLMap? {
    return ["id": id, "username": username, "firstName": firstName, "lastName": lastName, "bio": bio, "image": image, "location": location]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("saveUser", arguments: ["id": GraphQLVariable("id"), "username": GraphQLVariable("username"), "firstName": GraphQLVariable("firstName"), "lastName": GraphQLVariable("lastName"), "bio": GraphQLVariable("bio"), "image": GraphQLVariable("image"), "location": GraphQLVariable("location")], type: .object(SaveUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(saveUser: SaveUser? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "saveUser": saveUser.flatMap { $0.snapshot }])
    }

    public var saveUser: SaveUser? {
      get {
        return (snapshot["saveUser"] as? Snapshot).flatMap { SaveUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "saveUser")
      }
    }

    public struct SaveUser: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("firstName", type: .scalar(String.self)),
        GraphQLField("lastName", type: .scalar(String.self)),
        GraphQLField("bio", type: .scalar(String.self)),
        GraphQLField("image", type: .scalar(String.self)),
        GraphQLField("location", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, username: String, firstName: String? = nil, lastName: String? = nil, bio: String? = nil, image: String? = nil, location: String? = nil) {
        self.init(snapshot: ["__typename": "User", "id": id, "username": username, "firstName": firstName, "lastName": lastName, "bio": bio, "image": image, "location": location])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var firstName: String? {
        get {
          return snapshot["firstName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "firstName")
        }
      }

      public var lastName: String? {
        get {
          return snapshot["lastName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastName")
        }
      }

      public var bio: String? {
        get {
          return snapshot["bio"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bio")
        }
      }

      public var image: String? {
        get {
          return snapshot["image"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "image")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
        }
      }
    }
  }
}

public final class WriteCommentMutation: GraphQLMutation {
  public static let operationString =
    "mutation WriteComment($id: ID, $content: String) {\n  writeComment(id: $id, content: $content) {\n    __typename\n    postid\n    commentid\n    content\n  }\n}"

  public var id: GraphQLID?
  public var content: String?

  public init(id: GraphQLID? = nil, content: String? = nil) {
    self.id = id
    self.content = content
  }

  public var variables: GraphQLMap? {
    return ["id": id, "content": content]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("writeComment", arguments: ["id": GraphQLVariable("id"), "content": GraphQLVariable("content")], type: .object(WriteComment.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(writeComment: WriteComment? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "writeComment": writeComment.flatMap { $0.snapshot }])
    }

    public var writeComment: WriteComment? {
      get {
        return (snapshot["writeComment"] as? Snapshot).flatMap { WriteComment(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "writeComment")
      }
    }

    public struct WriteComment: GraphQLSelectionSet {
      public static let possibleTypes = ["Comment"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("postid", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("commentid", type: .nonNull(.scalar(String.self))),
        GraphQLField("content", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(postid: GraphQLID, commentid: String, content: String? = nil) {
        self.init(snapshot: ["__typename": "Comment", "postid": postid, "commentid": commentid, "content": content])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var postid: GraphQLID {
        get {
          return snapshot["postid"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "postid")
        }
      }

      public var commentid: String {
        get {
          return snapshot["commentid"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentid")
        }
      }

      public var content: String? {
        get {
          return snapshot["content"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "content")
        }
      }
    }
  }
}

public final class DeleteCommentMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteComment($d: ID) {\n  deleteComment(d: $d) {\n    __typename\n    postid\n    commentid\n    content\n  }\n}"

  public var d: GraphQLID?

  public init(d: GraphQLID? = nil) {
    self.d = d
  }

  public var variables: GraphQLMap? {
    return ["d": d]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteComment", arguments: ["d": GraphQLVariable("d")], type: .object(DeleteComment.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteComment: DeleteComment? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteComment": deleteComment.flatMap { $0.snapshot }])
    }

    public var deleteComment: DeleteComment? {
      get {
        return (snapshot["deleteComment"] as? Snapshot).flatMap { DeleteComment(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteComment")
      }
    }

    public struct DeleteComment: GraphQLSelectionSet {
      public static let possibleTypes = ["Comment"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("postid", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("commentid", type: .nonNull(.scalar(String.self))),
        GraphQLField("content", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(postid: GraphQLID, commentid: String, content: String? = nil) {
        self.init(snapshot: ["__typename": "Comment", "postid": postid, "commentid": commentid, "content": content])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var postid: GraphQLID {
        get {
          return snapshot["postid"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "postid")
        }
      }

      public var commentid: String {
        get {
          return snapshot["commentid"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentid")
        }
      }

      public var content: String? {
        get {
          return snapshot["content"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "content")
        }
      }
    }
  }
}

public final class GetUserQuery: GraphQLQuery {
  public static let operationString =
    "query GetUser($id: ID, $username: String) {\n  getUser(id: $id, username: $username) {\n    __typename\n    id\n    username\n    firstName\n    lastName\n    bio\n    image\n    location\n  }\n}"

  public var id: GraphQLID?
  public var username: String?

  public init(id: GraphQLID? = nil, username: String? = nil) {
    self.id = id
    self.username = username
  }

  public var variables: GraphQLMap? {
    return ["id": id, "username": username]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getUser", arguments: ["id": GraphQLVariable("id"), "username": GraphQLVariable("username")], type: .object(GetUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getUser: GetUser? = nil) {
      self.init(snapshot: ["__typename": "Query", "getUser": getUser.flatMap { $0.snapshot }])
    }

    public var getUser: GetUser? {
      get {
        return (snapshot["getUser"] as? Snapshot).flatMap { GetUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getUser")
      }
    }

    public struct GetUser: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("firstName", type: .scalar(String.self)),
        GraphQLField("lastName", type: .scalar(String.self)),
        GraphQLField("bio", type: .scalar(String.self)),
        GraphQLField("image", type: .scalar(String.self)),
        GraphQLField("location", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, username: String, firstName: String? = nil, lastName: String? = nil, bio: String? = nil, image: String? = nil, location: String? = nil) {
        self.init(snapshot: ["__typename": "User", "id": id, "username": username, "firstName": firstName, "lastName": lastName, "bio": bio, "image": image, "location": location])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var firstName: String? {
        get {
          return snapshot["firstName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "firstName")
        }
      }

      public var lastName: String? {
        get {
          return snapshot["lastName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastName")
        }
      }

      public var bio: String? {
        get {
          return snapshot["bio"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bio")
        }
      }

      public var image: String? {
        get {
          return snapshot["image"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "image")
        }
      }

      public var location: String? {
        get {
          return snapshot["location"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "location")
        }
      }
    }
  }
}