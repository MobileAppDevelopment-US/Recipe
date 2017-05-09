//
//  RecipeViewController.swift
//  Recipe
//
//  Created by User on 04.05.17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import Alamofire
//When scrolling down, the data is updated from the server,
//When clicking on a cell, go to the site with a recipe
//When you click on Cancel - the default data

class RecipeViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var arrayDictionaries = NSArray()
    let url = "http://www.recipepuppy.com/api/?i=onions,garlic&q=omelet&p=3"
    let urlImage = "http://lorempixel.com/400/200/food/"
    var cellModelsArray = [DataModel]()
    let userDefaults = UserDefaults.standard
    var refresh = UIRefreshControl()
    var art: DataModel?
    var searchURL = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.arrayDictionaries.count > 0 {
            dataFromLocal()
        } else {
            loadData()
        }
        self.refresh = UIRefreshControl()
        self.refresh.attributedTitle = NSAttributedString(string: "UpgateData".localized)
        self.refresh.addTarget(self, action: #selector(actionRefresh), for: .valueChanged)
        self.tableView.refreshControl = refresh
        self.tableView.addSubview(refresh)
        self.navigationItem.title = "Title".localized
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchWord = self.searchBar.text!
        let finalSearchWord = searchWord.replacingOccurrences(of: " ", with: "+")
        self.searchURL = "http://www.recipepuppy.com/api/?q=\(finalSearchWord)"
        searchData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        loadData()
    }
    
    func dataFromLocal() {
        self.arrayDictionaries = (self.userDefaults.object(forKey: "arrayDictionaries") as! [DataModel] as NSArray)
        createModels()
        self.tableView.reloadData()
        showAlert(withMessage: "UseDataLocalDatabase".localized, andTitle: "Attention".localized)
    }
    
    func loadData() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            Alamofire.request(self.url).responseJSON {
                response in
                if let result = response.result.value {
                    let dictJSON = result as! NSDictionary
                    if (dictJSON.count > 0) {
                        self.arrayDictionaries = dictJSON.object(forKey: "results") as! NSArray
                        self.saveDataLocal()
                        self.createModels()
                        self.refresh.endRefreshing()
                        self.tableView.reloadData()
                    } else {
                        self.showAlert(withMessage: "ListEmpty".localized,
                                       andTitle: "Attention".localized)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func searchData() {
        Alamofire.request(self.searchURL).responseJSON {
            response in
            if let result = response.result.value {
                let dictJSON = result as! NSDictionary
                if (dictJSON.count > 0) {
                    self.arrayDictionaries = dictJSON.object(forKey: "results") as! NSArray
                    self.createModels()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func createModels() {
        self.cellModelsArray = []
        for dict in self.arrayDictionaries {
            let cellModel = DataModel(withDictionary: dict as! NSDictionary)
            self.cellModelsArray.append(cellModel)
        }
    }
    
    //MARK: - Action
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.art = cellModelsArray[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "siteGo") as! InfoController
        controller.article = art?.urlSite
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func actionRefresh(_ sender: UIRefreshControl) {
        loadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellModelsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.titleLabel.text = cellModelsArray[indexPath.row].title
        cell.ingredientsLabel.text = cellModelsArray[indexPath.row].ingredients
        if cellModelsArray[indexPath.row].image != "" {
            cell.myImageView.downloadImage(from: cellModelsArray[indexPath.row].image)
        } else {
            cell.myImageView.downloadImage(from: self.urlImage)
        }
        cell.myImageView.layer.cornerRadius = cell.myImageView.frame.size.height/2
        return cell
    }
    
    func showAlert(withMessage message: String, andTitle title: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertActionStyle.`default`,
                                      handler: nil))
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func saveDataLocal() {
        self.userDefaults.set(self.arrayDictionaries, forKey: "arrayDictionaries")
    }
    
}

extension UIImageView {
    func downloadImage(from url: String) -> Void {
        let urlRequest = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            if error != nil {
                print(error ?? "Error")
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
    
}
