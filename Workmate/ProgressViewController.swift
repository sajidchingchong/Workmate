//
//  ProgressViewController.swift
//  Workmate
//
//  Created by Profile1 on 8/12/19.
//  Copyright © 2019 Profile1. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {

    var delegate: ProgressViewDelegate?
    
    @IBOutlet weak var checking: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var checkingType: ViewState?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        checking.text = checkingType == ViewState.ClockIn ? "Checking In ..." : "Checking Out ..."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressView.progress = 1.0
        UIView.animate(withDuration: 10, animations: {
                self.progressView.layoutIfNeeded()
            }) { (completed) in
                if (completed) {
                    self.dismiss(animated: true, completion: {
                        if (self.checkingType == ViewState.ClockIn) {
                            self.delegate?.clockedIn()
                        } else {
                            self.delegate?.clockedOut()
                        }
                    })
                 }
            }
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
