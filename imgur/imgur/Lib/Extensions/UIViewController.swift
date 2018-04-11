//
//  UIViewController.swift
//  imgur
//
//  Created by Johan Hernandez on 4/11/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import UIKit

extension UIViewController {
    
    //This extension define methods related with the UI. They are used by many controllers including the same logic.
    
    //MARK: - OVERLAYVIEW
    func includeOverlayView(controller : UIViewController) -> UIView{
        let overlay_view = UIView(frame: CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size))
        overlay_view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        //activity indicator
        let activity_indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activity_indicator.color = UIColor(red: 66/255, green: 167/255, blue: 184/255, alpha: 1)
        activity_indicator.center = overlay_view.center
        overlay_view.addSubview(activity_indicator)
        activity_indicator.startAnimating()
        //check_mark
        let check_mark_image_view = UIImageView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 100)))
        check_mark_image_view.tag = 1
        check_mark_image_view.center = overlay_view.center
        check_mark_image_view.alpha = 0
        check_mark_image_view.transform = CGAffineTransform(rotationAngle: 180)
        overlay_view.addSubview(check_mark_image_view)
        overlay_view.alpha = 0
        controller.view.addSubview(overlay_view)
        return overlay_view
    }
    
    func showHideOverview(show_action : String, overlay_view : UIView, show_checkmark : Bool = false){
        //Este método permite mostrar u ocultar la vista de carga que tapa los elementos del formulario
        //show_action puede ser "show" o "hide"
        var new_overlayview_alpha : CGFloat = 0
        if show_action == "show" {
            new_overlayview_alpha = 1
        }
        if show_action == "show" || (show_action == "hide" && show_checkmark == false){
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                () in
                overlay_view.alpha = new_overlayview_alpha
            },
                           completion: {
                            (finished: Bool) in
            });
        }
        else if (show_action == "hide" && show_checkmark == true) {
            let check_mark_image_view = overlay_view.viewWithTag(1) as! UIImageView//tag for checkmark defined in function getOverlayView()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                () in
                check_mark_image_view.transform = CGAffineTransform(rotationAngle: 0)
                check_mark_image_view.alpha = 1
            },
                           completion: {
                            (finished: Bool) in
                            UIView.animate(withDuration: 0.3, delay: 0.6, options: .curveLinear, animations: {
                                () in
                                overlay_view.alpha = new_overlayview_alpha
                            },
                                           completion: {
                                            (finished: Bool) in
                                            check_mark_image_view.alpha = 0
                                            check_mark_image_view.transform = CGAffineTransform(rotationAngle: 180)
                            });
                            
            });
            
        }
    }
    
    //MARK: Alert message
    func showAlert(alert_view : UIView, alert_message : String){
        let view_label = alert_view.viewWithTag(10) as! UILabel
        view_label.text = alert_message
        self.showOrHideViewElement(show_action: "show", element: alert_view)
    }
    
    func includeAlertView( controller : UIViewController, withLongText : Bool = false) -> UIView {
        let screen_size : CGRect = UIScreen.main.bounds
        var alert_content_view_height : CGFloat = 140
        let alert_content_view_width : CGFloat = screen_size.width * 0.84
        var height_to_decrease : CGFloat = 0
        height_to_decrease = screen_size.height * 0.09
        var alert_message_label_y : CGFloat = 20
        var alert_message_height : CGFloat = 50
        var number_of_lines = 3
        var margin_top_button : CGFloat = 0.05
        if (withLongText == true) {
            alert_message_label_y = 10
            alert_message_height = 80
            number_of_lines = 5
            margin_top_button = 0.15
            alert_content_view_height = 160
        }
        
        let alert_view = UIView(frame:CGRect(x: 0, y: 0, width: screen_size.width, height: screen_size.height))
        alert_view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
        //Message view
        let alert_content_view = UIView(frame:
            CGRect(x: (alert_view.frame.size.width / 2) - ((alert_view.frame.size.width * 0.84) / 2), y: (screen_size.height / 2) - (alert_content_view_height / 2) - height_to_decrease, width: alert_content_view_width, height: alert_content_view_height)
        )
        alert_content_view.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        alert_content_view.layer.cornerRadius = 7
        alert_content_view.layer.borderWidth = 1
        alert_content_view.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1).cgColor
        //shadow
        alert_content_view.layer.shadowColor = UIColor.black.cgColor
        alert_content_view.layer.shadowOpacity = 0.3
        alert_content_view.layer.shadowOffset = CGSize.zero
        alert_content_view.layer.shadowRadius = 3
        alert_content_view.layer.shadowPath = UIBezierPath(rect: alert_content_view.bounds).cgPath
        
        
        alert_view.addSubview(alert_content_view)
        let alert_message_label = UILabel(frame:
            CGRect(x: 10, y: alert_message_label_y, width: alert_content_view.frame.size.width - 20, height: alert_message_height)
        )
        alert_message_label.text = "Alert message"//This value is defined each time the alert is called
        alert_message_label.textAlignment = NSTextAlignment.center
        alert_message_label.numberOfLines = number_of_lines
        alert_message_label.lineBreakMode = NSLineBreakMode.byWordWrapping
        alert_message_label.tag = 10
        alert_content_view.addSubview(alert_message_label)
        //Button
        let confirm_button = UIButton(frame: CGRect(x: (alert_content_view.frame.size.width / 2) - 50 ,y: (alert_content_view.frame.size.height/2) + alert_content_view.frame.size.height * margin_top_button ,width: 100,height: 35))
        confirm_button.setTitle("Accept", for: UIControlState.normal)
        confirm_button.backgroundColor = UIColor(red: 66/255, green: 167/255, blue: 184/255, alpha: 1)
        confirm_button.layer.cornerRadius = 5
        confirm_button.addTarget(controller, action: Selector(("acceptAlert")),for: UIControlEvents.touchUpInside)
        //button.addTarget(self, action: #selector(pressButton(_:)), for: .touchUpInside)
        alert_content_view.addSubview(confirm_button)
        controller.view.addSubview(alert_view)
        alert_view.alpha = 0
        alert_view.layer.zPosition = 990;
        return alert_view
    }
    
    //showOrHideViewElement shows or hide any element with fade effect
    func showOrHideViewElement(show_action : String, element : UIView){
        //show_action could be "show" or "hide"
        var new_overlayview_alpha : CGFloat = 0
        if show_action == "show" {
            new_overlayview_alpha = 1
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            () in
            element.alpha = new_overlayview_alpha
        },
                       completion: {
                        (finished: Bool) in
        });
    }
    
    //MARK: LOOK
    func setHeaderStyle(navigation_bar : UINavigationBar, title_for_vc : Bool = false){
        //background
        navigation_bar.setBackgroundImage(#imageLiteral(resourceName: "background"), for: UIBarPosition.top, barMetrics: UIBarMetrics.default)
        
        if title_for_vc == false {
            //logo for title
            let imageView = UIImageView(image: #imageLiteral(resourceName: "header_logo"))
            imageView.contentMode = UIViewContentMode.scaleAspectFit // set imageview's content mode
            navigation_bar.topItem?.titleView = imageView
        }
        navigation_bar.backgroundColor = UIColor.darkGray
        navigation_bar.barTintColor = UIColor.white
        navigation_bar.tintColor = UIColor.white
        navigation_bar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
}
