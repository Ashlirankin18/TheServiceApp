//
//  ServiceUpcomingTableViewController.swift
//  Stylist
//
//  Created by Ashli Rankin on 4/5/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit
import Kingfisher

class ServiceUpcomingTableViewController: UITableViewController {
    var authservice = AuthService()
    var providerId = ""{
        didSet{
            getAppointmentInfo(serviceProviderId: providerId)
        }
    }
    var appointments = [Appointments]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getAppointments()
      setupTableview()
    }
    
    private func   getAppointments() {
        DBService.getAppointments { (appointments, error) in
            if let error = error {
                print(error)
            } else if let appointments = appointments {
                for appointment in appointments {
                self.getAppointmentInfo(serviceProviderId: appointment.providerId)
                }
            }
        }
    }
    
    private func getAppointmentInfo(serviceProviderId:String) {
        guard let currentUser = authservice.getCurrentUser() else {
            showAlert(title: "Error", message: "No user signedIn", actionTitle: "TryAgain")
            return
        }
        DBService.firestoreDB.collection("bookedAppointments")
            .whereField("providerId", isEqualTo: providerId).whereField("userId", isEqualTo: currentUser.uid).getDocuments { [weak self] (snapshot, error) in
                
                if let error = error {
                    
                    self?.showAlert(title: "Error", message: "Could not retrieve appointments:\(error.localizedDescription)", actionTitle: "Try Again")
                }
                else if let snapshot = snapshot {
                    let appointments =  snapshot.documents.map{Appointments(dict: $0.data()) }
                    self?.appointments = appointments
                }
        }
    }

    private func setupTableview() {
        tableView.tableFooterView = UIView()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
              return appointments.count
        } else  {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenAppointments", for: indexPath) as! AppointmentCell
//        let appointment = appointments[indexPath.row]
//        DBService.getAppointmentImage(userID: appointment.userId) { (user, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else if let user = user {
//                cell.AppointmentImage.kf.setImage(with: URL(string: user.imageURL ?? "no image"), placeholder: #imageLiteral(resourceName: "placeholder.png"))
//            }
//        }
      
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }

}
