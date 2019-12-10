//
//  ViewController.swift
//  Workmate
//
//  Created by Profile1 on 8/12/19.
//  Copyright © 2019 Profile1. All rights reserved.
//

import UIKit

enum ViewState : String {
    case ClockIn = "Clock In"
    case ClockOut = "Clock Out"
    case FinishWork = "Finished Work"
}

protocol ProgressViewDelegate {
    func clockedIn()
    func clockedOut()
}

class ViewController: UIViewController, ProgressViewDelegate {
    
    @IBOutlet weak var positionName: UILabel!
    @IBOutlet weak var wageAmount: UILabel!
    @IBOutlet weak var clientName: UILabel!
    @IBOutlet weak var wageType: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var managerName: UILabel!
    @IBOutlet weak var managerPhone: UILabel!
    
    @IBOutlet weak var checkIn: UILabel!
    @IBOutlet weak var checkOut: UILabel!
    
    @IBOutlet weak var action: UIButton!
    
    var state: ViewState = ViewState.ClockIn
    
    var key: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.action.layer.cornerRadius = 0.5 * self.action.bounds.width
        self.action.layer.borderColor = UIColor.lightGray.cgColor
        self.action.layer.borderWidth = 15.0
        
        let (loginRequest, loginData) = RequestFactory.login()
        HTTP.execute(request: loginRequest, data: loginData) { result in
            if result != nil {
                if let error = result as? Error {
                    print(error)
                    return
                }
                if let dictionary = result as? [String: Any] {
                    self.key = dictionary["key"] as! String
                    
                    let staffRequest = RequestFactory.staff(key: self.key!)
                    HTTP.execute(request: staffRequest, data: nil) { result in
                        if result != nil {
                            if let error = result as? Error {
                                print(error)
                                return
                            }
                            if let dictionary = result as? [String: Any] {
                                DispatchQueue.main.async {
                                    self.configureView(dictionary: dictionary)
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let key = self.key {
            var progressController : ProgressViewController = segue.destination as! ProgressViewController
            progressController.delegate = self
            progressController.checkingType = self.state
        }
    }
    
    // MARK: - ProgressViewDelegate
    
    func clockedIn() {
        let (clockinRequest, clockinData) = RequestFactory.clockin(key: self.key!)
        HTTP.execute(request: clockinRequest, data: clockinData) { result in
            if result != nil {
                if let error = result as? Error {
                    print(error)
                    return
                }
                self.state = ViewState.ClockOut
                if let dictionary = result as? [String: Any] {
                    DispatchQueue.main.async {
                        self.checkIn.text = self.timeFromDate(dateString: dictionary["clock_in_time"] as! String)
                        self.action.setTitle(self.state.rawValue, for: .normal)
                    }
                }
            }
        }
    }
    
    func clockedOut() {
        let (clockoutRequest, clockoutData) = RequestFactory.clockout(key: self.key!)
        HTTP.execute(request: clockoutRequest, data: clockoutData) { result in
            if result != nil {
                if let error = result as? Error {
                    print(error)
                    return
                }
                self.state = ViewState.FinishWork
                if let dictionary = result as? [String: Any] {
                    DispatchQueue.main.async {
                        self.checkOut.text = self.timeFromDate(dateString: (dictionary["timesheet"] as! [String: Any])["clock_out_time"] as! String)
                        self.action.isHidden = true
                    }
                }
            }
        }
    }
    
    // MARK: - Private
    
    func configureView(dictionary: [String: Any]) {
        self.positionName.text = (dictionary["position"] as! [String: Any])["name"] as! String
        self.wageAmount.text = "Rp " + (dictionary["wage_amount"] as! String)
        self.clientName.text = (dictionary["client"] as! [String: Any])["name"] as! String
        self.wageType.text = (dictionary["wage_type"] as! String).replacingOccurrences(of: "_", with: " ")
        self.address.text = ((dictionary["location"] as! [String: Any])["address"] as! [String: Any])["street_1"] as! String
        self.managerName.text = (dictionary["manager"] as! [String: Any])["name"] as! String
        self.managerPhone.text = (dictionary["manager"] as! [String: Any])["phone"] as! String
        self.action.setTitle(self.state.rawValue, for: .normal)
    }
    
    func timeFromDate(dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        // Work around since yyyy-MM-dd'T'HH:mm:ssZ was not working for some reason
        let index = dateString.firstIndex(of: ".") ?? dateString.endIndex
        let date = formatter.date(from: String(dateString[..<index]))!
        
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
    
}

