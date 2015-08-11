//
//  RealmLogger.swift
//  RealmResultsController
//
//  Created by Pol Quintana on 6/8/15.
//  Copyright © 2015 Redbooth. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLogger {
    var realm: Realm
    var temporary: [RealmChange] = []
    var notificationToken: NotificationToken?
    
    init(realm: Realm) {
        self.realm = realm
        self.notificationToken = self.realm.addNotificationBlock { (notification, realm) -> Void in
            if notification == .DidChange {
                self.finishRealmTransaction()
            }
        }
    }
    
    func finishRealmTransaction() {
        if realm.path.hasSuffix("testingRealm") {
            NSNotificationCenter.defaultCenter().postNotificationName("realmChangesTest", object: temporary)
            return //Don't send notifications for testing realm. Hackish :(
        }
        NSNotificationCenter.defaultCenter().postNotificationName("realmChanges", object: temporary)
        cleanAll()
    }
    
    func didAdd<T: Object>(object: T) {
        addObject(object, action: .Create)
    }
    
    func didUpdate<T: Object>(object: T) {
        addObject(object, action: .Update)
    }
    
    func didDelete<T: Object>(object: T) {
        addObject(object, action: .Delete)
    }
    
    func addObject<T: Object>(object: T, action: RealmAction) {
        let primaryKey = T.primaryKey()!
        let primaryKeyValue = (object as Object).valueForKey(primaryKey)
        let realmChange = RealmChange(type: object.dynamicType, primaryKey: primaryKeyValue!, action: action)
        temporary.append(realmChange)
    }
    
    func cleanAll() {
        temporary.removeAll()
    }
}

