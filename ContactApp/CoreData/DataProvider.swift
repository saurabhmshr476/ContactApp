//
//  DataProvider.swift
//  ContactApp
//
//  Created by SAURABH MISHRA on 17/05/20.
//  Copyright © 2020 SAURABH MISHRA. All rights reserved.
//

import CoreData

let dataErrorDomain = "dataErrorDomain"

enum DataErrorCode: NSInteger {
    case unavailable = 101
    case wrongDataFormat = 102
}


class DataProvider {
    
    private let persistentContainer: NSPersistentContainer
    private let util: ContactUtil
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    init(persistentContainer: NSPersistentContainer, util: ContactUtil) {
        self.persistentContainer = persistentContainer
        self.util = util
    }
    
    func fetchContact(completion:@escaping(Error?) -> Void) {
        util.getContact() { contacts, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let contacts = contacts else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                completion(error)
                return
            }
            
            let taskContext = self.persistentContainer.newBackgroundContext()
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            taskContext.undoManager = nil
            
            _ = self.syncContacts(contacts: contacts, taskContext: taskContext)
            
            completion(nil)
        }
    }
    
    private func syncContacts(contacts: [ContactU], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        taskContext.performAndWait {
            let matchingContactRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
            let mobileIds = contacts.map { $0.mobileNumber }.compactMap { $0 }
            matchingContactRequest.predicate = NSPredicate(format: "mobileNumber in %@", argumentArray: [mobileIds])
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingContactRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }
            
            // Create new records.
            for contact in contacts {
                
                guard let cnt = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: taskContext) as? Contact else {
                    print("Error: Failed to create a new Film object!")
                    return
                }
                
                do {
                    try cnt.update(with: contact)
                } catch {
                    print("Error: \(error)\nThe contact object will be deleted.")
                    taskContext.delete(cnt)
                }
            }
            
            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }
}
