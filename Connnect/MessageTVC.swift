import UIKit
import PubNub

class MessageTVC: UITableViewController {
    
    let notificationName = Notification.Name("NewMessage")

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(MessageTVC.updateMessage), name: notificationName, object: nil)

    }
    
    func updateMessage()  {
        print("new message reveived by table view controller")
        tableView.reloadData()
    }

    
}


extension MessageTVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate.shared.myMessages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        
        cell.textLabel?.text = AppDelegate.shared.myMessages[indexPath.row]
        
        return cell
    }
}