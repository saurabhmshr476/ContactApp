//
//  ViewController.swift
//  ContactApp
//
//  Created by SAURABH MISHRA on 16/05/20.
//  Copyright © 2020 SAURABH MISHRA. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Proeperties
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataProvider: DataProvider?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Contact> = {
          let fetchRequest = NSFetchRequest<Contact>(entityName:"Contact")
          fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending:true)]
          let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                      managedObjectContext: CoreDataStack.shared.persistentContainer.viewContext,
                                                      sectionNameKeyPath: nil, cacheName: nil)
          controller.delegate = self
          
          do {
              try controller.performFetch()
          } catch {
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
          }
          
          return controller
      }()
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        
    }
    
    func setUp(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Contacts";

        tableView.delegate = self
        tableView.dataSource = self
        
        let coreDataStack = CoreDataStack.shared
        
        dataProvider = DataProvider(persistentContainer: coreDataStack.persistentContainer, util: ContactUtil.shared)
        
        dataProvider?.fetchContact {(error) in
            // Handle Error by displaying it in UI
        }
    }
    
}


// MARK: - Tableview delegate & datasource

extension ViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        
        let contact = fetchedResultsController.object(at: indexPath)
        cell.email.text = contact.email
        cell.name.text = (contact.firstName) + " " + (contact.lastName)
        cell.mobile.text = contact.mobileNumber
        return cell
    }
    
    
}


// MARK: - NSFetchedResultsControllerDelegate

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.reloadData()
    }
}
