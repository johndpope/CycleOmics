//
//  HealthCategorySampleBuilder.swift
//  CycleOmics
//
//  Created by Mojtaba Koosej on 7/5/16.
//  Copyright © 2016 Curio. All rights reserved.
//

import ResearchKit
import CareKit
/**
 A protocol that defines the methods and properties required to be able to save
 an `ORKTaskResult` to a `ORKCarePlanStore` with an associated `HKCategorySample`.
 */
protocol HealthCategorySampleBuilder {
    
    var categotyType: HKCategoryType { get }
    var value: Int { get }
    func buildSampleWithTaskResult(result: ORKTaskResult) -> HKCategorySample
    func buildCategoricalResultForCarePlanEvent(event: OCKCarePlanEvent, taskResult: ORKTaskResult) -> OCKCarePlanEventResult
}

