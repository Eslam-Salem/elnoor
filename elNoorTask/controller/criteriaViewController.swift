//
//  criteriaViewController.swift
//  elNoorTask
//
//  Created by Eslam  on 4/27/19.
//  Copyright © 2019 Eslam. All rights reserved.
//

import UIKit
// as i understanded from google places docs that i can't search for to types at the same request because type paramter take the next value only so i made a picker view to let the user to choose what to search for 
class criteriaViewController: UIViewController {

    @IBOutlet weak var searchType: UIPickerView!
    
    let possibleTypes = ["bank","mosque"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchType.dataSource = self
        searchType.delegate = self
    }
    

    @IBAction func startSearching(_ sender: Any) {
        performSegue(withIdentifier: "startSearching", sender: nil)
    }
}

extension criteriaViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return possibleTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return possibleTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SearchingCriteria.searchingType = possibleTypes[row]
    }
    
}
