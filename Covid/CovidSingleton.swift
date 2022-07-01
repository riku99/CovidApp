import Foundation

// シングルトン。アプリでデータを保持するための実装方法
// 指定したクラスのインスタンスが絶対に1個しか存在しないことを保証するもの
class CovidSingleton {
    // イニシャライザをprivateにすることによりインスタンスの生成を防ぐ
    private init() {}
    
    // staticは全てのインスタンスで共通で、必ず1つしか存在しない
    static let shared = CovidSingleton()
    var prefecture: [CovidInfo.Prefecture] = []
}
