//
//  Contact.swift
//  ContactApp
//
//  Created by SAURABH MISHRA on 17/05/20.
//  Copyright © 2020 SAURABH MISHRA. All rights reserved.
//

import CoreData

@objc(Contact)
class Contact: NSManagedObject {
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var mobileNumber: String
    @NSManaged var email: String

    func update(with contact: ContactU) throws {
        guard let firstName = contact.firstName,
               let lastName = contact.lastName,
               let email = contact.email,
               let mobileNumber = contact.mobileNumber
               else {
                   throw NSError(domain: "", code: 100, userInfo: nil)
           }
           
           self.firstName = firstName
           self.lastName = lastName
           self.email = email
           self.mobileNumber = mobileNumber
          
       }
}

