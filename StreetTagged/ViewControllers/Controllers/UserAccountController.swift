import Eureka
import ImageRow
import AWSAppSync


class UserAccountController: FormViewController {
    
    
    var appSyncClient: AWSAppSyncClient?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print(userGlobalState)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: GLOBAL_SIGNIN_REFRESH), object: nil)
        
        form
            
            +++ Section() {
                $0.header = HeaderFooterView<SALogoView>(.class)
            }
            
            +++ Section("Basic Information")
            <<< LabelRow(){ row in
                row.title = "Username"
                row.value = username
            }
            <<< TextRow(){ row in
                row.tag = "name"
                row.title = "Name"
                //row.placeholder = "Name"
                row.value = firstName + " " + lastName
            }
            <<< TextRow(){ row in
                row.title = "Location"
                //   row.placeholder = "Location"
                row.value = location
            }
            <<< TextRow(){ row in
                row.title = "Bio"
                // row.placeholder = "Bio"
                row.value = bio
            }
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.tag = "login"
                row.title = getUserState()
            }
            .onCellSelection { cell, row in
                self.handleLogin()
                row.title = self.getUserState()
            }.cellUpdate { cell, row in
                row.title = self.getUserState()
        }
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    @objc func refresh(){
        form.rowBy(tag: "login")?.updateCell()
        form.rowBy(tag: "name")?.updateCell()
    }
    
    func getUserState() -> String {
        var title: String = ""
        switch userGlobalState {
        case .userSignedIn:
            title = "Sign Out"
            break
        case .userSignedOut:
            title = "Sign in"
            break
        default:
            title = "Sign in/out"
        }
        return title
        
    }
    
    func handleLogin(){
        switch userGlobalState {
        case .userSignedIn:
            userSignOut()
            form.rowBy(tag: "login")?.updateCell()
            
            
            break
        default:
            userSignIn(navController: self.navigationController!)
            form.rowBy(tag: "login")?.updateCell()
            break
            
            
        }
        
    }
}




class SALogoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 130)
        
        let imageView = UIImageView(image: UIImage(named: "headshot"))
        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        print(UIScreen.main.bounds.width/2-50)
        imageView.frame = CGRect(x: (UIScreen.main.bounds.width/2)-50, y: 10, width: 100, height: 100)
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
