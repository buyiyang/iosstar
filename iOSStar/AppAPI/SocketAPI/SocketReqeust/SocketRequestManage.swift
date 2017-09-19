//
//  SocketPacketManage.swift
//  viossvc
//
//  Created by yaowang on 2016/11/22.
//  Copyright © 2016年 ywwlcom.yundian. All rights reserved.
//

import UIKit
//import XCGLogger

class SocketRequestManage: NSObject {
    
    static let shared = SocketRequestManage();
    fileprivate var socketRequests = [UInt64: SocketRequest]()
    fileprivate var _timer: Timer?
    fileprivate var _lastHeardBeatTime:TimeInterval!
    fileprivate var _lastConnectedTime:TimeInterval!
    fileprivate var _reqeustId:UInt32 = 10000
    fileprivate var _socketHelper:SocketHelper?
    fileprivate var _sessionId:UInt64 = 0
    
    fileprivate var timelineRequest: SocketRequest?
    var receiveMatching:CompleteBlock?
    var receiveOrderResult:CompleteBlock?

    var operate_code = 0
    func start() {
        _lastHeardBeatTime = timeNow()
        _lastConnectedTime = timeNow()
        stop()
        _timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(didActionTimer), userInfo: nil, repeats: true)
#if true
        _socketHelper = APISocketHelper()
#else
        _socketHelper = LocalSocketHelper()
#endif
        
        _socketHelper?.connect()
    }
    
    func  stop() {
        _timer?.invalidate()
        _timer = nil
        objc_sync_enter(self)
        _socketHelper?.disconnect()
        _socketHelper = nil
        objc_sync_exit(self)
    }
    
    var sessionId:UInt64 {
        get {
            objc_sync_enter(self)
            if _sessionId > 2000000000 {
                _sessionId = 10000
            }
            _sessionId += 1
            objc_sync_exit(self)
            return _sessionId;
        }
        
    }

    func notifyResponsePacket(_ packet: SocketDataPacket) {
        
        objc_sync_enter(self)
        var  socketReqeust = socketRequests[packet.session_id]
        if packet.operate_code == SocketConst.OPCode.timeLine.rawValue + 1{
            socketReqeust = timelineRequest
        }else if packet.operate_code == SocketConst.OPCode.receiveMatching.rawValue {
            let response:SocketJsonResponse = SocketJsonResponse(packet:packet)
            if receiveMatching != nil{
                receiveMatching!(response)
            }
        }else if packet.operate_code == SocketConst.OPCode.orderResult.rawValue{
            let response:SocketJsonResponse = SocketJsonResponse(packet:packet)
            if receiveOrderResult != nil{
                receiveOrderResult!(response)
            }
        }else if packet.operate_code == SocketConst.OPCode.onlyLogin.rawValue{
            stop()
            NotificationCenter.default.post(name: Notification.Name.init(rawValue: AppConst.NoticeKey.onlyLogin.rawValue), object: nil, userInfo: nil)
        }else{
            socketRequests.removeValue(forKey: packet.session_id)
        }
        objc_sync_exit(self)
        let response:SocketJsonResponse = SocketJsonResponse(packet:packet)
        let statusCode:Int = response.statusCode;
        if statusCode == AppConst.frozeCode{
            ShareDataModel.share().controlSwitch = false
            return
        }
        if response.result < 0{
            socketReqeust?.onError(response.result)
            return
        }
        if ( statusCode < 0) && packet.data?.count != 0 {
            socketReqeust?.onError(statusCode)
        } else {
            socketReqeust?.onComplete(response)
        }
    }
    
    
    func checkReqeustTimeout() {
        objc_sync_enter(self)
        for (key,reqeust) in socketRequests {
            if reqeust.isReqeustTimeout() {
                socketRequests.removeValue(forKey: key)
                reqeust.onError(-11011)
                print(">>>>>>>>>>>>>>>>>>>>>>>>>>\(key)")
                break
            }
        }
        objc_sync_exit(self)
    }
    
    
    fileprivate func sendRequest(_ packet: SocketDataPacket) {
        let block:()->() = {
            [weak self] in
            self?._socketHelper?.sendData(packet.serializableData()!)
        }
        objc_sync_enter(self)
        if _socketHelper == nil {
            SocketRequestManage.shared.start()
            let when = DispatchTime.now() + Double((Int64)(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when,execute: block)
        }
        else {
            block()
        }
        objc_sync_exit(self)
    }
    
    func startJsonRequest(_ packet: SocketDataPacket, complete: CompleteBlock?, error: ErrorBlock?) {

        let socketReqeust = SocketRequest();
        socketReqeust.error = error;
        socketReqeust.complete = complete;
        packet.request_id = 0;
        packet.session_id = sessionId;
        operate_code = Int(packet.operate_code)
        objc_sync_enter(self)
        if packet.operate_code ==  SocketConst.OPCode.timeLine.rawValue{
            timelineRequest = socketReqeust
        } else {
            socketRequests[packet.session_id] = socketReqeust
        }

        objc_sync_exit(self)
        sendRequest(packet)
    }
  
    fileprivate func timeNow() ->TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    fileprivate func lastTimeNow(_ last:TimeInterval) ->TimeInterval {
        return timeNow() - last
    }
    
    fileprivate func isDispatchInterval(_ lastTime:inout TimeInterval,interval:TimeInterval) ->Bool {
        if timeNow() - lastTime >= interval  {
            lastTime = timeNow()
            return true
        }
        return false
    }
    
    
    fileprivate func sendHeart() {
        let packet = SocketDataPacket(opcode: .heart,dict:[SocketConst.Key.uid: 0 as AnyObject])
        sendRequest(packet)
    }
    
    func didActionTimer() {
        if _socketHelper != nil && _socketHelper!.isConnected {
            _lastConnectedTime = timeNow()
        }
        else if( isDispatchInterval(&_lastConnectedTime!,interval: 10) ) {
            _socketHelper?.connect()
        }
        checkReqeustTimeout()
    }

}
