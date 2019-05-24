//
//  ChocolateCartCell.swift
//  Chocotastic
//
//  Created by Tunde on 17/05/2019.
//  Copyright © 2019 RayWenderlich.com. All rights reserved.
//

import UIKit
import RxSwift

class ChocolateCartCell: UITableViewCell {
  
  static let identifier = "ChocolateCartCell"
  private let disposeBag = DisposeBag()
  private var cartItem: ChocolateCartItem?
  
  @IBOutlet weak var titleLbl: UILabel!
  
  func configure(with chocolateCartItem: ChocolateCartItem) {
    self.cartItem = chocolateCartItem
    ShoppingCart.sharedCart
      .getCartItems()
      .asObservable()
      .subscribe(onNext: { [weak self] chocolateCartItems in
        guard let `self` = self else { return }
        self.titleLbl.text = "\(chocolateCartItem.chocolate.countryFlagEmoji)🍫: \(ShoppingCart.sharedCart.getChocolates().value.filter { $0 == chocolateCartItem.chocolate }.count)"
      }).addDisposableTo(disposeBag)
  }
  
  @IBAction func addDidTouch(_ sender: Any) {
    guard let cartItem = cartItem else { return }
    ShoppingCart.sharedCart.add(cartItem.chocolate)
  }
  
  @IBAction func removeDidTouch(_ sender: Any) {
    guard let cartItem = cartItem else { return }
    ShoppingCart.sharedCart.remove(cartItem.chocolate)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cartItem = nil
  }
}
