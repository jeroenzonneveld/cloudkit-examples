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
    
    private var favorites: [CKRecord]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "AltConf Schedule"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        getData()
        setupTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(showAddTalkViewController))
    }
}

// MARK: - Setup
private extension TalksViewController {
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TalkTableViewCell", bundle: nil), forCellReuseIdentifier: "TalkTableViewCell")
    }
    
    @objc func showAddTalkViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addTalkVc: AddTalkViewController = (storyboard.instantiateViewController(withIdentifier: "AddTalkViewController") as? AddTalkViewController) else { return }
        
        navigationController?.pushViewController(addTalkVc, animated: true)
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
                let record = talk
                
                let title = talk.object(forKey: "title") as? String
                let speaker = talk.object(forKey: "speaker") as? String
                let date = talk.object(forKey: "date") as? Date
                let location = talk.object(forKey: "location") as? String
                
                let speakerAsset = talk.object(forKey: "speakerImage") as? CKAsset
                let speakerImage = speakerAsset?.image
                
                let talk = ACTalk(record: record, title: title, speaker: speaker, date: date, location: location, speakerImage: speakerImage)
                self?.talks.append(talk)
            })
            
            self?.getFavorites()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func getFavorites() {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "favorites", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { [weak self] (results, error) in
            
            self?.favorites = results
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
        
        favorites?.forEach({ (record) in
            let talk = record.object(forKey: "talk") as? CKReference
            
            if talk?.recordID == cell.talk?.record?.recordID {
                cell.isFavorite = true
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - UITableViewDelegate
extension TalksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let favorite = UITableViewRowAction(style: .normal, title: "Favorite") { action, index in
            let talk = self.talks[indexPath.row]
            self.setFavorite(talk: talk)
        }
        
        favorite.backgroundColor = .orange
        
        let dislike = UITableViewRowAction(style: .normal, title: "Dislike") { action, index in
            let talk = self.talks[indexPath.row]
            self.unsetFavorite(talk: talk)
        }
        
        dislike.backgroundColor = .red
        
        var isFavorite = false
        favorites?.forEach({ (record) in
            let talk = record.object(forKey: "talk") as? CKReference
            
            if talk?.recordID == talks[indexPath.row].record?.recordID {
                isFavorite = true
            }
        })
        
        if isFavorite {
            return [dislike]
        } else {
            return [favorite]
        }
    }
}

//MARK: Set talks favorite
private extension TalksViewController {
    func setFavorite(talk: ACTalk) {
        guard let record = talk.record else { return }
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        let activityRecord = CKRecord(recordType: "favorites")
        
        let reference = CKReference(record: record, action: CKReferenceAction.deleteSelf)
        activityRecord["talk"] = reference
        
        privateDatabase.save(activityRecord) { [weak self] (record, error) in
            guard error == nil, let record = record else { return }
            self?.favorites?.append(record)
        }
    }
    
    func unsetFavorite(talk: ACTalk) {
        
        var deletedRecord: CKRecord?
        favorites?.forEach({ (record) in
            let referenceTalk = record.object(forKey: "talk") as? CKReference
            
            if talk.record?.recordID == referenceTalk?.recordID {
                deletedRecord = record
            }
        })
        
        guard let recordID = deletedRecord?.recordID else { return }
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        privateDatabase.delete(withRecordID: recordID) { [weak self] (record, error) in
            guard error == nil, let favorites = self?.favorites?.filter({ $0 != deletedRecord }) else { return }
            self?.favorites = favorites
        }
    }
}


