//
//  StressSurvey.swift
//  CycleOmics
//
//  Created by Mojtaba Koosej on 7/6/16.
//  Copyright © 2016 Curio. All rights reserved.
//

import CareKit
import ResearchKit

/**
 Struct that conforms to the `Activity` protocol to define an outdoor walking
 activity.
 */
struct FingerBloodSpot: TubeSample {
    // MARK: Activity
    
    let activityType: ActivityType = .FingerBloodSpot
    let title = NSLocalizedString("Finger Blood Spot", comment: "")
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = NSDateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklyScheduleWithStartDate(startDate, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the activity.
        let title = NSLocalizedString("Finger blood spot", comment: "")
        let summary = NSLocalizedString("Add 80ul of blood", comment: "")
        
        let text = "1) To ensure a good finger stick: Warm water washing for 1mi.n\n\n" +
        "2) Vigorously massaging or rubbing the fingertip for 30 seconds.\n\n" +
        "Remember to select either the middle or ring finger on the non-dominant hand. Avoid calluses and the “pad” of the fingertip. The fleshy side of the fingertip is the ideal spot to place the lancet for the finger stick.\n\n" +
        "3) Anchor your hand against a firm surface before using the  lancet.\n\n" +
        "4) Use lancet to prick fleshy side of middle or ring finger.\n\n" +
        "5) Apply pressure around fingerprick if needed to encourage blood flow.\n\n" +
        "6) Touch 80ul capillary tube to the blood (do not squeeze dropper part yet!).\n\n" +
        "7) If bubble appears in capillary tube, repeat with a new tube.\n\n" +
        "8) After capillary tube full, squeeze dropper to deposit blood into center of a HemaSpot. Add daily, from plate 1 to 2, position A1 to A2.\n\n" +
        "9) Label the date and time on the cover of the plate at today’s blood spot position.\n\n"
        
        let instructions = NSLocalizedString(text , comment: "")
        let imageUrl = NSBundle.mainBundle().URLForResource("fingerBloodSample", withExtension: "png")
        
        // Create the intervention activity.
        let activity = OCKCarePlanActivity.interventionWithIdentifier(
            activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: summary,
            tintColor: Colors.Red.color,
            instructions: instructions,
            imageURL: imageUrl,
            schedule: schedule,
            userInfo: nil
        )
        
        return activity
    }
    
    func task() -> ORKTask {
        // Get the localized strings to use for the task.
        let question = NSLocalizedString("Please enter the tube number you are using for sampling", comment: "")
        
        let questionStep = ORKQuestionStep(identifier: activityType.rawValue, title: title, text: question, answer: ORKAnswerFormat.integerAnswerFormatWithUnit(nil))
        questionStep.optional = false
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [questionStep])
        
        return task
    }

}
