//
//  FriendList.swift
//  faggot
//
//  Created by Димасик on 01/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

class FriendsPage: Page, UISearchBarDelegate, AccountNotifications {
  let searchBar: DFSearchBar
//  let searchView: SearchView
  let contentView: DFContentView
  var isSearching = false
  
  private let share = FShare()
  
  private let nearFriends = NearFriends()
  private lazy var nearUsersTitle = TitleBlock(text: "Near you".uppercased())
  private var nearUsers = Set<User>()
  private var nearUserBlocks = [UserView]()
  private lazy var friendsTitle = TitleBlock(text: "Friends".uppercased())
  
  var count: Int
  
  override init() {
    
    searchBar = DFSearchBar(frame: .zero)
    searchBar.dframe = { CGRect(Pos(60,screen.top+NBHeight/2),.left,Size(screen.width-80,40)) }
    searchBar.autocapitalizationType = .none
    
    contentView = DFContentView(frame: screen.frame)
    contentView.dframe = { screen.frame }
    contentView.contentInset.top = screen.top + NBHeight
    contentView.contentInset.bottom = screen.height - screen.bottom - 20
    
    count = account.friends.count
    count += account.incoming.count
    count += account.outcoming.count
    
    super.init()
    
    searchBar.searchBarStyle = .minimal
    searchBar.delegate = self
    addSubview(contentView)
    
    contentView.append(share, animated: false)
    showFriends()
    showsNavigationBar = true
    
    nearFriends.insertUser = { [weak self] id in
      guard self != nil else { return }
      id.loadUser { [weak self] user in
        self?.insert(near: user)
      }?.autorepeat(self!)
    }
  }
  
  // Account Notifications
  func added(friends: Set<ID>) {
    load(ids: friends)
  }
  
  func removed(friends: Set<ID>) {
    unload(ids: friends)
  }
  
  func added(incoming: Set<ID>) {
    load(ids: incoming)
  }
  
  func removed(incoming: Set<ID>) {
    unload(ids: incoming)
  }
  
  func added(outcoming: Set<ID>) {
    load(ids: outcoming)
  }
  
  func removed(outcoming: Set<ID>) {
    unload(ids: outcoming)
  }
  
  override func resolutionChanged() {
    super.resolutionChanged()
    contentView.contentInset.top = screen.top + NBHeight
    contentView.contentInset.bottom = screen.height - screen.bottom - 20
  }
  
  func insert(near user: User) {
    guard !nearUsers.contains(user) else { return }
    let block = UserView(user: user, page: self)
    if !isSearching {
      if nearUsers.isEmpty {
        contentView.insert(block, at: 1)
        contentView.insert(nearUsersTitle, at: 1)
      } else {
        contentView.insert(block, at: nearUserBlocks.count + 2)
      }
    }
    nearUserBlocks.append(block)
    nearUsers.insert(user)
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    closeSearch()
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    isSearching = true
    searchBar.resignFirstResponder()
    (searchBar.value(forKey: "_cancelButton") as? UIButton)?.isEnabled = true
    guard let text = searchBar.text , text.count > 0 else { return }
    print(text)
    request()
      .search(users: text.lowercased()) { (ids) in
        mainThread {
          self.searched(ids: Set(ids))
        }
    }
    
//    let download = RequestProgress()
//    downloadManager.subscribe(download, view: searchBar, path: nil, page: self)
//    serverThread {
//      do {
//        let user = try Server.checkUser(text)
//        mainThread {
//          self.contentView.shows = false
//          self.searchView.display(user, page: self)
//        }
//      } catch {
//        download.done()
//      }
//      download.complete()
//    }
  }
  
  override func didShow() {
    main.navigation.display(searchBar)
    nearFriends.start()
    
    if firstShow && account.friends.isEmpty && account.incoming.isEmpty && account.outcoming.isEmpty {
      searchBar.becomeFirstResponder()
    }
  }
  
  override func closed() {
    nearFriends.stop()
  }
  
  override func willHide() {
    searchBar.destroy()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
private extension FriendsPage {
  func showFriends() {
    guard count > 0 else { return }
    var ids = account.friends
    ids += account.incoming
    ids += account.outcoming
    
    contentView.append(friendsTitle, animated: false)
    
    ids.loadUsers { [weak self] users in
      guard self != nil else { return }
      let users = users.sorted { $0.name < $1.name }
      for user in users {
        self!.append(user: user, animated: false)
      }
    }?.autorepeat(self)
    
//    if let users = usersManager.getAll(users: ids) {
//      insert(friends: users)
//    } else {
//      request()
//        .userMains(ids: ids, filter: true) { users in
//          let array = users.sorted { $0.name < $1.name }
//          mainThread {
//            self.insert(friends: array)
//          }
//      }
//    }
  }
  
  func load(ids: Set<Int64>) {
    ids.loadUsers { [weak self] users in
      guard self != nil else { return }
      for user in users {
        self!.insert(user: user, animated: true)
      }
    }?.autorepeat(self)
//    if let users = usersManager.getAll(users: ids) {
//      for user in users {
//        insert(user: user)
//      }
//    } else {
//      request()
//      .userMains(ids: ids, filter: true) { users in
//        mainThread {
//          for user in users {
//            self.insert(user: user)
//          }
//        }
//      }
//    }
  }
  
  func unload(ids: Set<Int64>) {
    for id in ids {
      remove(user: id)
    }
  }
  func append(user: User, animated: Bool) {
    guard !isSearching else { return }
    let view = UserView(user: user, page: self)
    self.contentView.append(view, animated: animated)
  }
  
  func insert(user: User, animated: Bool) {
    guard !isSearching else { return }
    if let cell = find(user.id) {
      cell.update()
    } else {
      if count == 0 {
        contentView.append(friendsTitle, animated: animated)
      }
      
      count += 1
      let view = UserView(user: user, page: self)
      self.contentView.insert(view, at: friendsTitle.index + 1, animated: animated)
    }
  }
  
  func remove(user id: Int64) {
    guard !isSearching else { return }
    guard let cell = find(id) else { return }
    contentView.remove(cell)
  }
  
  func find(_ id: Int64) -> UserView? {
    for block in contentView.cells {
      guard let block = block as? UserView else { continue }
      guard block.user.id == id else { continue }
      return block
    }
    return nil
  }
  
  func closeSearch() {
    guard isSearching else { return }
    isSearching = false
    searchBar.setShowsCancelButton(false, animated: true)
    contentView.removeAll()
    contentView.append(share, animated: false)
    if !nearUsers.isEmpty {
      contentView.append(nearUsersTitle, animated: false)
      for block in nearUserBlocks {
        contentView.append(block, animated: false)
      }
      contentView.append(friendsTitle, animated: false)
    }
    self.showFriends()
  }
  
  func searched(ids: Set<Int64>) {
    contentView.removeAll()
    ids.loadUsers { [weak self] users in
      self?.insert(search: users)
    }
  }
  
  func insert(search users: [User]) {
    for user in users {
      let view = UserView(user: user, page: self)
      self.contentView.append(view, animated: false)
    }
  }
  
  func insert(friends users: [User]) {
    var incoming = [User]()
    var outcoming = [User]()
    var friends = [User]()
    for user in users {
      let status = user.friendStatus
      switch status {
      case .friend: friends.append(user)
      case .incoming: incoming.append(user)
      case .outcoming: outcoming.append(user)
      default: break
      }
    }
    incoming.sort { $0.name < $1.name }
    outcoming.sort { $0.name < $1.name }
    friends.sort { $0.name < $1.name }
    for user in incoming {
      let view = UserView(user: user, page: self)
      self.contentView.append(view, animated: false)
    }
    for user in friends {
      let view = UserView(user: user, page: self)
      self.contentView.append(view, animated: false)
    }
    for user in outcoming {
      let view = UserView(user: user, page: self)
      self.contentView.append(view, animated: false)
    }
  }
  
  
  class TitleBlock: Block {
    var titleLabel: UILabel
    init(text: String) {
      titleLabel = UILabel()
      titleLabel.text = text
      titleLabel.font = .caption1
      titleLabel.frame.origin = Pos(screen.left + .margin, 4)
      super.init(height: UIFont.caption1.lineHeight + 8)
      addSubview(titleLabel)
      backgroundColor = .white(0.2)
      resolutionChanged()
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    override func resolutionChanged() {
      let text = titleLabel.text!
      let font = UIFont.caption1
      let maxWidth: CGFloat = screen.right - screen.left - .margin - .margin
      let width = min(text.width(font),maxWidth)
      let height = text.height(font, width: maxWidth)
      titleLabel.frame.size = Size(width,height)
      self.height = height + 8
    }
  }
}

extension FriendsPage: UserMainNotifications {
  func updated(user: User, name: String) {
    find(user.id)?.set(name: name)
  }
  
  func updated(user: User, online: Bool) {
    
  }
  
  func updated(user: User, deleted: Bool) {
    
  }
  
  func updated(user: User, banned: Bool) {
    
  }
  
  func updated(user: User, avatar: Bool) {
    find(user.id)?.updateAvatar()
  }
}

private class UserView: Block {
//  class Button: DPButton {
//    init(text: String) {
//      super.init(text: text, font: .normal(16), color: .dark)
//      button.backgroundColor = .black(0.5)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//    }
//  }
  let photo: UIImageView
  let name: UILabel
  let user: User
  weak var page: Page?
  var statusLabel: UILabel?
  
  init(user: User, page: Page) {
    self.page = page
    self.user = user
    photo = UIImageView(frame: CGRect(screen.left + 20,5,40,40))
    photo.backgroundColor = .background
    photo.clipsToBounds = true
    photo.layer.cornerRadius = 20
    photo.contentMode = .scaleAspectFill
    name = UILabel(pos: Pos(screen.left + 80,22.5), anchor: .left, text: user.name, color: .dark, font: .light(18))
    super.init(height: 50)
    addSubview(photo)
    addSubview(name)
    
//    if profileManager.friendStatus(user.id) == .friending {
//      let status = UILabel(pos: name.view.frame.bottomLeft, anchor: _topLeft, text: "Request sent", color: .dark, font: .normal(11))
//      addSubview(status)
//    }
    
    selectable = true
    loadPhoto()
    switch user.friendStatus {
    case .outcoming:
      set(status: "Request sent")
    case .incoming:
      set(status: "Incoming request")
    default: break
    }
  }
  
  override func resolutionChanged() {
    super.resolutionChanged()
    photo.frame.x = screen.left + 20
    name.frame.x = screen.left + 80
  }
  
  func accept() {
    user.friend()
  }
  
  func decline() {
    user.unfriend()
  }
  
  func cancel() {
    user.unfriend()
  }
  
  func update() {
    switch user.friendStatus {
    case .outcoming:
      set(status: "Request sent")
    case .incoming:
      set(status: "Incoming request")
    default:
      set(status: "")
    }
  }
  
  func set(status: String) {
    if status.isEmpty {
      name.move(y: 22.5, .left)
    } else {
      name.move(y: 16, .left)
    }
    if statusLabel == nil {
      statusLabel = UILabel(pos: name.frame.bottomLeft, anchor: .topLeft, text: status, color: .dark, font: .normal(11))
      addSubview(statusLabel!)
    }
    statusLabel!.text = status
    statusLabel!.fixFrame(false)
  }
  func set(name: String) {
    self.name.set(text: name, anchor: .left)
  }
  func updateAvatar() {
    if user.hasAvatar {
      self.photo.user(page!, user: user)
    } else {
      self.photo.image = nil
    }
  }
  
  override func selected() {
    main.push(UserPage(user: user))
  }
  
  func loadPhoto() {
    guard page != nil else { return }
    self.photo.user(page!, user: user)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
