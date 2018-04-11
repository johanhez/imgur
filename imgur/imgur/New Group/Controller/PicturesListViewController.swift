//
//  PicturesListViewController.swift
//  imgur
//
//  Created by Johan Hernandez on 4/10/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import UIKit

class PicturesListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,ApiResponsable {
    
    //MARK: - GLOBAL VARIABLES DECLARATION
    //--------UI Variables--------
    @IBOutlet var pictures_tableview: UITableView!
    //textfields
    @IBOutlet weak var search_textfield: UITextField!
    //buttons
    @IBOutlet weak var search_button: UIButton!
    //--------Business logic variables--------
    var pictures : Array<Picture> = []
    //--------General variables--------
    //views
    var overlay_view = UIView()//Present spinner
    var alert_view = UIView()//Present messages for user
    //Api
    let api_connection = ApiConnection.shared//singleton object
    
    //MARK: - VIEW BEHAVIOR METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        //API
        self.api_connection.setApiResponsable(api_responsable: self)
        //STYLE
        //navigation bar
        self.setHeaderStyle(navigation_bar:self.navigationController!.navigationBar, titulo_personalizado: false)
        //tableview
        let background_view = UIView(frame: CGRect.zero)
        self.pictures_tableview.tableFooterView = background_view
        self.pictures_tableview.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor.white
        //Helper views
        self.overlay_view = self.includeOverlayView(controller: self)
        self.alert_view = self.includeAlertView(controller: self, withLongText: true)
        //tap event to hide keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PicturesListViewController.hideKeyboard))
        self.pictures_tableview.addGestureRecognizer(tap)
        
    }
    
    //MARK: - TABLEVIEW METHODS
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = self.pictures_tableview.dequeueReusableCell(withIdentifier: "picture_cell") as! PictureTableViewCell
        if indexPath.row % 2 == 0 {
            cell.title_label.text = "Can’t describe How happy i am"
            cell.main_picture_imageview.image = #imageLiteral(resourceName: "test_happy")
            cell.date_of_post_label.text = "04 Dec 2018"
            cell.number_of_pics_label.text = "4"
        }
        else {
            cell.title_label.text = "I don’t know why people are so angry about this. I also acknowledge that I am going to get a lot of criticism for posting this."
            cell.main_picture_imageview.image = #imageLiteral(resourceName: "test_fb")
            cell.date_of_post_label.text = "021 Jan 2018"
            cell.number_of_pics_label.text = "3"
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    //MARK: - UI ACTION METHODS
    @IBAction func searchButtonAction(_ sender: Any) {
        
    }
    
    //MARK: - CUSTOM METHODS
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    //acceptAlert is called when the user press the button "Accept" in the alert view
    @objc func acceptAlert() {
        self.showOrHideViewElement(show_action: "hide", element: self.alert_view)
    }
    
    
    //MARK: - API CONNECTION METHODS
    
    //sendApiRequestFinished is called after the app receive a response from the server
    func sendApiRequestFinished(response_array: Dictionary<String, AnyObject>, function_name_to_response: String) {
        print("sendApiRequestFinished")
        if response_array["error"] != nil {
            var mensaje_error = "There was an error obtaining the information. Please try again."
            if let error_message = response_array["error_message"] as? String {
                mensaje_error = error_message
            }
            self.showHideOverview(show_action: "hide", overlay_view: self.overlay_view)
            self.showAlert(alert_view: self.alert_view, alert_message: mensaje_error)
        }
        else {
            switch function_name_to_response {
            case "interpretResponseSearchPictures":
                self.interpretResponseSearchPictures(response_array: response_array)
                break
            default:
                //
                break
            }
        }
    }
    
    //interpretResponseSearchPictures is called after the app receive a response from the server
    //and the response is related to search pictures
    func interpretResponseSearchPictures(response_array : Dictionary<String, AnyObject>){
        print("interpretarRespuestaBuscarEstablecimientos")
        self.showHideOverview(show_action: "hide", overlay_view: self.overlay_view)
        if  let response_code = response_array["response_code"] as? Int,
            var _ = response_array["response"]  as? Dictionary<String, Any>,
            response_code == 200
        {
            
        }
    }
    
    //MARK: - SCAPE METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

