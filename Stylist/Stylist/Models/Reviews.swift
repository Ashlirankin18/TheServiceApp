//
//  Reviews.swift
//  Stylist
//
//  Created by Ashli Rankin on 4/3/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation
struct Reviews {
  let reviewerId:String
  let description:String
  let createdDate:String
  let ratingId:String
  let value:Int

  init(reviewerId:String,description:String,createdDate:String,ratingId:String,value:Int){
    self.reviewerId = reviewerId
    self.description = description
    self.createdDate = createdDate
    self.ratingId = ratingId
    self.value = value
    
  }
  init(dict:[String:Any]) {
    self.reviewerId = dict[ReviewsCollectionKeys.reviewerId] as? String ?? "no reviewer id found"
    self.description = dict[ReviewsCollectionKeys.description] as? String ?? "no description found"
    self.createdDate = dict[ReviewsCollectionKeys.createdDate] as? String ?? "no created date found"
    self.ratingId = dict[RatingsCollectionKeys.ratingId] as? String ?? "no rating id found"
    self.value = dict[RatingsCollectionKeys.value] as? Int ?? 5
  }
}