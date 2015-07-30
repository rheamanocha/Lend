//
//  LendViewController.swift
//  Lend
//
//  Created by Rhea on 7/30/15.
//  Copyright (c) 2015 Rhea. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class LendViewController: UITableViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    var state: State = .DefaultMode {
        didSet {
            // update notes and search bar whenever State changes
            switch (state) {
            case .DefaultMode:
                let realm = Realm()
                notes = realm.objects(Note).sorted("modificationDate", ascending: false) //1
                self.navigationController!.setNavigationBarHidden(false, animated: true) //2
                searchBar.resignFirstResponder() // 3
                searchBar.text = ""
                searchBar.showsCancelButton = false
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                searchBar.setShowsCancelButton(true, animated: true) //4
                notes = searchNotes(searchText) //5
                self.navigationController!.setNavigationBarHidden(true, animated: true) //6
            }
        }
    }
    
    var notes: Results<Note>!  {
        didSet {
            // Whenever notes update, update the table view
            if let tableView = tableView {
                tableView.reloadData()
            }
        }
    }
    
    var selectedNote: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let realm = Realm()
        notes = realm.objects(Note).sorted("modificationDate", ascending: false)
        state = .DefaultMode
        super.viewWillAppear(animated)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Actions
    
    @IBAction func unwindToSegue(segue: UIStoryboardSegue) {
        
        if let identifier = segue.identifier {
            
            switch identifier {
            case "Save":
                let source = segue.sourceViewController as! NewNoteViewController
                let realm = Realm()
                
                realm.write() {
                    realm.add(source.currentNote!)
                }
            case "Delete":
                let realm = Realm()
                
                realm.write() {
                    realm.delete(self.selectedNote!)
                }
                
                let source = segue.sourceViewController as! NoteDisplayViewController
                source.note = nil;
                
            default:
                println("No one loves \(identifier)")
            }
        }
        
        let realm = Realm()
        notes = realm.objects(Note).sorted("modificationDate", ascending: false) //2
    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowExistingNote") {
            let noteViewController = segue.destinationViewController as! NoteDisplayViewController
            noteViewController.note = selectedNote
        }
    }
    
    //MARK: Search
    
    func searchNotes(searchString: String) -> Results<Note> {
        let realm = Realm()
        let searchPredicate = NSPredicate(format: "title CONTAINS[c] %@ OR content CONTAINS[c] %@", searchString, searchString)
        return realm.objects(Note).filter(searchPredicate)
    }
}

extension NotesViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) as! NoteTableViewCell
        
        let row = indexPath.row
        let note = notes[row] as Note
        cell.note = note
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(notes?.count ?? 0)
    }
    
}

extension NotesViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedNote = notes[indexPath.row] //1
        self.performSegueWithIdentifier("ShowExistingNote", sender: self) //2
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // 3
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            
            let note = notes[indexPath.row] as Object
            
            let realm = Realm()
            
            realm.write() {
                realm.delete(note)
            }
            
            notes = realm.objects(Note).sorted("modificationDate", ascending: false)
        }
    }
}

extension NotesViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        notes = searchNotes(searchText)
    }
    
}
