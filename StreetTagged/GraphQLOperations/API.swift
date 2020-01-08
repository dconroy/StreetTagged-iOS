//  This file was automatically generated and should not be edited.

import AWSAppSync

public final class SaveMutation: GraphQLMutation {
  public static let operationString =
    "mutation Save($id: ID, $username: String, $firstName: String, $lastName: String, $bio: String, $image: String, $location: String) {\n  save(id: $id, username: $username, firstName: $firstName, lastName: $lastName, bio: $bio, image: $image, location: $location) {\n    __typename\n    id\n    username\n    firstName\n    lastName\n    bio\n    image\n    location\n  }\n}"

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
      GraphQLField("save", arguments: ["id": GraphQLVariable("id"), "username": GraphQLVariable("username"), "firstName": GraphQLVariable("firstName"), "lastName": GraphQLVariable("lastName"), "bio": GraphQLVariable("bio"), "image": GraphQLVariable("image"), "location": GraphQLVariable("location")], type: .object(Save.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(save: Save? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "save": save.flatMap { $0.snapshot }])
    }

    public var save: Save? {
      get {
        return (snapshot["save"] as? Snapshot).flatMap { Save(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "save")
      }
    }

    public struct Save: GraphQLSelectionSet {
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

public final class GetQuery: GraphQLQuery {
  public static let operationString =
    "query Get($id: ID, $username: String) {\n  get(id: $id, username: $username) {\n    __typename\n    id\n    username\n    firstName\n    lastName\n    bio\n    image\n    location\n  }\n}"

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
      GraphQLField("get", arguments: ["id": GraphQLVariable("id"), "username": GraphQLVariable("username")], type: .object(Get.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(`get`: Get? = nil) {
      self.init(snapshot: ["__typename": "Query", "get": `get`.flatMap { $0.snapshot }])
    }

    public var `get`: Get? {
      get {
        return (snapshot["get"] as? Snapshot).flatMap { Get(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "get")
      }
    }

    public struct Get: GraphQLSelectionSet {
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