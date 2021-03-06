//
//  GalleryKits.swift
//  Electsys Utility
//
//  Created by 法好 on 2019/9/17.
//  Copyright © 2019 yuxiqian. All rights reserved.
//

import Alamofire
import Alamofire_SwiftyJSON
import Foundation
import SwiftyJSON

class GalleryKits {
    static var courseList: [NGCurriculum] = []
    static let emptyCurriculum = NGCurriculum(identifier: "",
                                              code: "",
                                              holderSchool: "",
                                              name: "",
                                              year: 0,
                                              term: 0,
                                              targetGrade: 0,
                                              teacher: [],
                                              credit: 0.0,
                                              arrangements: [],
                                              studentNumber: 0,
                                              notes: "")

    fileprivate static let betaJsonHeader = "https://raw.githubusercontent.com/yuetsin/NG-Course/be-ta/release/"
    fileprivate static let stableJsonHeader = "https://raw.githubusercontent.com/yuetsin/NG-Course/master/release/"

    static var possibleUrl: String?
    static func requestGalleryData(year: Int, term: Int, beta: Bool = false,
                                   handler: @escaping (String) -> Void,
                                   failure: @escaping (Int) -> Void) {
        var requestUrl: String?
        if beta {
            requestUrl = "\(betaJsonHeader)\(year)_\(year + 1)_\(term).json"
        } else {
            requestUrl = "\(stableJsonHeader)\(year)_\(year + 1)_\(term).json"
        }
        GalleryKits.possibleUrl = requestUrl
        Alamofire.request(requestUrl!,
                          method: .get).responseSwiftyJSON { responseJSON in
            if responseJSON.error == nil {
                let jsonResp = responseJSON.value
                if jsonResp != nil {
                    let timeStamp = jsonResp?["generate_time"].stringValue

                    GalleryKits.courseList.removeAll()
                    for curObject in jsonResp?["data"].arrayValue ?? [] {
                        var arrangements: [NGArrangements] = []
                        for arrObject in curObject["arrangements"].arrayValue {
                            var weeksInt: [Int] = []
                            var sessionsInt: [Int] = []
                            for weekObj in arrObject["weeks"].arrayValue {
                                weeksInt.append(weekObj.intValue)
                            }
                            for sessionObj in arrObject["sessions"].arrayValue {
                                sessionsInt.append(sessionObj.intValue)
                            }
                            let arrangement = NGArrangements(weeks: weeksInt,
                                                             weekDay: arrObject["week_day"].intValue,
                                                             sessions: sessionsInt,
                                                             campus: arrObject["campus"].stringValue,
                                                             classroom: arrObject["classroom"].stringValue)
                            if !arrangements.contains(arrangement) {
                                arrangements.append(arrangement)
                            }
                        }

                        var teachersLiteral: [String] = []
                        for teacherObject in curObject["teacher"].arrayValue {
                            teachersLiteral.append(teacherObject.stringValue)
                        }
                        GalleryKits.courseList.append(NGCurriculum(identifier: curObject["identifier"].stringValue,
                                                      code: curObject["code"].stringValue,
                                                      holderSchool: curObject["holder_school"].stringValue,
                                                      name: curObject["name"].stringValue,
                                                      year: curObject["year"].intValue,
                                                      term: curObject["term"].intValue,
                                                      targetGrade: curObject["target_grade"].intValue,
                                                      teacher: teachersLiteral,
                                                      credit: curObject["credit"].doubleValue,
                                                      arrangements: arrangements,
                                                      studentNumber: curObject["student_number"].intValue,
                                                      notes: curObject["notes"].stringValue))
                    }
                    handler(timeStamp ?? "")
                } else {
                    failure(-3)
                }
            } else {
                failure(-2)
            }
        }
    }
}
