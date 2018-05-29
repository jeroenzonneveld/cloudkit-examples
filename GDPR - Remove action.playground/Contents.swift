//: Playground - noun: a place where people can play

import UIKit
import CloudKit

CKContainer.default().privateCloudDatabase.fetchAllRecordZones { zones, error in
    guard let zones = zones, error == nil else {
        print("Error fetching zones.")
        return
    }
    
    let zoneIDs = zones.map { $0.zoneID }
    let deletionOperation = CKModifyRecordZonesOperation(recordZonesToSave: nil, recordZoneIDsToDelete: zoneIDs)
    
    deletionOperation.modifyRecordZonesCompletionBlock = { _, _, error in
        guard error == nil else {
            print("Error deleting records.")
            return
        }
        
        print("Records successfully deleted in this zone.")
    }
    
    CKContainer.default().privateCloudDatabase.add(deletionOperation)
}

