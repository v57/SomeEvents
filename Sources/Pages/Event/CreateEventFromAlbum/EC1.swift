//
//  AlbumSelecter.swift
//  Events
//
//  Created by Димасик on 5/6/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some
import Photos
import SomeTable

class AlbumPage: Page {
  let titleLabel: UILabel
  let table = Table()
  override init() {
    
    titleLabel = UILabel(text: "Select album", color: .black, font: .navigationBarLarge)
    titleLabel.frame.origin = Pos(.margin,-60)
    super.init()
    table.insets.left = .margin
    table.insets.right = .margin
//    table.insets.top = screen.top + 64
    
    table.gap.vertical = .miniMargin
    table.gap.horizontal = .miniMargin
    table.type = .grid
    
//    table.resize(size: screen.resolution, animated: false)
    
    addSubview(table)
    table.view.addSubview(titleLabel)
    
    findAlbums()
  }
  
  func findAlbums() {
    let cell = AlbumCell(collection: nil)
    self.table.append(cell, animated: false)
    PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil).enumerateObjects(options: [.reverse,.concurrent]) { collection, index, stop in
      guard collection.estimatedAssetCount > 0 else { return }
      let cell = AlbumCell(collection: collection)
      self.table.append(cell, animated: false)
    }
    PHAssetCollection.fetchAssetCollections(with: .moment, subtype: .any, options: nil).enumerateObjects(options: [.reverse,.concurrent]) { collection, index, stop in
        assert(Thread.current.isMainThread)
        guard collection.estimatedAssetCount > 0 else { return }
        let cell = AlbumCell(collection: collection)
        self.table.append(cell, animated: false)
    }
    PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil).enumerateObjects(options: [.concurrent]) { collection, index, stop in
        assert(Thread.current.isMainThread)
        guard collection.estimatedAssetCount > 0 else { return }
        let cell = AlbumCell(collection: collection)
        self.table.append(cell, animated: false)
    }
  }
  
  override func resolutionChanged() {
    super.resolutionChanged()
    table.resize(size: screen.resolution, animated: false)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class AlbumCell: SomeTable.Cell {
  let collection: PHAssetCollection?
  var title: String? {
    if let collection = collection {
      return collection.localizedTitle
    } else {
      return "All Photos"
    }
  }
//  var count: Int {
//    return collection?.estimatedAssetCount ?? 0
//  }
  override func size(fitting: CGSize, max: CGSize) -> CGSize {
    return CGSize(50,50)
  }
//  override var size: CGSize {
//    return CGSize(180,180)
//  }
  init(collection: PHAssetCollection?) {
    self.collection = collection
    super.init()
  }
  override func makeView() -> UIView {
    let size = self.size
    let imageView = UIImageView(frame: frame)
    
//    imageView.clipsToBounds = true
    weak var _imageView = imageView
    weak var _label: UILabel?
    
    let collection = self.collection
    
    if let title = title, !title.isEmpty {
      let label = UILabel(text: title, color: .black, font: .heavy(18), maxWidth: size.width - .miniMargin2)
      label.adjustsFontSizeToFitWidth = true
      label.minimumScaleFactor = 0.6
      label.move(Pos(.miniMargin,size.height - 4), .bottomLeft)
      imageView.addSubview(label)
      _label = label
    }
    
    newThread {
      let options = PHFetchOptions()
      options.fetchLimit = 5
      let fetch: PHFetchResult<PHAsset>
      if let collection = collection {
        fetch = PHAsset.fetchAssets(in: collection, options: options)
      } else {
        fetch = PHAsset.fetchAssets(with: options)
      }
      fetch.enumerateObjects(options: [.reverse]) { (asset, id, stop) in
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        options.isSynchronous = false
        PHImageManager.default().requestImage(for: asset, targetSize: size * screen.retina, contentMode: .aspectFill, options: options) { (image, info) in
          imageThread {
//            guard let data = data else {
//              print("no data for asset")
//              return }
//            guard var image = UIImage(data: data) else {
//              print("no image for asset")
//              return }
            guard var image = image else {
              print("no image for asset")
              return }
            stop.pointee = true
            image = UIImage.draw(size: size, retina: true) { context in
              let scale = min(image.width / size.width, image.height / size.height)
              let newSize = image.size / scale
              let frame = CGRect(origin: CGPoint((size.width-newSize.width) / 2,(size.height-newSize.height) / 2), size: newSize)
              
              context.addPath(UIBezierPath(roundedRect: CGRect(size: size), cornerRadius: .margin).cgPath)
              context.clip()
              
              image.draw(in: frame)
              if _label != nil {
                let s = CGSize(size.width,72)
                let shadow = UIImage.shadowGradient(size: s)
                shadow.draw(in: CGRect(0,size.height-s.height,s.width,s.height))
              }
            }
            mainThread {
              guard let view = _imageView else { return }
              view.buttonActions.set(shadow: .rounded(radius: .margin))
              view.image = image
              if let label = _label {
                label.textColor = .white
              }
            }
          }
        }
      }
    }
    imageView.buttonActions.onTouch {
      self.open()
    }
    return imageView
  }
  
  func open() {
    let page = EventCreatorSelecter(collection: collection)
    main.push(page)
  }
}

/* Отдельная вьюшка для тени. Сейчас тень рисуется прямо в фотке. Можно будет потом использовать, если надо будет добавить динамичность
class ShadowView: UIImageView {
  private static var cimage: UIImage?
  let height: CGFloat = 50
  init(size: CGSize) {
    super.init(frame: CGRect(0,size.height-height,size.width,height))
    let imageHeight = height*screen.retina
    if let image = ShadowView.cimage, image.height == imageHeight {
      self.image = image
    } else {
      let image = UIImage.draw(size: CGSize(1,imageHeight), retina: false) { context in
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var colors = [CGColor]()
        colors.append(UIColor.black(0.0).cgColor)
        colors.append(UIColor.black(0.3).cgColor)
        let locations: [CGFloat] = [0,1]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        context.drawLinearGradient(gradient!, start: Pos(0,10), end: Pos(0,imageHeight), options: [])
      }
      self.image = image
      ShadowView.cimage = image
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
*/
