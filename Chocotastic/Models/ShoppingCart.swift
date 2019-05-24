/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import RxSwift

class ShoppingCart {
  
  fileprivate let chocolates: Variable<[Chocolate]> = Variable([])
  fileprivate let cartItems: Variable<[ChocolateCartItem]> = Variable([])
  fileprivate let disposeBag = DisposeBag()
  
  private init() {
    setupShoppingCartObserver()
  }
  
  static let sharedCart = ShoppingCart()

  func itemCountString() -> String {
    guard chocolates.value.count > 0 else {
      return "🚫🍫"
    }
    
    //Unique the chocolates
    let setOfChocolates = Set<Chocolate>(chocolates.value)
    
    //Check how many of each exists
    let itemStrings: [String] = setOfChocolates.map {
      chocolate in
      let count: Int = chocolates.value.reduce(0) {
        runningTotal, reduceChocolate in
        if chocolate == reduceChocolate {
          return runningTotal + 1
        }
        
        return runningTotal
      }
      
      return "\(chocolate.countryFlagEmoji)🍫: \(count)"
    }
    
    return itemStrings.joined(separator: "\n")
  }
}


fileprivate extension ShoppingCart {
  
  func setupShoppingCartObserver() {
    self.chocolates
      .asObservable()
      .subscribe(onNext: { chocolates in
      
        self.cartItems.value = chocolates
          .reduce(into: [:]) { counts, number in counts[number, default: 0] += 1 }
          .enumerated()
          .map { ChocolateCartItem(chocolate: $0.element.key, quantity: $0.element.value) }
          .sorted { $0.0.quantity > $0.1.quantity }

        print(self.cartItems.value)

      }).addDisposableTo(disposeBag)
  }
}

extension ShoppingCart {
  
  func getCartTotal() -> Float {
    
    return self.cartItems.value.reduce(0.0) { result, chocolateCartItem -> Float in
      let totalCost = (Float(chocolateCartItem.quantity) * chocolateCartItem.chocolate.priceInDollars)
      return result + totalCost
    }
  }
  
  func getChocolates() -> Variable<[Chocolate]> {
    return self.chocolates
  }
  
  func getCartItems() -> Variable<[ChocolateCartItem]> {
    return self.cartItems
  }
  
  func add(_ chocolate: Chocolate) {
    chocolates.value.append(chocolate)
  }
  
  func remove(_ chocolate: Chocolate) {
    for(index, element) in self.chocolates.value.enumerated() {
      if element == chocolate {
        self.chocolates.value.remove(at: index)
        break
      }
    }
  }
  
  func getTotal() -> Int {
    return chocolates.value.count
  }
  
  func totalCost() -> Float {
    return chocolates.value.reduce(0) { $0 + $1.priceInDollars }
  }
  
  func reset() {
    self.chocolates.value = []
  }
}

extension Collection {
  func count(where test: (Element) throws -> Bool) rethrows -> Int {
    return try self.filter(test).count
  }
}
