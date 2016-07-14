//
//  ViewController.swift
//  BlueTeam
//
//  Created by Yanliang Gu on 7/13/16.
//  Copyright © 2016 Yanliang Gu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var teamTable: UITableView!
    @IBOutlet weak var locationTable: UITableView!
    @IBOutlet weak var calculateBtn: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var mainSiteBtn: UIButton!
    @IBOutlet weak var mainSiteLabel: UILabel!
    
    private let teamTableCellReuseIdentifier = "teamTableCell"
    private let locationTableCellReuseIdentifier = "locationTableCell"
    private let LOCATION_PENALTY = 0.5
    private let TIME_ZONE_PENALTY = 0.75
    private let TIME_ZONE_DIFF = 12.0
    
    var teamArray = NSMutableArray()
    var siteDict: NSDictionary!
    var siteDictKeys: Array<String>!
    var addMainSite: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTeamTable()
        setLocationTable()
        scoreLabel.layer.borderColor = UIColor.redColor().CGColor
        scoreLabel.layer.borderWidth = 2.0
        scoreLabel.layer.cornerRadius = 8.0
        self.view.bringSubviewToFront(mainSiteBtn)
        mainSiteLabel.layer.borderWidth = 0.5
        mainSiteLabel.layer.borderColor = UIColor.grayColor().CGColor
        siteDict = readSiteList()
        siteDictKeys = (siteDict.allKeys as! Array<String>).sort{$0 < $1}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        Read the site list "SiteList.plist"s
     */
    func readSiteList() -> NSDictionary {
        var myDict: NSDictionary!
        if let path = NSBundle.mainBundle().pathForResource("SiteList", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        return myDict
    }
    
    /**
        Set the team table
     */
    func setTeamTable() {
        teamTable.registerNib(UINib(nibName: "TeamTableCell", bundle: nil), forCellReuseIdentifier: teamTableCellReuseIdentifier)
        teamTable.delegate = self
        teamTable.dataSource = self
        //teamTable.backgroundColor = UIColor.grayColor()
        //teamTable.allowsSelection = false
    }
    
    /**
        Set the location table
     */
    func setLocationTable() {
        locationTable.delegate = self
        locationTable.dataSource = self
        self.view.bringSubviewToFront(locationTable)
        locationTable.layer.borderWidth = 1.0
        locationTable.layer.borderColor = UIColor.blackColor().CGColor
        locationTable.layer.cornerRadius = 5.0
        locationTable.hidden = true
        //locationTable.allowsSelection = false
    }
    
    /**
        Number of sections in the table
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
        Number of rows in the table
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == teamTable {
            return teamArray.count + 1
        } else {
            return siteDictKeys.count
        }
    }
    
    /**
        Set cell in the table
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == teamTable {
            let cell: TeamTableCell = tableView.dequeueReusableCellWithIdentifier(teamTableCellReuseIdentifier, forIndexPath: indexPath) as! TeamTableCell
            if indexPath.row == teamArray.count {
                cell.textField.text = ""

            } else {
                let time = (siteDict.valueForKey(teamArray[indexPath.row] as! String)?.integerValue)! - 12
                var middleString = " UTC"
                if time >= 0 {
                    middleString = " UTC+"
                }
                cell.textField.text = teamArray[indexPath.row] as! String + middleString + String(time) + ":00"
            }
            if indexPath.row == teamArray.count {
                cell.addBtn.tag = indexPath.row
                cell.addBtn.hidden = false
                cell.deleteBtn.hidden = true
                cell.addBtn.addTarget(self, action: #selector(ViewController.addBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                cell.deleteBtn.tag = indexPath.row
                cell.addBtn.hidden = true
                cell.deleteBtn.hidden = false
                cell.deleteBtn.addTarget(self, action: #selector(ViewController.deleteBtnClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(locationTableCellReuseIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = siteDictKeys[indexPath.row]
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if tableView == locationTable {
            if addMainSite {
//                mainSiteBtn.setTitle(siteDictKeys[indexPath.row], forState: .Normal)
                mainSiteLabel.text = siteDictKeys[indexPath.row]
                locationTable.hidden = true
            } else {
                teamArray.addObject(siteDictKeys[indexPath.row])
                locationTable.hidden = true
                teamTable.reloadData()
            }
        }
        
    }
    
    /**
        Click the delete button in one cell will delete this cell
     */
    func deleteBtnClicked(sender:UIButton) {
        teamArray.removeObjectAtIndex(sender.tag)
        teamTable.reloadData()
    }
    
    /**
        Click the add button in the last cell will add a new cell
     */
    func addBtnClicked(sender:UIButton) {
        locationTable.hidden = false
        addMainSite = false
    }

    @IBAction func chooseMainSite(sender: UIButton) {
        locationTable.hidden = false
        addMainSite = true
    }
    
    @IBAction func calculateScore(sender: AnyObject) {
        if mainSiteLabel.text != "Choose Main Site" {
            var diffLocation: NSMutableDictionary = NSMutableDictionary()
//            var maxN = 0
//            var maxL = ""
            for location in teamArray {
                let val = diffLocation.valueForKey(location as! String)
                if val != nil {
                    diffLocation.setValue((val?.integerValue)!+1, forKey: location as! String)
//                    if (val?.integerValue)!+1 > maxN {
//                        maxN = (val?.integerValue)!+1
//                        maxL = location as! String
//                    }
                } else {
                    diffLocation.setValue(1, forKey: location as! String)
//                    if maxN == 0 {
//                        maxN = 1
//                        maxL = location as! String
//                    }
                }
            }
            let diffLocationKeys = diffLocation.allKeys
            //print(diffLocation)
            if diffLocationKeys.count != 0 {
                let standardTime = siteDict.valueForKey((mainSiteLabel.text)!)!.integerValue
                var totalMembers = 0.0
                var sumLocations = 0.0
                //print(standardTime)
                for dl in diffLocation {
                    //let locationMembers = dl.value.doubleValue
                    totalMembers = totalMembers + (dl.value).doubleValue
                    let timeDiff = Double(abs(siteDict.valueForKey(dl.key as! String)!.integerValue - standardTime))
                    sumLocations = sumLocations + (1 - timeDiff / TIME_ZONE_DIFF * TIME_ZONE_PENALTY) * (dl.value).doubleValue
                    //print(sumLocations/totalMembers)
                }
                let result = (sumLocations - Double(diffLocationKeys.count - 1) * LOCATION_PENALTY) / totalMembers
                scoreLabel.text = String(Int(result*100))+"%"
                print(result)
            }
        }
    }
}

