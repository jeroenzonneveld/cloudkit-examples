//
//  ViewController.swift
//  AltConf
//
//  Created by Jeroen Zonneveld on 19-05-18.
//  Copyright © 2018 Jeroen Zonneveld. All rights reserved.
//

import UIKit
import CloudKit

final class TalksViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!
    private var talks: [ACTalk] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "AltConf Schedule"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        getData()
        setupTableView()
    }
}

// MARK: - Setup
private extension TalksViewController {
    func setupTableView() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TalkTableViewCell", bundle: nil), forCellReuseIdentifier: "TalkTableViewCell")
    }
    
    func getData() {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "talks", predicate: predicate)
        
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        publicDatabase.perform(query, inZoneWith: nil) { [weak self] (results, error) in
            
            guard error == nil else {
                // show error to the user
                return
            }
            
            results?.forEach({ (talk) in
                let title = talk.object(forKey: "title") as? String
                let speaker = talk.object(forKey: "speaker") as? String
                let date = talk.object(forKey: "date") as? Date
                let location = talk.object(forKey: "location") as? String
                
                let speakerAsset = talk.object(forKey: "speakerImage") as? CKAsset
                let speakerImage = speakerAsset?.image
                
                let talk = ACTalk(title: title, speaker: speaker, date: date, location: location, speakerImage: speakerImage)
                self?.talks.append(talk)
            })
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TalksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TalkTableViewCell", for: indexPath) as! TalkTableViewCell
        cell.talk = talks[indexPath.row]
        return cell
    }
}
