//
//  UserGetters.swift
//  Events
//
//  Created by Димасик on 1/12/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeFunctions
import SomeBridge

extension User {
  var isOnline: Bool {
    return publicOptions.contains(.online)
  }
  var hasAvatar: Bool {
    return publicOptions.contains(.avatar)
  }
  var isDeleted: Bool {
    return publicOptions.contains(.deleted)
  }
  var isBanned: Bool {
    return publicOptions.contains(.banned)
  }
  var avatarStatus: RemoteFileStatus {
    if isAvatarDownloaded && avatarURL.exists {
      return .downloaded
    } else if let download = serverManager.downloads[avatarTemp] {
      switch download.status {
      case .waiting:
        return .waiting
      case .downloading:
        return .downloading
      case .downloaded:
        return .downloaded
      case .cancelled:
        return .waiting
      }
    } else {
      return .waiting
    }
  }
  
  var isFriend: Bool {
    return account.friends.contains(id)
  }
  
  var friendStatus: FriendStatus {
    if account.friends.contains(id) {
      return .friend
    } else if account.outcoming.contains(id) {
      return .outcoming
    } else if account.incoming.contains(id) {
      return .incoming
    } else {
      return .notFriend
    }
  }
  
  var isMainLoaded: Bool {
    get {
      return localOptions[.mainLoaded]
    } set {
      localOptions[.mainLoaded] = newValue
    }
  }
  var isPublicLoaded: Bool {
    get {
      return localOptions[.publicLoaded]
    } set {
      localOptions[.publicLoaded] = newValue
    }
  }
  var isAvatarDownloaded: Bool {
    get {
      return localOptions[.avatarDownloaded]
    } set {
      localOptions[.avatarDownloaded] = newValue
    }
  }
  var isSubscriber: Bool {
    get {
      return localOptions[.isSubscriber]
    } set {
      localOptions[.isSubscriber] = newValue
    }
  }
  var shouldUpdateMain: Bool {
    get {
      return localOptions[.mainUpdate]
    } set {
      localOptions[.mainUpdate] = newValue
    }
  }
  var shouldUpdateAvatar: Bool {
    return downloadedAvatarVersion != avatarVersion
  }
}


extension ID {
  var user: User! {
    return usersManager[self]
  }
  var userName: String {
    if let user = user {
      return "\(user.name) (\(self))"
    } else {
      return "unknown (\(self))"
    }
  }
}

extension Sequence where Iterator.Element == User {
  var ids: [ID] { return map { $0.id } }
}

extension Sequence where Iterator.Element == ID {
  var usersArray: [User] { return map { usersManager[$0]! } }
  var userNames: String {
    var string = ""
    for id in self {
      if string.isEmpty {
        string += id.userName
      } else {
        string += ", \(id.userName)"
      }
    }
    return string
  }
  var missingUsers: Set<ID> {
    var set = Set<ID>()
    for id in self {
      if id.user == nil {
        set.insert(id)
      }
    }
    return set
  }
  var containsMissingUsers: Bool {
    for id in self {
      if id.user == nil {
        return true
      }
    }
    return false
  }
}
