import Eureka
import ImageRow
import AWSAppSync


class UserAccountController: FormViewController {
    
    
    var appSyncClient: AWSAppSyncClient?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print(userGlobalState)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient!
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: GLOBAL_SIGNIN_REFRESH), object: nil)
        
        form
            
            +++ Section() {
                $0.header = HeaderFooterView<SALogoView>(.class)
            }
            
            +++ Section("Basic Information")
            <<< LabelRow(){ row in
                row.tag = "username"
                row.title = "Username"
                row.value = username
            }.cellUpdate { cell, row in
                 print("cell update ,username: \(username)")
                 row.value = username
            }
            <<< TextRow(){ row in
                row.tag = "name"
                row.title = "Name"
                //row.placeholder = "Name"
                row.value = firstName + " " + lastName
            }.cellUpdate { cell, row in
                row.value = firstName + " " + lastName
            }
            <<< TextRow(){ row in
                row.tag = "location"
                row.title = "Location"
                //   row.placeholder = "Location"
                row.value = location
                }.cellUpdate { cell, row in
                    row.value = location
                }
            <<< TextRow(){ row in
                row.tag = "bio"
                row.title = "Bio"
                // row.placeholder = "Bio"
                row.value = bio
                }.cellUpdate { cell, row in
                    row.value = location
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
        getSettingsQuery()
  
        print("Username: \(username)")
        print("Location: \(location)")
        form.rowBy(tag: "username")?.updateCell()
        form.rowBy(tag: "name")?.updateCell()
        form.rowBy(tag: "location")?.updateCell()
        form.rowBy(tag: "bio")?.updateCell()
        form.rowBy(tag: "login")?.updateCell()
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
            let clearCacheOptions = ClearCacheOptions(clearQueries: true,
                                                        clearMutations: true,
                                                    clearSubscriptions: true)
                do {
                    try {
                        appSyncClient.clearCaches(options: clearCacheOptions)
                    }
                    catch {
                           print("fuck me")
                    }}
              
                break
            default:
                userSignIn(navController: self.navigationController!)
                form.rowBy(tag: "login")?.updateCell()
                break
                
                
            }
            
        }
    
    func getSettingsQuery() {
    appSyncClient?.fetch(query: GetUserQuery()) {
        (result, error) in
        if error != nil {
            print(error?.localizedDescription ?? "")
            return
        }
        
        print(result?.data?.getUser?.firstName)
        firstName = (result?.data?.getUser?.firstName)!
        lastName = (result?.data?.getUser?.lastName)!
        bio = (result?.data?.getUser?.bio)!
        location = (result?.data?.getUser?.location)!
        username = (result?.data?.getUser?.username)!
        avatarImage = (result?.data?.getUser?.image)!
        
    }
}
}


class SALogoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 130)
        
        let imageView = UIImageView(image: UIImage(named: "dummy-avatar"))
        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.frame = CGRect(x: (UIScreen.main.bounds.width/2)-50, y: 10, width: 100, height: 100)
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
