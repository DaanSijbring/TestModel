//
//  ViewController.swift
//  ModelTest
//
//  Created by D. Sijbring on 23/02/2018.
//  Copyright © 2018 D. Sijbring. All rights reserved.

// ALL TUNABLE PARAMETERS.
// --------------ACT-R-------------
// retrieval threshold, baselevel decay, activation noise, latency factor\
// --------------MODEL-------------
// responseTime, addToDMTime, checkDMTime, attendModel, attendTarget
//

import UIKit

class ViewController: UIViewController {
    

    var timer: Timer? = nil
    
    
    lazy var game = Dobble()
    lazy var model = TestModel(game: game)
    
    let steps = 10
    let rtRange = [0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0]
    let responseTimeRange = [0.2, 0.4, 0.6, 0.8, 1.0, 1.2]
    let addToDMTimeRange = [0.05, 0.1, 0.15, 0.2]
    let checkDMTimeRange = [0.05, 0.1, 0.15, 0.2]
    
    
    
    let attendModelRange = [1, 2, 3, 4, 5, 6, 7, 8]
    let attendTargetRange = [1, 2, 3, 4, 5, 6, 7, 8]

    

    override func viewDidLoad() {
        super.viewDidLoad()
        model.reset()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
   
    
    
    @IBAction func addToModel() {
        
        model.run()
        print(model.foundTime)
        ///model.reset()
    }
    
    
    @IBAction func printFromModel() {
        let fileName = "Times.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        let total = rtRange.count * responseTimeRange.count * addToDMTimeRange.count * checkDMTimeRange.count
        
        var csvText = "Reaction Times \n"
        for rt in rtRange {
            var counter = 0
            var percentage: Double = 0
            model.dm.retrievalThreshold = rt
            for responseTime in responseTimeRange {
                model.responseTime = responseTime
                for addToDMTime in addToDMTimeRange {
                    model.addToDMTime = addToDMTime
                    for checkDMTime in checkDMTimeRange {
                        model.checkDMTime = checkDMTime
                        counter += 1
                        percentage = Double(counter)/Double(total)
                        print("\(percentage)%")
                        csvText.append("100 reaction times for the following parameters:;Retrieval Threshold;\(rt);Response Time;\(responseTime);addToDMTime;\(addToDMTime);checkDMTime;\(checkDMTime)\n")
                        /// -----100 RT creation ----
                        for _ in 1...20 {
                            for _ in 1...5 {
                                model.run()
                                let newLine = String(model.foundTime) + ";"
                                csvText.append(newLine)
                                
                            }
                            model.reset()
                            csvText.append("\n")
                        }
                        /// -------------------------
                    }
                }
            }
                
                
        }
        

        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    
    @IBAction func resetModel() {
        model.reset()
    }
    
    



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

