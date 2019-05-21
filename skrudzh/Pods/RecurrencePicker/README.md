# RecurrencePicker

[![CI Status](https://img.shields.io/travis/petalvlad@gmail.com/RecurrencePicker.svg?style=flat)](https://travis-ci.org/petalvlad@gmail.com/RecurrencePicker)
[![Version](https://img.shields.io/cocoapods/v/RecurrencePicker.svg?style=flat)](https://cocoapods.org/pods/RecurrencePicker)
[![License](https://img.shields.io/cocoapods/l/RecurrencePicker.svg?style=flat)](https://cocoapods.org/pods/RecurrencePicker)
[![Platform](https://img.shields.io/cocoapods/p/RecurrencePicker.svg?style=flat)](https://cocoapods.org/pods/RecurrencePicker)

An event recurrence rule picker similar to iOS system calendar. 

![Example](https://github.com/teambition/RecurrencePicker/raw/master/Gif/RecurrencePickerExample.gif "RecurrencePickerExample")

## Installation

RecurrencePicker is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RecurrencePicker'
```

### Usage
#### Import necessary frameworks
```swift
import RRuleSwift
import EventKit
import RecurrencePicker
```

####  Initialization and Configuration
```swift
// prepare a recurrence rule and an occurrence date
// occurrence date is the date which the repeat event occurs this time
let recurrenceRule = ...
let occurrenceDate = ...

// initialization and configuration
// RecurrencePicker can be initialized with a recurrence rule or nil, nil means "never repeat"
let recurrencePicker = RecurrencePicker(recurrenceRule: recurrenceRule)
recurrencePicker.language = .english
recurrencePicker.calendar = Calendar.current
recurrencePicker.tintColor = UIColor.blue
recurrencePicker.occurrenceDate = occurrenceDate

// assign delegate
recurrencePicker.delegate = self

// push to the picker scene
navigationController?.pushViewController(recurrencePicker, animated: true)
```

####  Implement the delegate
```swift
func recurrencePicker(_ picker: RecurrencePicker, didPickRecurrence recurrenceRule: RecurrenceRule?) {
    // do something, if recurrenceRule is nil, that means "never repeat".
}
```

## Minimum Requirement
iOS 10.0

## Localization
RecurrencePicker supports 6 languages: English, Russian, Simplified Chinese, Traditional Chinese, Korean, Japanese. You can set the language when initialization.

You can also get a localized rule text string like this:
```swift
let ruleString = "RRULE:FREQ=WEEKLY;INTERVAL=2;WKST=MO;DTSTART=20160413T133011Z;BYDAY=TU,WE,FR"
let recurrenceRule = RecurrenceRule(rruleString: ruleString)
let language: RecurrencePickerLanguage = ...
let recurrenceRuleText = recurrenceRule?.toText(of: language, occurrenceDate: Date())
print(recurrenceRuleText)
// Event will occur every 2 weeks on Tuesday, Wednesday and Friday.
// 事件将每2周于星期二、星期三和星期五重复一次。
// 行程每2週的星期二、星期三和星期五重複一次。
// 2주마다 화요일, 수요일 및 금요일에 이벤트 반복
// 2週間ごとに、火曜日、水曜日と金曜日にあるイベントです。
```

## Author

Original version https://github.com/teambition/RecurrencePicker

## License

RecurrencePicker is available under the MIT license. See the LICENSE file for more info.
