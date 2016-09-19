/*
Copyright (c) 2015, Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3.  Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import ResearchKit

class ConsentDocument: ORKConsentDocument {
    // MARK: Properties
    
    let steps = [
        "This simple walkthrough will explain the research study, the impact it may have on your life and will allow you to provide your consent to participate.",
        "Stanford Medicine (“Stanford”) and the CycleOmics research team know you care about how your information is used and shared. We take protecting your privacy very seriously.",
        "For the purpose of the study, you should take required samples in a daily basis. You should keep samples hard frozen after sample collection for storage and transportation",
        "Some of the tasks in this study will require you to answer survey questions about health and lifesttyle factors.",
        "Your coded study will be used for research by Stanford and may be shared with other researchers approved by Stanford."
    ]
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        title = NSLocalizedString("Research Health Study Consent Form", comment: "")
        
        let sectionTypes: [ORKConsentSectionType] = [
            .overview,
            .privacy,
            .studyTasks,
            .studySurvey,
            .dataUse
        ]
        
        sections = zip(sectionTypes, steps).map { sectionType, steps in
            let section = ORKConsentSection(type: sectionType)
            
            let localizedIpsum = NSLocalizedString(steps, comment: "")
            let localizedSummary = localizedIpsum
            
            section.summary = localizedSummary
            section.content = localizedIpsum
            
            if(section.type == ORKConsentSectionType.privacy) {
                
                section.contentURL = URL(string: "https://people.stanford.edu/rkellogg/cycleomics-privacy-policy")
            }
            else {
                section.customLearnMoreButtonTitle = ""
            }
            
            return section
        }
        
        sections?.first?.customLearnMoreButtonTitle = ""

        let signature = ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature")
        addSignature(signature)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ORKConsentSectionType: CustomStringConvertible {

    public var description: String {
        switch self {
            case .overview:
                return "Overview"
                
            case .dataGathering:
                return "DataGathering"
                
            case .privacy:
                return "Privacy"
                
            case .dataUse:
                return "DataUse"
                
            case .timeCommitment:
                return "TimeCommitment"
                
            case .studySurvey:
                return "StudySurvey"
                
            case .studyTasks:
                return "StudyTasks"
                
            case .withdrawing:
                return "Withdrawing"
                
            case .custom:
                return "Custom"
                
            case .onlyInDocument:
                return "OnlyInDocument"
        }
    }
}
