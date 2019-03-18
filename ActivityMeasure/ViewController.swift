//
//  ViewController.swift
//  ActivityMeasure
//
//  Created by Marcus Thuvesen on 2019-03-15.
//  Copyright © 2019 Marcus Thuvesen. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var isDeviceMotionOn = false
    var accelerationArray : [Double] = []
    var averageArray : [Double] = [0]
    let motionManager = CMMotionManager()
    var currentNode = 0
    var acceleration : Double = 0
    var timeInterval : Double = 20
    var batchNumbersArray = [Double]()
    var percentage = 0
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var healthContainer: UIView!
    @IBOutlet weak var healthView: UIView!
    @IBOutlet weak var startBtnOutlet: UIButton!
    @IBOutlet weak var restartBtnOutlet: UIButton!
    @IBOutlet weak var healthConstraintToTop: NSLayoutConstraint!
    @IBOutlet weak var percentageLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        healthContainer.layer.cornerRadius = 15
        healthView.layer.cornerRadius = 15
        startBtnOutlet.layer.cornerRadius = startBtnOutlet.frame.height/2
        restartBtnOutlet.layer.cornerRadius = restartBtnOutlet.frame.height/2
        
    }
    
    func startAccelerometer(){
        
        motionManager.deviceMotionUpdateInterval = 1/self.timeInterval //How many nodes per second?(Hertz)
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            if let motion = motion{
                
                var x = motion.userAcceleration.x
                var y = motion.userAcceleration.y
                var z = motion.userAcceleration.z
                
                //All positive numbers
                x = abs(x)
                y = abs(y)
                z = abs(z)
                
                //Detects Movement in all Chanels
                self.acceleration = round((x+y+z) * 100) / 100
                
                
                let gravity = motion.gravity
                let rotation = atan2(gravity.x, gravity.y) + .pi
                //            print("X + \(gravity.x)")
                //            print("Y + \(gravity.y)")
                //            print("Z + \(gravity.z)")
                let roundedGravityX = round(gravity.x * 100) / 100
                let roundedGravityY = round(gravity.y * 100) / 100
                let roundedGravityZ = round(gravity.z * 100) / 100
                OperationQueue.main.addOperation {
                    
                    if abs(gravity.z) > 0.87 && (abs(motion.userAcceleration.x) > 0.7 || abs(motion.userAcceleration.y) > 0.7) {
                        self.cheatingDetected(str : "FUSK1")
                    }
                        
                    else if abs(gravity.x) > 0.5 && (abs(motion.userAcceleration.z) > 0.7 || abs(motion.userAcceleration.y) > 0.7) {
                        self.cheatingDetected(str : "FUSK2")
                    }
                        
                    else if abs(gravity.y) > 0.5 && (abs(motion.userAcceleration.x) > 0.7 || abs(motion.userAcceleration.z) > 0.7) {
                        self.cheatingDetected(str : "FUSK3")
                    }
                    else{
                        
                        self.view.backgroundColor = .black
                        
                        if percentage > 50{
                            self.healthView.backgroundColor = .green
                        }
                        self.accelerationArray.append(self.acceleration)
                        
                        // Add Values to Array
                        self.batchNumbersArray.append(self.accelerationArray[self.currentNode])
                        
                        // The Latest Node Number
                        self.currentNode += 1
                        
                        // Every Second
                        if self.currentNode % Int(self.timeInterval) == 0 {
                            print("20")
                            self.calculateActivityFactor(activityArray: self.batchNumbersArray)
                            // kalla på funktion; (räkna ihop alla värden, medelvärdet (hastighet))
                            
                            // Töm arrayen
                            self.batchNumbersArray.removeAll()
                            
                        }
                    }
                    
                }
            }
        }
    }
    
    func cheatingDetected(str : String){
        print(str)
        self.view.backgroundColor = .red
        topLabel.text = "Fusk!"
        
    }
    
    // Function for users speed
    func calculateActivityFactor(activityArray : Array<Double>) {
        
        // Calculate sum of array
        
        let activitySum = activityArray.reduce(0) { $0 + $1 }
        
        // Get the speed of activity by dividing sum of values with nodes/.count
        let activityFactor = activitySum / Double(activityArray.count)
        if activityFactor > 0.4{
            activityFilter(activityFactor: Double(activityFactor))
        }
    }
    
    func activityFilter(activityFactor : Double){
        if activityFactor < 2 {
            print("ActivityFactor: \(activityFactor)")
            topLabel.text = "Godkänt!"
            if self.healthConstraintToTop.constant != 0{
                self.healthConstraintToTop.constant -= CGFloat(20)
                UIView.animate(withDuration: 1) {
                    self.view.layoutIfNeeded()
                }
                
                let percentage =  Int(100 - (self.healthConstraintToTop.constant / 4))
                self.percentageLabel.text = "\(percentage)%"
                
            }
           
        }
    }
    
    @IBAction func startBtn(_ sender: Any) {
        if motionManager.isDeviceMotionAvailable{
            if isDeviceMotionOn == false{
                isDeviceMotionOn = true
                startAccelerometer()
                startBtnOutlet.setTitle("Stoppa", for: .normal)
            }
            else{
                isDeviceMotionOn = false
                motionManager.stopDeviceMotionUpdates()
                startBtnOutlet.setTitle("Starta", for: .normal)
            }
        }
    }
    
    @IBAction func restartBtn(_ sender: UIButton) {
        if motionManager.isDeviceMotionAvailable{
            motionManager.stopDeviceMotionUpdates()
            accelerationArray.removeAll()
            averageArray.removeAll()
            batchNumbersArray.removeAll()
            reloadInputViews()
            startBtnOutlet.setTitle("Stoppa", for: .normal)
            motionManager.startDeviceMotionUpdates()
            startAccelerometer()
            isDeviceMotionOn = true
            currentNode = 0
            percentage = 0
            percentageLabel.text = "\(percentage)%"
            self.healthConstraintToTop.constant = 400
            self.healthView.backgroundColor = .red
            UIView.animate(withDuration: 1) {
               self.view.layoutIfNeeded()
            }
            
        }
        
    }
    
}

