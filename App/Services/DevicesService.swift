//
//  DevicesService.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import PromiseKit

class DevicesService: Service, DevicesServiceProtocol {
    func register(deviceToken: Data, userId: Int) -> Promise<Void> {
        let form = UserDeviceTokenUpdatingForm(userId: userId, token: deviceToken.hexString())
        return request(APIRoute.updateDeviceToken(form: form))
    }
}
