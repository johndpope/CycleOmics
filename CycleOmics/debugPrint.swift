//
//  debugPrint.swift
//  CycleOmics
//
//  Created by Mojtaba Koosej on 8/25/16.
//  Copyright © 2016 Curio. All rights reserved.
//

#if !arch(x86_64) && !arch(i386)
    
    func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
    func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {}
    
#endif
