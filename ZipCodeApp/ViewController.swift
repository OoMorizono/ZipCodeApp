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
     
     
     func address() -> String {
         return address1 + address2 + address3
     }
     
     func kana() -> String{
         return kana1 + kana2 + kana3
     }
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
                     print(responseData?.results)
                 } catch {
                     // do{ }でtryが失敗した場合の処理
                     print(error.localizedDescription)
                 }
                 // 住所情報が合ったら保存
                 if responseData?.results != nil {
                     for result in
                            (responseData?.results)! {
                         self.results.append(result)
                     }
                 }
                 
                 DispatchQueue.main.async {
                // 取得したデータから住所情報を取得
                if responseData?.results != nil {
                    self.results = (responseData?.results)!
                } else {
                    self.showAlert(title: "エラー！", message: "存在しない番号です")
                }
                     self.addressTableView.reloadData()
                }
                 
             }
             task.resume()
         }
    
        //正規表現のチェックのためのメソッド(数字で7文字)
         func isZipCode(enteredText: String) -> Bool {
             let pattern = "^[0-9]{7}$"                                                            // パターンを作成
             guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }    // NSRegularExpressionをインスタンス化
             let matches = regex.matches(
                in: enteredText,
                range: NSRange(location:0,
                               length:enteredText.count))    // パターンマッチを確認
             return matches.count == 1 ? true : false                                              // 結果によって真偽値を返す
         }
    
    //アラート表示のメソッド
         func showAlert(title: String, message: String) {
             let alert = UIAlertController(title: title, message: message, preferredStyle: .alert) // 表示作成
             let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)           // ボタン作成
             alert.addAction(alertAction)                                                          // 表示にボタンを追加
             present(alert, animated: true)                                                        // 画面に表示
         }

}

// MARK: delegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //入力したらキーボードを下げる｡
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text else { return }
        guard isZipCode(enteredText: searchText)
        else{
            showAlert(title: "エラー!", message: "数字7文字を入力してください;")
            return
        }
        requestAddressFromZipCode(zipCode: searchText)
        
        }
    }

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier:"AddressCell",for: indexPath)
        
            let address = results[indexPath.row]
                 cell.textLabel?.text = "\(address.address())(\(address.kana()))"

        return cell
    }
    
    
}
