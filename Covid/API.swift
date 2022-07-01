import UIKit

struct CovidAPI {
    // staticで静的メソッド
    // @escapingは引数に渡されるクロージャに付与することができるキーワード。関数が終了してもこのスコープのデータを参照する必要がある時に使用する
    static func getTotal(completion: @escaping (CovidInfo.Total) -> Void) {
        let url = URL(string: "https://covid19-japan-web-api.vercel.app/api/v1/total")
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("error:\(error!.localizedDescription)")
            }
            
            // if letは右辺にデータが存在する場合は左辺に代入され {} 内が実行される
            if let data = data {
                // try! は確実にエラーが起こらないことを保証している。エラー出たらクラッシュする。
                let result = try! JSONDecoder().decode(CovidInfo.Total.self, from: data)
                completion(result)
            }
        }.resume()
    }
    
    static func getPrefecture(completion: @escaping ([CovidInfo.Prefecture]) -> Void) {
        let url = URL(string: "https://covid19-japan-web-api.vercel.app/api/v1/prefectures")
        let request = URLRequest(url: url!)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                let result = try! JSONDecoder().decode([CovidInfo.Prefecture].self, from: data)
                completion(result)
            }
        }.resume()
    }
}
