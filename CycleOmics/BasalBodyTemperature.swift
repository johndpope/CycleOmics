
import ResearchKit
import CareKit

/**
 Struct that conforms to the `Assessment` protocol to define a basal body temperature.
 */
struct BasalBodyTemperature: Assessment, HealthQuantitySampleBuilder {
    // MARK: Activity properties
    
    let activityType: ActivityType = .BasalBodyTemp
    
    // MARK: HealthSampleBuilder Properties

    let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBasalBodyTemperature)!
    let unit = HKUnit.degreeFahrenheitUnit()
    
    var quantityStringFormatter: NSNumberFormatter {
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
    }
    
    // MARK: Activity

    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = NSDateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklyScheduleWithStartDate(startDate, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let activity = OCKCarePlanActivity.assessmentWithIdentifier(
            activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: nil,
            tintColor: Colors.Red.color,
            resultResettable: false,
            schedule: schedule,
            userInfo: nil
        )
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
        // Get the localized strings to use for the task.
        let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: self.quantityType, unit:self.unit, style: .Decimal)
        
        // Create a question.
        let title = NSLocalizedString("Input your basal body temperature", comment: "")
        let text = NSLocalizedString("Take your temperature when you first wake up in the morning, before you even sit up in bed.", comment: "")
        let questionStep = ORKQuestionStep(identifier: activityType.rawValue, title: title , text: text , answer: answerFormat)
        questionStep.optional = false
        
        // Create an ordered task with a single question.
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [questionStep])
        
        return task
    }
    
    // MARK: HealthSampleBuilder
    
    /// Builds a `HKQuantitySample` from the information in the supplied `ORKTaskResult`.
    func buildSampleWithTaskResult(result: ORKTaskResult, date:NSDate) -> HKQuantitySample {
        // Get the first result for the first step of the task result.
        guard let firstResult = result.firstResult as? ORKStepResult, stepResult = firstResult.results?.first else { fatalError("Unexepected task results") }
        
        // Get the numeric answer for the result.
        guard let degreeResult = stepResult as? ORKNumericQuestionResult, degreeAnswer = degreeResult.numericAnswer else { fatalError("Unable to determine result answer") }
        
        // Create a `HKQuantitySample` for the answer.
        let quantity = HKQuantity(
            unit: unit,
            doubleValue: degreeAnswer.doubleValue
        )
        
        return HKQuantitySample(
            type: quantityType,
            quantity: quantity,
            startDate: date,
            endDate: date
        )
    }
    
    /**
     Uses an NSNumberFormatter to determine the string to use to represent the
     supplied `HKQuantitySample`.
     */
    func localizedUnitForSample(sample: HKQuantitySample) -> String {
        
        // TODO: find a better way to format temparature units
        switch(unit.unitString) {
            case "degF": return "\u{00B0}F"
            case "degC": return "\u{00B0}C"
            case "degK": return "\u{00B0}K"
            default: return unit.unitString
        }
        
    }

}
