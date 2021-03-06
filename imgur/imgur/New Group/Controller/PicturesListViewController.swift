//
//  PicturesListViewController.swift
//  imgur
//
//  Created by Johan Hernandez on 4/10/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import UIKit

class PicturesListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,ApiResponsable, UITextFieldDelegate {
    
    //MARK: - GLOBAL VARIABLES DECLARATION
    //--------UI Variables--------
    @IBOutlet var pictures_tableview: UITableView!
    //textfields
    @IBOutlet weak var search_textfield: UITextField!
    //buttons
    @IBOutlet weak var search_button: UIButton!
    //Switches
    @IBOutlet weak var even_results_switch: UISwitch!
    
    //--------Business logic variables--------
    var picture_collection : PictureCollection = PictureCollection()
    //--------General variables--------
    var api_routing : NSDictionary!
    var api_page : Int = 1
    //views
    var overlay_view = UIView()//Present spinner
    var alert_view = UIView()//Present messages for user
    var cellHeightDictionary: NSMutableDictionary = NSMutableDictionary()
    //Api
    let api_connection = ApiConnection.shared//singleton object
    
    
    //MARK: - VIEW BEHAVIOR METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        //API
        self.api_connection.setApiResponsable(api_responsable: self)
        self.api_routing = Bundle.main.object(forInfoDictionaryKey: "ApiRouting") as! NSDictionary
        //STYLE
        //navigation bar
        self.setHeaderStyle(navigation_bar:self.navigationController!.navigationBar, title_for_vc: false)
        //tableview
        let background_view = UIView(frame: CGRect.zero)
        self.pictures_tableview.tableFooterView = background_view
        self.pictures_tableview.backgroundColor = UIColor.clear
        
        self.pictures_tableview.rowHeight = UITableViewAutomaticDimension
        self.pictures_tableview.estimatedRowHeight = 488
        cellHeightDictionary = NSMutableDictionary()
        
        //Helper views
        self.overlay_view = self.includeOverlayView(controller: self)
        self.alert_view = self.includeAlertView(controller: self, withLongText: true)
        //tap event to hide keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PicturesListViewController.hideKeyboard))
        self.pictures_tableview.addGestureRecognizer(tap)
        
        //turn of filtering toggle
        self.even_results_switch.setOn(false, animated: false)
        
    }
    
    //MARK: - TABLEVIEW METHODS
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.picture_collection.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = self.pictures_tableview.dequeueReusableCell(withIdentifier: "picture_cell") as! PictureTableViewCell
        //get picture object to render
        let picture : Picture = self.picture_collection.getElementAtIndex(index : indexPath.row)
        
        //get title for cell
        var cell_title_label = ""
        if picture.title != "" {
            cell_title_label = picture.title!
        }
        cell.title_label.text = cell_title_label
        
        //get date of post for cell
        var cell_date_of_post_label = ""
        if picture.post_date != nil {
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"
            cell_date_of_post_label = dayTimePeriodFormatter.string(from: picture.post_date! as Date)
        }
        cell.date_of_post_label.text = cell_date_of_post_label
        
        //get number of images
        var cell_number_of_pics_label = "1"
        if let number_images = picture.number_images {
            cell_number_of_pics_label = String(number_images)
        }
        cell.number_of_pics_label.text = cell_number_of_pics_label
        
        //get image
        cell.main_picture_imageview.image = #imageLiteral(resourceName: "loading_bg")
        cell.image_activity_indicator.startAnimating()
        //If picture was already downloaded, the image is obtaied from the object to avoid downloading again
        if picture.post_picture != nil{
            //The picture has not been downloaded
            print("Picture was downloaded previously for row \(indexPath.row)")
            cell.main_picture_imageview.image = picture.post_picture!
            cell.image_activity_indicator.stopAnimating()
        }
        else{
            //The picture has not been downloaded
            let current_index_path = indexPath//required to know which picture is being downloaded
            if  let image_url = picture.image_url,
                let url = URL(string: image_url) {
                //downloading image
                getDataFromUrl(url: url) { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    DispatchQueue.main.async() {
                        picture.post_picture = UIImage(data: data)
                        if let cell_to_update = self.pictures_tableview.cellForRow(at: current_index_path) as? PictureTableViewCell {
                            cell_to_update.main_picture_imageview.image = UIImage(data: data)
                            cell_to_update.image_activity_indicator.stopAnimating()
                        }
                    }
                }
            }
        }
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    //Include pagination and reload list
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDecelerating")
        let scrollview_origin_y = scrollView.contentOffset.y
        let end_scrolling = scrollview_origin_y + scrollView.frame.size.height
        if scrollview_origin_y>0 && end_scrolling >= (scrollView.contentSize.height+100){
            print("load next page")
            //if the user pull the scroll up
            self.api_page += 1
            self.searchPictures()
        }
        else if scrollview_origin_y <= -100{
            print("reload search")
            //when the user pull the scroll down reload info from the beginning
            self.api_page = 1
            self.picture_collection.clearCollection()
            self.pictures_tableview.reloadData()
            self.searchPictures()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeightDictionary.setObject(cell.frame.size.height, forKey: indexPath as NSCopying)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if cellHeightDictionary.object(forKey: indexPath) != nil {
            let height = cellHeightDictionary.object(forKey: indexPath) as! CGFloat
            return height
        }
        return UITableViewAutomaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.hideKeyboard()
    }
    
    //MARK: - UI ACTION METHODS
    //searchButtonAction is executed after pressing the search button
    @IBAction func searchButtonAction(_ sender: Any) {
        self.validateSearchRequest()
    }
    
    @IBAction func switchFilteringResults(_ sender: Any) {
        self.validateSearchRequest()
    }
    
    
    //MARK: - CUSTOM METHODS
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    //validateSearchRequest verification for the keyword to be valid
    func validateSearchRequest(){
        let text_to_search = self.search_textfield.text
        if text_to_search!.count < 3 {
            self.showAlert(alert_view: self.alert_view, alert_message: "You must insert at least 3 characterers")
        }
        else{
            self.picture_collection.clearCollection()
            self.pictures_tableview.reloadData()
            self.searchPictures()
        }
    }
    
    //searchPictures starts the request to the API to get pictures with the keyword
    func searchPictures(){
        let text_to_search = self.search_textfield.text
        self.hideKeyboard()
        if(self.api_connection.checkNetworkConnection() == true){
            self.showHideOverview(show_action: "show", overlay_view: self.overlay_view)
            var url_parameters : Dictionary<String, String> = [:]
            url_parameters["q"] = text_to_search
            
            //url definition
            let plist_api_routing_name = "uri_gallery"
            let page_string : String = String(self.api_page)
            var api_url : String = self.api_routing["url"] as! String
            let api_version : String = self.api_routing["api_version"] as! String
            api_url += api_version
            api_url += self.api_routing[plist_api_routing_name] as! String
            api_url += "/search/time/week/"+page_string
            
            var aditional_parameters : Dictionary<String, String> = [:]
            aditional_parameters["plist_api_routing_name"] = plist_api_routing_name
            aditional_parameters["function_name_to_response"] = "interpretResponseSearchPictures"
            aditional_parameters["api_url"] = api_url
            
            self.api_connection.sendGetRequest(url_parameters: url_parameters, aditional_parameters: aditional_parameters)
        }
        else{
            self.showAlert(alert_view: self.alert_view, alert_message: "Please, verify your internet connection")
        }
    }
    
    //acceptAlert is called when the user press the button "Accept" in the alert view
    @objc func acceptAlert() {
        self.showOrHideViewElement(show_action: "hide", element: self.alert_view)
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    //MARK: - DELEGATES
    //Textfield delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  //if desired
        print("enter")
        self.validateSearchRequest()
        return true
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
                self.showHideOverview(show_action: "hide", overlay_view: self.overlay_view)
                //
                break
            }
        }
    }
    
    //interpretResponseSearchPictures is called after the app receive a response from the server
    //and the response is related to search pictures
    func interpretResponseSearchPictures(response_array : Dictionary<String, AnyObject>){
        self.showHideOverview(show_action: "hide", overlay_view: self.overlay_view)
        if  let response_code = response_array["response_code"] as? Int,
            let response = response_array["response"]  as? Dictionary<String, Any>,
            response_code == 200
        {
            if let json_pictures = response["data"] as? Array<Dictionary<String, AnyObject>> {
                self.picture_collection._toggle_filter_is_on = self.even_results_switch.isOn
                self.picture_collection.createCollectionFromJsonArray(json_pictures: json_pictures)
                
                if self.picture_collection.count == 0 {
                    self.showAlert(alert_view: self.alert_view, alert_message: "There are no results. Please try with a different keyword")
                }
                else if self.api_page > 1 && json_pictures.count == 0 {
                    self.showAlert(alert_view: self.alert_view, alert_message: "Sorry, it looks like there are no more related pictures. But you can try with a different keyword.")
                }
                self.pictures_tableview.reloadData()
            }
        }
        else{
            self.showAlert(alert_view: self.alert_view, alert_message: "There was an error. Please try again")
        }
    }
    
    //MARK: - SCAPE METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}




