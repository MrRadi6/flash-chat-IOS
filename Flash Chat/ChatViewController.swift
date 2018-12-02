//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import Toast_Swift

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    // Declare instance variables here

    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    var messagesDB: [Message] = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self //delegate or dataScoure call reloadData()
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        messageTableView.separatorStyle = .none
        retrieveMessages()
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = messagesDB[indexPath.row].messageBody
        cell.senderUsername.text = messagesDB[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String!{
            
            cell.messageBackground.backgroundColor = UIColor.flatBlue()
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
        }
        else{
            
            cell.messageBackground.backgroundColor = UIColor.flatGreen()
            cell.avatarImageView.backgroundColor = UIColor.flatLime()
            
        }
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesDB.count
    }
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 130.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDB_ref = Database.database().reference().child("Messages")
        let messageContent = ["sender":Auth.auth().currentUser?.email,"message":messageTextfield.text]
        
        messageDB_ref.childByAutoId().setValue(messageContent) {
            (error, userReference) in
            if error != nil{
                self.view.makeToast("connection Error",duration: 0.3,position: .bottom)
                print("sent message failed: \(String(describing: error))")
            }
            else{
                print("sent message success!")
                self.messageTextfield.text = ""
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
            }
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages(){
        let messageDB_ref = Database.database().reference().child("Messages")
        messageDB_ref.observe(.childAdded) { (snapshot) in
            
            if snapshot.value != nil{
                let snapeShotValue = snapshot.value as! Dictionary<String,String>
                let message = Message(sender: snapeShotValue["sender"]!, messageBody: snapeShotValue["message"]!)
                print("message: \(message.messageBody), sender: \(message.sender)")
                self.messagesDB.append(message)
                self.configureTableView()
                self.messageTableView.reloadData()
            }
            else {
                self.view.makeToast("connection Error",duration: 0.3,position: .bottom)
                print("failed to retrieve the message")
            }
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do{
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
            
        }
        catch{
            print("error has been caughted!!")
        }
    }
    


}
