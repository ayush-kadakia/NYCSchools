//
//  NYCSchoolsViewController.swift
//  NYCSchools
//
//  Created by Ayush Kadakia on 6/28/23.
//

import UIKit
import JGProgressHUD

class NYCSchoolsViewController: UIViewController {

    ///search bar to search for schools
    private let searchBar: UISearchBar = {
        let searchBarch = UISearchBar()
        searchBarch.placeholder = "Search"
        searchBarch.showsCancelButton = false
        return searchBarch
    }()
    
    ///progess spinner while data loads
    private let spinner = JGProgressHUD(style: .dark)

    ///table view to list the schools
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var schools: [NYCHighSchool] = []
    var isSearching = false
    var searchedSchools: [NYCHighSchool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        view.addSubview(tableView)

        ///call api get the schools
        APICaller.shared.fetchNYCHighSchoolInformation { [ weak self ] result in

            switch result {
            case .success(let highschools):
                ///if we get the schools, call API to get the SAT scores for each school
                APICaller.shared.updateNYCHighSchoolWithSATInformation(schools: highschools) { [ weak self ] result in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let highschoolswithsats):
                        strongSelf.schools = highschoolswithsats
                        strongSelf.tableView.reloadData()
                        DispatchQueue.main.async {
                            strongSelf.navigationController?.navigationBar.topItem?.titleView = strongSelf.searchBar
                            strongSelf.spinner.dismiss()
                        }
                    case .failure(_):
                        print("Error Updating Schools with SAT Info")
                    }
                }

            case .failure(_):
                print("Error Fetching the Schools")
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner.show(in: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }


}

extension NYCSchoolsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchedSchools.count
        } else {
            return schools.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///if i was given more time, i would have used a custom tableview cell that would have displayed more data about the school and looked better
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if isSearching {
            cell.textLabel?.text = searchedSchools[indexPath.row].school_name
        } else {
            cell.textLabel?.text = schools[indexPath.row].school_name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        ///if we select a school, open a new view controller as a sheet
        let vc = HighSchoolInfoViewController()
        if isSearching {
            vc.configure(with: searchedSchools[indexPath.row])
        } else {
            vc.configure(with: schools[indexPath.row])
        }
        
        present(vc, animated: true)
    }
    
}

extension NYCSchoolsViewController: UISearchBarDelegate {
     
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         searchedSchools = schools.filter({$0.school_name!.lowercased().prefix(searchText.count) == searchText.lowercased()})
         isSearching = true
         tableView.reloadData()
     }
     
     func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         isSearching = false
         searchBar.text = ""
         searchBar.showsCancelButton = false
         searchBar.endEditing(true)
         tableView.reloadData()
     }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
 }



