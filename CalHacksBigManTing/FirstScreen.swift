//
//  ViewController.swift
//  CalHacksBigManTing
//
//  Created by Yevgeniy Vasylenko on 10/7/17.
//  Copyright © 2017 Jack Vasylenko. All rights reserved.
//

import UIKit

class FirstScreen: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var stockNames = ["AAPL", "AMZN", "GOOGL", "NFLX", "ORCL", "IBM", "AMD", "INTC", "CMCSA", "GPRO", "FB", "ADBE", "MSFT", "TWTR", "TSLA", "SNAP", "PYPL", "ORCL", "WMT", "COST", "GM", "FB", "YELP", "BIDU", "SQ"].sorted()
    var picked = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stockNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stockNames[row]
    }
    

    @IBOutlet weak var picker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        picked = row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! GraphScreen
        dest.stck = stockNames[picked]
    }


}

