//
//  Service.swift
//  SmartControlAssignment
//
//  Created by Shibili Areekara on 18/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import Foundation




public enum RequestMethod : String {
    case GET = "GET"
    case POST = "POST"
}

public enum BaseUrl : String {
    case baseUrl = "https://backend.klickcheck.com"
}

public enum RelativeUrl : String {
    case login = "/api/login"
    case machineList = "/api/assets"
}

public enum ServiceStatus : String {
    case SUCCESS = "success"
    case FAILED = "failed"
    case SERVICE_ERROR = "Service Error"
    case ERROR = "Error"
}

public struct AuthDetails {
    static var name = "christoph.halang+apple@z-lab.com"
    static var password = "someTEST"
}

private enum AuthParameters : String {
    case email = "email"
    case password = "password"
}

private enum DataParameters : String {
    case page = "page"
    case limit = "limit"
    case companyId = "company_id"
}

private var _url : String = ""
private var _statusCode : Int = 0
private var _httpStatusCode:Int?
private var _timeOutInterval: Int = 15
private var _allowCelllarAccess:Bool = true
var _requestMethod:String = RequestMethod.GET.rawValue

private var _companyId : Int = 0
private var _token : String = ""

/// Service Class to Handle API calls
open class Service :NSObject  {
	
    
	open class var timeOutInterval : Int {
		get {return _timeOutInterval}
		set {_timeOutInterval = newValue}
	}
	
    
	open class var allowCellularAccess : Bool {
		get {return _allowCelllarAccess}
		set {_allowCelllarAccess = newValue}
	}
    
    open func setConfigUrl(_ value:String) {
        _url = value;
    }

    open func requestMethod(_ value:String) {
        _requestMethod = value
    }
    
    open func setCompanyId(_ value:Int) {
        _companyId = value;
    }
    
    open func setToken(_ value:String) {
        _token = value;
    }
    
    func loginUser(email:String, password:String, _ completion:@escaping (_ data:Data?,_ action:String,_ serviceStatus:String) -> Void) {
        guard let myUrl:URL = URL(string: _url) else { return }
        
        let request = NSMutableURLRequest(url: myUrl)
        request.httpMethod = _requestMethod
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let parameters: [String: Any] = [
            AuthParameters.email.rawValue: email,
            AuthParameters.password.rawValue: password
        ]
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
        self.execute(request: request as URLRequest, { (data, response, error) in
            completion(data, response, error)
        })
    }
    
    func getMachineList(_ completion:@escaping (_ data:Data?,_ action:String,_ serviceStatus:String) -> Void) {
        guard let myUrl:URL = URL(string: _url) else { return }
        
        let request = NSMutableURLRequest(url: myUrl)
        request.httpMethod = _requestMethod
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("Bearer \(_token)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = [
            DataParameters.page.rawValue: 1,
            DataParameters.limit.rawValue: 100,
            DataParameters.companyId.rawValue: _companyId,
            
        ]
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
        self.execute(request: request as URLRequest, { (data, response, error) in
            completion(data, response, error)
        })
    }
    
    func execute(request: URLRequest, _ completion:@escaping (_ data:Data?,_ action:String,_ serviceStatus:String) -> Void) {
        
        let session = URLSession(configuration : sessionConfiguration())
		
        let task = session.dataTask(with: request as URLRequest){
        (data, response, error) in
            if  error != nil {
                print("error ==\(String(describing:  error?.localizedDescription))")
                completion(data, (error?.localizedDescription)!,ServiceStatus.FAILED.rawValue)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                _httpStatusCode = httpResponse.statusCode
                print(_httpStatusCode!)
                if (_httpStatusCode == 200) {
                    completion(data, "",ServiceStatus.SUCCESS.rawValue)
                }
                else  if (_httpStatusCode == 500 )
                {
                    completion(data, ServiceStatus.SERVICE_ERROR.rawValue, ServiceStatus.FAILED.rawValue)
                }
                else  {
                    completion(data, ServiceStatus.ERROR.rawValue, ServiceStatus.FAILED.rawValue)
                }

            }
        }
        task.resume()
    }


	fileprivate func sessionConfiguration() -> URLSessionConfiguration {
		let configuration = URLSessionConfiguration.default
		configuration.allowsCellularAccess = _allowCelllarAccess
		configuration.timeoutIntervalForRequest = TimeInterval(_timeOutInterval)
		configuration.timeoutIntervalForResource = 15
		return configuration
	}
	
}


private extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

private extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}



