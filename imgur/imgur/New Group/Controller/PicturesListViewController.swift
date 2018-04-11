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
    var api_routing : NSDictionary!
    var page : Int = 1
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
        self.api_routing = Bundle.main.object(forInfoDictionaryKey: "ApiRouting") as! NSDictionary
        //STYLE
        //navigation bar
        self.setHeaderStyle(navigation_bar:self.navigationController!.navigationBar, title_for_vc: false)
        //tableview
        let background_view = UIView(frame: CGRect.zero)
        self.pictures_tableview.tableFooterView = background_view
        self.pictures_tableview.backgroundColor = UIColor.clear
        
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
        return self.pictures.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = self.pictures_tableview.dequeueReusableCell(withIdentifier: "picture_cell") as! PictureTableViewCell
        let picture : Picture = self.pictures[indexPath.row]
        if let title = picture.title {
            cell.title_label.text = title
        }
        var date_of_post = ""
        if picture.post_date != nil {
            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"
            date_of_post = dayTimePeriodFormatter.string(from: picture.post_date! as Date)
        }
        cell.date_of_post_label.text = date_of_post
        if let number_images = picture.number_images {
            cell.number_of_pics_label.text = String(number_images)
        }
        
        if  let image_url = picture.image_url,
            let url = URL(string: image_url) {
            //imageView.contentMode = .scaleAspectFit
            
            cell.main_picture_imageview.downloadedFrom(link: image_url)
            
            /*
            //downloading image
            print("Download Started")
            getDataFromUrl(url: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                DispatchQueue.main.async() {
                    cell.main_picture_imageview.image = UIImage(data: data)
                }
            }
             */
        }
        
        /*
        switch indexPath.row {
        case 0,3,6,9:
            cell.title_label.text = "Can’t describe How happy i am"
            cell.main_picture_imageview.image = #imageLiteral(resourceName: "test_happy")
            cell.date_of_post_label.text = "04 Dec 2018"
            cell.number_of_pics_label.text = "4"
            break
        case 1,4,7:
            cell.title_label.text = "I don’t know why people are so angry about this. I also acknowledge that I am going to get a lot of criticism for posting this."
            cell.main_picture_imageview.image = #imageLiteral(resourceName: "test_fb")
            cell.date_of_post_label.text = "01 Apr 2018"
            cell.number_of_pics_label.text = "3"
            break
        case 2,5,8:
            cell.title_label.text = "Coachella sued for preventing acts from playing within 1,300 miles for five months "
            cell.main_picture_imageview.image = #imageLiteral(resourceName: "test_twitt")
            cell.date_of_post_label.text = "02 Jan 2018"
            cell.number_of_pics_label.text = "3"
            break
        default:
            //
            break
        }
         */
        
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    //MARK: - UI ACTION METHODS
    //searchButtonAction is executed after pressing the search button
    @IBAction func searchButtonAction(_ sender: Any) {
        self.validateSearchRequest()
    }
    
    //MARK: - CUSTOM METHODS
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func validateSearchRequest(){
        let text_to_search = self.search_textfield.text
        if text_to_search!.count < 3 {
            self.showAlert(alert_view: self.alert_view, alert_message: "You must insert at least 3 characterers")
        }
        else{
            self.searchPictures(text_to_search: text_to_search!)
        }
    }
    
    //searchPictures starts the request to the API to get pictures with the keyword
    func searchPictures(text_to_search : String){
        self.hideKeyboard()
        if(self.api_connection.checkNetworkConnection() == true){
            self.pictures.removeAll()
            self.pictures_tableview.reloadData()
            self.showHideOverview(show_action: "show", overlay_view: self.overlay_view)
            var url_parameters : Dictionary<String, String> = [:]
            url_parameters["q"] = text_to_search
            
            //url definition
            let plist_api_routing_name = "uri_gallery"
            let page_string : String = String(self.page)
            var api_url : String = self.api_routing["url"] as! String
            let api_version : String = self.api_routing["api_version"] as! String
            api_url += api_version
            api_url += self.api_routing[plist_api_routing_name] as! String
            api_url += "/search/top/"+page_string
            
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
        print("interpretarRespuestaBuscarEstablecimientos")
        self.showHideOverview(show_action: "hide", overlay_view: self.overlay_view)
        if  let response_code = response_array["response_code"] as? Int,
            let response = response_array["response"]  as? Dictionary<String, Any>,
            response_code == 200
        {
            print("response: \(response["data"])")
            
            if let json_pictures = response["data"] as? Array<Dictionary<String, AnyObject>> {
                print("Amount of pictures found: \(json_pictures.count)")
                for (index,json_picture) in json_pictures.enumerated() {
                    print("loading json picture \(index)")
                    //try to get first image from list or main image from post
                    var image_url : String? = nil
                    var number_of_pictures : Int16 = 1
                    if  let images = json_picture["images"] as? Array<Dictionary<String, AnyObject>>,
                        images.count > 0 {
                        let first_image = images.first
                        if let link_first_image = first_image!["link"] as? String {
                            image_url = link_first_image
                            number_of_pictures = Int16(images.count)
                        }
                    }
                    else if let link = json_picture["link"] as? String{
                        image_url = link
                    }
                    if image_url != nil {
                        print("its a valid picture 1")
                        let picture = Picture()
                        if let title = json_picture["title"] as? String {
                            picture.title = title
                        }
                        picture.number_images = number_of_pictures
                        if let datetime = json_picture["datetime"] as? Double {
                            picture.post_date = NSDate(timeIntervalSince1970: datetime)
                        }
                        picture.image_url = image_url
                        self.pictures.append(picture)
                    }
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

