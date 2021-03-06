//
//  DBService.swift
//  Stylist
//
//  Created by Ashli Rankin on 4/5/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

final class DBService {
    private init() {}
    public static var firestoreDB: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        return db
    }()
    static public var generateDocumentId: String {
        return firestoreDB.collection(StylistsUserCollectionKeys.stylistUser).document().documentID
    }
    static func CreateServiceProvider(serviceProvider:ServiceSideUser,completionHandler: @escaping (Error?) -> Void){
        firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider).document(serviceProvider.userId).setData([ServiceSideUserCollectionKeys.firstName: serviceProvider.firstName
            ?? "" ,
                                                                                                                        ServiceSideUserCollectionKeys.lastName:serviceProvider.lastName ?? "" ,
                                                                                                                        ServiceSideUserCollectionKeys.bio: serviceProvider.bio ?? "" , ServiceSideUserCollectionKeys.email:serviceProvider.email, ServiceSideUserCollectionKeys.gender: serviceProvider.gender ?? "" ,ServiceSideUserCollectionKeys.imageURL:serviceProvider.imageURL ?? "" , ServiceSideUserCollectionKeys.joinedDate:serviceProvider.joinedDate, ServiceSideUserCollectionKeys.licenseExpiryDate:serviceProvider.licenseExpiryDate ?? "" , ServiceSideUserCollectionKeys.licenseNumber:serviceProvider.licenseNumber ?? "" , ServiceSideUserCollectionKeys.isCertified : serviceProvider.isCertified, ServiceSideUserCollectionKeys.userId: serviceProvider.userId ]) { (error) in
                                                                                                                            if let error = error {
                                                                                                                                print("there was an error:\(error.localizedDescription)")
                                                                                                                            }
                                                                                                                            print("database user sucessfully created")
        }
    }
    static func createConsumerDatabaseAccount(consumer: StylistsUser,completionHandler: @escaping (Error?) -> Void ){
        
        firestoreDB.collection(StylistsUserCollectionKeys.stylistUser)
            .document(consumer.userId)
            .setData([StylistsUserCollectionKeys.userId : consumer.userId, StylistsUserCollectionKeys.firstName: consumer.firstName ?? "",
                StylistsUserCollectionKeys.lastName:consumer.lastName ?? "" ,
                StylistsUserCollectionKeys.email : consumer.email,
                StylistsUserCollectionKeys.gender: consumer.gender ?? "",
                StylistsUserCollectionKeys.imageURL: consumer.imageURL ?? "",
                StylistsUserCollectionKeys.joinedDate: Date.getISOTimestamp(),
                StylistsUserCollectionKeys.state : consumer.state ?? "",
                StylistsUserCollectionKeys.street : consumer.street ?? ""
            ]) { (error) in
                    if let error = error {
                        completionHandler(error)
                    } else {
                        completionHandler(nil)
                }
        }
    }
    
    
    static func getDatabaseUser(userID: String, completionHandler: @escaping (Error?,StylistsUser?)-> Void){
        firestoreDB.collection(StylistsUserCollectionKeys.stylistUser)
            .whereField(StylistsUserCollectionKeys.userId, isEqualTo: userID)
            .getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    completionHandler(error, nil)
                } else if let snapshot = snapshot?.documents.first {
                    let stylistUser = StylistsUser(dict: snapshot.data())
                    completionHandler(nil, stylistUser)
                }
            })
    }
    
    
    static func rateUser(collectionName:String,userId:String,rating:Ratings){
        let id = firestoreDB.collection(collectionName).document().documentID
        DBService.firestoreDB.collection(collectionName).document(userId).collection(RatingsCollectionKeys.ratings).addDocument(data: [RatingsCollectionKeys.ratingId:id,
                                                                                                                                       RatingsCollectionKeys.value:rating.value,RatingsCollectionKeys.userId:rating.userId,RatingsCollectionKeys.ratingId:userId]) { (error) in
                                                                                                                                        if let error = error {
                                                                                                                                            print("there was an error: uploading your rating:\(error.localizedDescription)")
                                                                                                                                        }
        }
    }
    
    static func getProviders(completionHandler: @escaping([ServiceSideUser]?, Error?) -> Void) {
        DBService.firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completionHandler(nil, error)
                } else if let snapshot = snapshot {
                    completionHandler(snapshot.documents.map{ServiceSideUser(dict: $0.data())}, nil)
                }
        }
    }
    
    static func getProvider(consumer: StylistsUser, completion: @escaping(Error?, ServiceSideUser?) -> Void) {
        DBService.firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider)
          .document(consumer.userId).addSnapshotListener({ (snapshot, error) in
            if let error = error  {
              completion(error, nil)
            }else if let snapshot = snapshot {
              guard snapshot.data() != nil else{
                setupProviderCredentials(user: consumer)
                return
              }
              guard let providerData = snapshot.data() else {return}
              let provider = ServiceSideUser(dict:providerData)
              completion(nil, provider)
            }
          })
      
    }
    
    static func getProviderFromAppointment(appointment: Appointments, completion: @escaping(Error?, ServiceSideUser?) -> Void) {
        DBService.firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider)
            .document(appointment.providerId).addSnapshotListener { (snapshot, error) in
                if let error = error {
                    completion(error, nil)
                } else if let snapshot = snapshot {
                    guard let data = snapshot.data() else { return }
                    completion(nil, ServiceSideUser(dict: data))
                }
        }
    }
    
  static func setupProviderCredentials(user:StylistsUser){
    let providerInfo:[String:Any] = [ServiceSideUserCollectionKeys.userId:user.userId,
                        ServiceSideUserCollectionKeys.firstName: user.firstName ?? "no first name found",
                        ServiceSideUserCollectionKeys.lastName:user.lastName ?? "no last name found",
                        ServiceSideUserCollectionKeys.imageURL:user.imageURL ?? "no image url found"]
DBService.firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider).document(user.userId).setData(providerInfo, completion: { (error) in
      if let error = error {
        print("there was an error: \(error.localizedDescription)")
      }
      return
    })
    
  }
    static func postProviderRating(ratings: Ratings, completionHandler: @escaping (Error?) -> Void) {
        
        let rateId = firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider)
            .document(ratings.userId)
            .collection(RatingsCollectionKeys.ratings).document().documentID
        
        
        firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider)
            .document(ratings.userId)
            .collection(RatingsCollectionKeys.ratings)
            .document().setData([
                RatingsCollectionKeys.ratingId : rateId,
                RatingsCollectionKeys.value: ratings.value,
                RatingsCollectionKeys.raterId: ratings.raterId,
                RatingsCollectionKeys.userId: ratings.userId
                
            ]) { (error) in
                if let error = error {
                    completionHandler(error)
                    print("there was an error with the postProviderRating: \(error.localizedDescription)")
                } else {
                    completionHandler(nil)
                    print("rating posted successfully to reference: \(ratings.ratingId)")
                }
        }
    }
    static func postProviderReview(reviewer: StylistsUser ,stylistReviewed: ServiceSideUser?, review: Reviews, completionHandler: @escaping (Error?) -> Void) {
        let reviewId = firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider)
            .document(stylistReviewed?.userId ?? "no document id found")
            .collection(ReviewsCollectionKeys.reviews).document().documentID
        let date =
        firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider)
            .document(stylistReviewed?.userId ?? "no provider ID Found")
            .collection(ReviewsCollectionKeys.reviews)
            .document().setData([
                ReviewsCollectionKeys.reviewerId  : reviewer.userId,
                ReviewsCollectionKeys.createdDate : Date.getISOTimestamp(),
                ReviewsCollectionKeys.description : review.description,
                ReviewsCollectionKeys.ratingId : review.ratingId,
                ReviewsCollectionKeys.value : review.value,
                ReviewsCollectionKeys.reviewId : reviewId,
                ReviewsCollectionKeys.reviewStylist : review.reviewStylist
            ]) { (error) in
                if let error = error {
                    completionHandler(error)
                    print("there was an error with the postProviderReview: \(error.localizedDescription)")
                } else {
                    completionHandler(nil)
                    print("review posted successfully to  reference: \(review.reviewId)")
                }
        }
    }
    
    static func getServices(completionHandler: @escaping ([Service]?, Error?) -> Void) {
        firestoreDB.collection("stockServices")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completionHandler(nil, error)
                } else {
                    let services = snapshot?.documents.map { Service(dict: $0.data()) }
                    completionHandler(services, nil)
                }
        }
    }
    
    static func addToFavorites(id: String,prodider: ServiceSideUser, documentID: String, completionHandler: @escaping(Error?) -> Void) {
        if prodider.favoriteId == documentID {
            return
        }
        firestoreDB.collection(StylistsUserCollectionKeys.stylistUser)
            .document(id)
            .collection("userFavorites")
            .document(documentID).setData(["userId" : prodider.userId,
                                           "createdAt" : Date.getISOTimestamp(),
                                           StylistsUserCollectionKeys.imageURL: prodider.imageURL ?? "",
                                           ServiceSideUserCollectionKeys.firstName: prodider.firstName
                                            ?? "" ,
                                           ServiceSideUserCollectionKeys.lastName:prodider.lastName ?? "" ,
                                           ServiceSideUserCollectionKeys.bio: prodider.bio ?? "" ,
                                           "jobTitle": prodider.jobTitle,
                                           ServiceSideUserCollectionKeys.favoriteId : documentID
                
            ]) { (error) in
                if let error = error {
                    completionHandler(error)
                } else {
                    completionHandler(nil)
                }
        }
    }
    
    static func removeFromFavorites(id: String,favoirteId: String, provider: ServiceSideUser, completionHandler: @escaping(Error?, Bool) -> Void) {
        
        firestoreDB.collection(StylistsUserCollectionKeys.stylistUser)
            .document(id)
            .collection("userFavorites")
            .document(favoirteId)
            .delete { (error) in
                if let error = error {
                    completionHandler(error, false)
                } else  {
                    completionHandler(nil, true)
                }
        }
    }
    
    static func getFavorites(id: String, completionHandler: @escaping([ServiceSideUser]?, Error?) -> Void) {
        firestoreDB.collection(StylistsUserCollectionKeys.stylistUser)
            .document(id)
            .collection("userFavorites")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completionHandler(nil, error)
                } else {
                    completionHandler(snapshot?.documents.map{ServiceSideUser(dict:$0.data())}, nil)
                }
        }
    }
    
    static func createUserWallet(userId:String,information:[String:Any],documentId:String,completionHandler: @escaping(Error?) -> Void) {
    firestoreDB.collection(StylistsUserCollectionKeys.stylistUser).document(userId).collection("wallet").document(documentId).setData(information) { (error) in
            if let error = error {
                completionHandler(error)
            }
            print("sucessfully added to your wallet")
            
        }
    }
    

    // MARKS: Provider Services
    static func getReviews(provider: ServiceSideUser, completionHandler: @escaping([Reviews]?, Error?) -> Void) {
        DBService.firestoreDB.collection("serviceProvider")
            .document(provider.userId)
            .collection("reviews")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completionHandler(nil, error)
                } else if let snapshot = snapshot {
                    let reviewData = snapshot.documents.map{
                        Reviews(dict: $0.data())
                    }
                    completionHandler(reviewData,nil)
                }
        }
    }
    
    
  static func getBookedAppointments(userId: String, completion: @escaping(Error?, [Appointments]?) -> Void) {
        DBService.firestoreDB.collection(AppointmentCollectionKeys.bookedAppointments)
            .whereField("userId", isEqualTo: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting booked appointments: " + error.localizedDescription)
                    completion(error, nil)
                } else if let snapshot = snapshot {
                    completion(nil, snapshot.documents.map({Appointments(dict: $0.data())}))
                }
        }
  
    }

    static func getAppointments(completionHandler: @escaping ([Appointments]?, Error?) -> Void) {
        DBService.firestoreDB.collection("bookedAppointments")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completionHandler(nil, error)
                } else {
                    let appointments = snapshot?.documents.map { Appointments(dict: $0.data()) }
                    completionHandler(appointments, nil)
                }
        }
    }
    
    static func cancelPastBookedAppointments(appointments: [Appointments]) {
        for appointment in appointments {
            let appointmentTimeFormatter = DateFormatter()
            appointmentTimeFormatter.dateFormat = "EEEE, MMM d, yyyy h:mm a"
            guard let appointmentDate = appointmentTimeFormatter.date(from: appointment.appointmentTime) else { return }
            let currentDate = Date()
            if currentDate > appointmentDate {
                updateAppointment(appointmentID: appointment.documentId, status: "canceled")
            }
        }
    }
    
    static func updateAppointment(appointmentID: String, status: String) {
        DBService.firestoreDB.collection("bookedAppointments")
        .document(appointmentID)
        .updateData(["status" : status])
    }
  
static func getProviderServices(providerId:String,completion: @escaping (Error?,[ProviderServices]?) -> Void){
    var serviceArray = [ProviderServices]()
    
DBService.firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider).document(providerId).collection(ServicesCollectionKeys.subCollectionName).getDocuments { (snapshot, error) in
      if let error = error {
        completion(error,nil)
      }
      else if let snapshot = snapshot{
        snapshot.documents.forEach{
          let serviceData = ProviderServices(dict: $0.data())
          serviceArray.append(serviceData)
          completion(nil,serviceArray)
        }
      }
    }

  }
  static func getPortfolioImages(providerId:String,completion: @escaping (Error?,PortfolioImages?) -> Void ){
DBService.firestoreDB.collection(ServiceSideUserCollectionKeys.serviceProvider).document(providerId).collection(PortfolioCollectionKeys.portfolio).getDocuments { (snapshot, error) in
      if let error = error {
        completion(error,nil)
      }else if let snapshot = snapshot {
        guard let porfolioData = snapshot.documents.first?.data() else {return}
        let portfolio = PortfolioImages(dict: porfolioData)
        completion(nil,portfolio)
      }
    }
  }
}



