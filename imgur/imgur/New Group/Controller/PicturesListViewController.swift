//
//  PicturesListViewController.swift
//  imgur
//
//  Created by Johan Hernandez on 4/10/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import UIKit

class PicturesListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - GLOBAL VARIABLES DECLARATION
    //--------UI Variables--------
    @IBOutlet var pictures_tableview: UITableView!
    
    //textfields
    //labels
    //--------Business logic variables--------
    var pictures : Array<Picture> = []
    var index_path_seleccionado : IndexPath? = nil
    //sincronización
    var infracciones_por_sincronizar : Array<INFRACCION> = []//variable declarada para incluir infracciones pendientes de sincronizar
    var index_infraccion_en_sincronizacion = 0//establece el index de la infracción que se está sincronizando
    var cantidad_infracciones_sincronizadas = 0
    //--------Other variables--------
    //views
    var overlay_view = UIView()
    var alert_view = UIView()
    //Api
    let api_connection = ApiConnection.shared
    
    //MARK: - VIEW BEHAVIOR METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - TABLEVIEW METHODS
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_to_return = UITableViewCell()
        return cell_to_return
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    //MARK: - UI ACTION METHODS
    
    
    //MARK: - NAVIGATION METHODS
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    //MARK: - CUSTOM METHODS
    
    
    //MARK: - SCAPE METHODS
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

