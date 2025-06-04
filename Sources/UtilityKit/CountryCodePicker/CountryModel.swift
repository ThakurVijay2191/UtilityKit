//
//  CountryModel.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 04/06/25.
//

import Foundation

public class CountryModel{
    var countryCode: String?
    var countryName: String?
    var countryShortName: String?
    var countryFlag : String?
}

public class CountryListModel{
    var country: [CountryModel]?
    
    init(_ data: [JSON]) {
        country = [CountryModel]()
        for dt in data {
            let ctyInfo = CountryModel()
            ctyInfo.countryName = dt["name"].stringValue
            ctyInfo.countryCode = dt["dial_code"].stringValue
            ctyInfo.countryShortName = dt["code"].stringValue
            ctyInfo.countryFlag = dt["flag"].stringValue
            country?.append(ctyInfo)
        }
    }
}

func getCountryAndName(_ countryParam: String? = nil) -> CountryModel? {
   if let path = Bundle.main.path(forResource: "CountryCodes", ofType: "json") {
       do {
           let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
           let jsonObj = JSON(data)
           let countryData = CountryListModel.init(jsonObj.arrayValue)
           let locale: Locale = Locale.current
           var countryCode: String?
           if countryParam != nil {
               countryCode = countryParam
           } else {
               countryCode = locale.region?.identifier
           }
           let currentInfo = countryData.country?.filter({ (cm) -> Bool in
               return cm.countryShortName?.lowercased() == countryCode?.lowercased()
           })
           
           if currentInfo!.count > 0 {
               return currentInfo?.first
           } else {
               return nil
           }
           
       } catch {
           // handle error
       }
   }
   return nil
}
