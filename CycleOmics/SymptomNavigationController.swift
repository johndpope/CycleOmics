//
//  SymptomNavigationController.swift
//  CycleOmics
//
//  Created by Mojtaba Koosej on 6/23/16.
//  Copyright © 2016 Curio. All rights reserved.
//

import UIKit
import ResearchKit
import CareKit


class SymptomNavigationController: UINavigationController {
    
    fileprivate let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
    fileprivate let sampleData: SampleData
    fileprivate var symptomTrackerViewController: OCKSymptomTrackerViewController!

    required init?(coder aDecoder: NSCoder) {

        sampleData = SampleData(carePlanStore: storeManager.store)
        super.init(coder: aDecoder)
        
        symptomTrackerViewController = createSymptomTrackerViewController()

        self.pushViewController(symptomTrackerViewController, animated: true)        
    }
    
    fileprivate func createSymptomTrackerViewController() -> OCKSymptomTrackerViewController {
        let viewController = OCKSymptomTrackerViewController(carePlanStore: storeManager.store)
        viewController.delegate = self
        
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Symptom Tracker", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"symptoms"), selectedImage: UIImage(named: "symptoms-filled"))
        
        return viewController
    }
}


extension SymptomNavigationController: OCKSymptomTrackerViewControllerDelegate {
    
    /// Called when the user taps an assessment on the `OCKSymptomTrackerViewController`.
    func symptomTrackerViewController(_ viewController: OCKSymptomTrackerViewController, didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
        
        // Lookup the assessment the row represents.
        guard let activityType = ActivityType(rawValue: assessmentEvent.activity.identifier) else { return }
        guard let sampleAssessment = sampleData.activityWithType(activityType) as? Assessment else { return }
        
        /*
         Check if we should show a task for the selected assessment event
         based on its state.
         */
        guard assessmentEvent.state == .initial ||
            assessmentEvent.state == .notCompleted ||
            (assessmentEvent.state == .completed && assessmentEvent.activity.resultResettable) else { return }
        
        // Show an `ORKTaskViewController` for the assessment's task.
        let taskViewController = ORKTaskViewController(task: sampleAssessment.task(), taskRun: nil)
        taskViewController.delegate = self
        
        present(taskViewController, animated: true, completion: nil)
    }
}


extension SymptomNavigationController: ORKTaskViewControllerDelegate {
    
    /// Called with then user completes a presented `ORKTaskViewController`.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        // Make sure the reason the task controller finished is that it was completed.
        guard reason == .completed else {
            debugPrint("The task with id \(taskViewController.task?.identifier) has been canceled")
            return
        }
        
        // Determine the event that was completed and the `SampleAssessment` it represents.
        guard let event = symptomTrackerViewController.lastSelectedAssessmentEvent,
            let activityType = ActivityType(rawValue: event.activity.identifier),
            let sampleAssessment = sampleData.activityWithType(activityType) as? Assessment else {
                debugPrint("Error in capturing even values")
                return
        }
        
        guard let date = Calendar.current.date(from: event.date) else {
            debugPrint("Error in capturing even date")
            return
        }
        
        // Check assessment can be associated with a HealthKit sample.
        if let healthSampleBuilder = sampleAssessment as? HealthQuantitySampleBuilder {
            // Build the sample to save in the HealthKit store.
            
            let sample = healthSampleBuilder.buildSampleWithTaskResult(taskViewController.result, date: date)
            let sampleTypes: Set<HKSampleType> = [sample.sampleType]
            
            let carePlanResult = sampleAssessment.buildResultForCarePlanEvent(event, taskResult: taskViewController.result)
            
            //Save the quantity sample to HKStore
            saveSampleHealthStore(sampleTypes, sample: sample, event: event, carePlanResult: carePlanResult, completionBlock: {
                
                //Save the quantity sample to CarePlanStore  
                let healthKitAssociatedResult = OCKCarePlanEventResult(
                    quantitySample: sample,
                    quantityStringFormatter: healthSampleBuilder.quantityStringFormatter,
                    display: healthSampleBuilder.unit,
                    displayUnitStringKey: healthSampleBuilder.localizedUnitForSample(sample),
                    userInfo: nil
                )
                
                self.completeEvent(event, inStore: self.storeManager.store, withResult: healthKitAssociatedResult)
            })
        }
        else if let healthSampleBuilder = sampleAssessment as? HealthCategorySampleBuilder {
            // Build the sample to save in the HealthKit store.
            
            if(healthSampleBuilder.shouldIgnoreSample(taskViewController.result)) { //for conditional tasks that doesn't require sampling
                
                let carePlanResult = sampleAssessment.buildResultForCarePlanEvent(event, taskResult: taskViewController.result)
                self.completeEvent(event, inStore: self.storeManager.store, withResult: carePlanResult)
                return
            }
            
            let sample = healthSampleBuilder.buildSampleWithTaskResult(taskViewController.result,date: date)
            let sampleTypes: Set<HKSampleType> = [sample.sampleType]
            let carePlanResult = sampleAssessment.buildResultForCarePlanEvent(event, taskResult: taskViewController.result)
            
            //Save the category sample to HKStore
            saveSampleHealthStore(sampleTypes, sample: sample, event: event, carePlanResult: carePlanResult, completionBlock: {
                
                let healthKitAssociatedResult = OCKCarePlanEventResult(categorySample: sample, categoryValueStringKeys: carePlanResult.categoryValueStringKeys!, userInfo: nil)
                self.completeEvent(event, inStore: self.storeManager.store, withResult: healthKitAssociatedResult)
            })
        }
        else {
            // Update the event with the result.
            
            // Build an `OCKCarePlanEventResult` that can be saved into the `OCKCarePlanStore`.
            let carePlanResult = sampleAssessment.buildResultForCarePlanEvent(event, taskResult: taskViewController.result)
            completeEvent(event, inStore: storeManager.store, withResult: carePlanResult)
        }
    }
    
    // MARK: Convenience
    
    fileprivate func completeEvent(_ event: OCKCarePlanEvent, inStore store: OCKCarePlanStore, withResult result: OCKCarePlanEventResult) {
        store.update(event, with: result, state: .completed) { success, _, error in
            if !success {
                debugPrint(error?.localizedDescription)
            }
        }
    }
    
    fileprivate func saveSampleHealthStore(_ sampleTypes: Set<HKSampleType>, sample: HKSample, event: OCKCarePlanEvent , carePlanResult: OCKCarePlanEventResult , completionBlock: @escaping (Void)->Void ) {
        
        // Requst authorization to store the HealthKit sample.
        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: sampleTypes, read: sampleTypes, completion: { success, _ in
            // Check if authorization was granted.
            if !success {
                /*
                 Fall back to saving the simple `OCKCarePlanEventResult`
                 in the `OCKCarePlanStore`.
                 */
                self.completeEvent(event, inStore: self.storeManager.store, withResult: carePlanResult)
                return
            }
            
            // Save the HealthKit sample in the HealthKit store.
            healthStore.save(sample, withCompletion: { success, _ in
                if success {
                    completionBlock()
                }
                else {
                    /*
                     Fall back to saving the simple `OCKCarePlanEventResult`
                     in the `OCKCarePlanStore`.
                     */
                    self.completeEvent(event, inStore: self.storeManager.store, withResult: carePlanResult)
                }
            })
        })
    }
}
