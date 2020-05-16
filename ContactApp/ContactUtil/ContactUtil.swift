//
//  ContactUtil.swift
//  ContactApp
//
//  Created by SAURABH MISHRA on 17/05/20.
//  Copyright © 2020 SAURABH MISHRA. All rights reserved.
//

import Foundation
import Contacts

class ContactUtil {
    
    private init() {}
    
    static let shared = ContactUtil()
    
    func getContact(completion:@escaping(_ contacts:[ContactU]?, _ error:Error?)->()){
        
        
        requestedForAccess {(granted) in
            if granted{
                let store = CNContactStore()
                var results:[ContactU] = []
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactMiddleNameKey, CNContactEmailAddressesKey ,CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                request.sortOrder = CNContactSortOrder.userDefault
                do{
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stop) in
                        var emailAddress = ""
                        if (contact.emailAddresses as NSArray).count != 0{
                            emailAddress = (contact.emailAddresses.first!).value as String
                        }
                        
                        var mobiles = [CNPhoneNumber]()
                        for num in contact.phoneNumbers {
                            let numVal = num.value
                            if num.label != CNLabelPhoneNumberHomeFax && num.label != CNLabelPhoneNumberWorkFax && num.label != CNLabelPhoneNumberOtherFax && num.label != CNLabelHome && num.label != CNLabelWork {
                                mobiles.append(numVal)
                            }
                        }
                        if mobiles.count>0{
                            
                            results.append(ContactU(firstName: contact.givenName, lastName: contact.familyName, mobileNumber: mobiles.first?.stringValue, email: emailAddress))
                        }
                        
                    })
                    
                    completion(results,nil)
                }
                catch let error{
                    completion(nil,error)
                   
                }
            }else{
                completion(nil,NSError(domain: "authorization", code: 111, userInfo: nil))
            }
        }
        
        
        
    }
    
    func getMobileNumber(contact:CNContact){
        
        
        var mobiles = [CNPhoneNumber]()
        for num in contact.phoneNumbers {
            let numVal = num.value
            if num.label != CNLabelPhoneNumberHomeFax && num.label != CNLabelPhoneNumberWorkFax && num.label != CNLabelPhoneNumberOtherFax {
                mobiles.append(numVal)
            }
        }
        
    }
    
    
    
    func requestedForAccess(completion:@escaping ( _ accessGranted:Bool)->Void){
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        let store = CNContactStore()
        switch authorizationStatus {
        case .authorized:
            completion(true)
        case .notDetermined,.denied:
            store.requestAccess(for: .contacts ) { (access, accessError) in
                if access{
                    completion(access)
                }else{
                    if authorizationStatus == .denied{
                        let message="Allow access"
                        DispatchQueue.main.async{
                            print(message)
                        }
                    }
                }
            }
        default:
            completion(false)
        }
    }
}
