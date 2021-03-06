//
//  ViewController.swift
//  ZipCodeApp
//
//  Created by 森園王 on 2021/11/06.
//

import UIKit

//MARK: JSONをフラットマップにするためのStruct
 struct ZipCloudResponse: Codable {
     let message: String?
     let results : [Address]?
     let status : Int
 }

 struct Address: Codable {
     let address1: String
     let address2: String
     let address3: String
     let kana1: String
     let kana2: String
     let kana3: String
     let prefcode: String
     let zipcode: String
 }


class ViewController: UIViewController {


    @IBOutlet weak var zipCodeSearchBar: UISearchBar!
    @IBOutlet weak var addressTableView: UITableView!
    var results: [Address] = []
    
    let baseUrlStr = "https://zipcloud.ibsnet.co.jp/api/search?zipcode="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        zipCodeSearchBar.delegate = self
        addressTableView.dataSource = self

    }
    
         // MARK: リクエストメソッド
    func requestAddressFromZipCode(zipCode: String) {
    
        var responseData: ZipCloudResponse?       // データ保存用変数
             let urlStr = baseUrlStr + zipCode    // URLに郵便番号を追加
             let url = URL(string: urlStr)!       // URL型に変換
             var request = URLRequest(url: url)   // リクエストを生成
             request.httpMethod = "GET"           // リクエストのHTTPメソッドを設定(GETの場合は省略可)
    
             let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                 guard let data = data else { return }    // dataがなかった場合はreturn
                 do {
                     let decoder = JSONDecoder()
                     responseData = try decoder.decode(ZipCloudResponse.self, from: data)
                 } catch {
                     // do{ }でtryが失敗した場合の処理
                     print(error.localizedDescription)
                 }
                 // 住所情報が合ったら保存
                 if responseData?.results != nil {
                     self.results = (responseData?.results)!  // 取得したdataのresultsを
                 }
                 
                 // TableViewを再表示
                 DispatchQueue.main.async {
                     self.addressTableView.reloadData()
                 }
                 
             }
             task.resume()
         }

}

// MARK: delegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
                requestAddressFromZipCode(zipCode: searchText)
            }
    }

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier:"AddressCell",for: indexPath)
        
            let address = results[indexPath.row]
            cell.textLabel?.text =
            address.address1
            + address.address2
            + address.address3
            + "("
            + address.kana1
            + address.kana2
            + address.kana3
            + ")"
        return cell
    }
    
    
}
