import UIKit
import PubNub

class MessageTVC: UITableViewController {
    
    let notificationName = Notification.Name("NewMessage")

    @IBAction func settingsButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Geofencing", bundle: nil)
        let settingVC = storyboard.instantiateViewController(withIdentifier: "Settings")
        self.navigationController?.pushViewController(settingVC, animated: true)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(MessageTVC.updateMessage), name: notificationName, object: nil)
        tableView.tableFooterView = UIView()
        let imageView = UIImageView(image: UIImage(named: "NewBack"))
        self.tableView.backgroundView = imageView

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
        cell.layer.cornerRadius = 20
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = AppColors.LightGray.cgColor
        cell.clipsToBounds = true
        return cell
    }
    
}
