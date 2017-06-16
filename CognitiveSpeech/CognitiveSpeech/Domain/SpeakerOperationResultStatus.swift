//
//  SpeakerOperationResultStatus.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/15/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

enum SpeakerOperationResultStatus : String {
	case notstarted	// The operation is not started.
	case running 	// The operation is running.
	case failed 	// The operation is finished and failed.
	case succeeded 	// The operation is finished and succeeded.
}
