//
//  InfoController.swift
//  Recipe
//
//  Created by User on 05.05.17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

class InfoController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var cellInfoModel: RecipeViewController?
    var article: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        self.webView.loadRequest(URLRequest(url: URL(string: self.article)!))
        self.view.reloadInputViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func load(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            guard let urlRequest = URLRequest(url: URL(string: self.article)!) as URLRequest? else {
                print("An URL of the image is empty")
                return
            }
            let task = URLSession.shared.dataTask(with: urlRequest) {
                (data, response, error) in
                if error != nil {
                    print(error ?? "Can't download an image")
                    return
                }
            }
            task.resume()
        }
    }
    
}
