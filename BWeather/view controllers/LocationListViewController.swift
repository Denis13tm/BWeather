//
//  ViewController.swift
//  BWeather
//
//Created by Otabek Tuychiev

import UIKit

class LocationListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarBtn: UIBarButtonItem!
    @IBOutlet weak var editBarBtn: UIBarButtonItem!
    
    
    var weatherLocations: [WLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    //MARK: - Methods
    
    func initView() {
        let weatherLocation = WLocation(name: "Buenos Airos, Argentina", latitude: 0, longtitude: 0)
        weatherLocations.append(weatherLocation)
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func editBtnPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addBarBtn.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarBtn.isEnabled = false
        }
    }
    
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
    }
    

}


extension LocationListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = weatherLocations[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            weatherLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = weatherLocations[sourceIndexPath.row]
        weatherLocations.remove(at: sourceIndexPath.row)
        weatherLocations.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    
}
