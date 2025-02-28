/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

@testable import Glean
import XCTest

// The event extra keys.
// This would be generated by the glean_parser usually.
enum ClickKeys: Int32, ExtraKeys {
    case objectId = 0
    case other = 1

    public func index() -> Int32 {
        return self.rawValue
    }
}

// The event extra properties.
// This would be generated by the glean_parser usually.
struct ClickExtras: EventExtras {
    var objectId: String?
    var other: String?

    func toFfiExtra() -> ([Int32], [String]) {
        var keys = [Int32]()
        var values = [String]()

        if let objectId = self.objectId {
            keys.append(0)
            values.append(objectId)
        }
        if let other = self.other {
            keys.append(1)
            values.append(other)
        }

        return (keys, values)
    }
}

enum TestNameKeys: Int32, ExtraKeys {
    case testName = 0

    public func index() -> Int32 {
        return self.rawValue
    }
}

enum SomeExtraKeys: Int32, ExtraKeys {
    case someExtra = 0

    public func index() -> Int32 {
        return self.rawValue
    }
}

// swiftlint:disable force_cast
// REASON: Used in a test
class EventMetricTypeTests: XCTestCase {
    var expectation: XCTestExpectation?
    var lastPingJson: [String: Any]?

    private func setupHttpResponseStub() {
        stubServerReceive { pingType, json in
            if pingType != "events" {
                // Skip non-events pings here.
                // This might include the initial "active" baseline ping.
                return
            }

            XCTAssert(json != nil)
            self.lastPingJson = json

            // Fulfill test's expectation once we parsed the incoming data.
            DispatchQueue.main.async {
                // Let the response get processed before we mark the expectation fulfilled
                self.expectation?.fulfill()
            }
        }
    }

    override func setUp() {
        resetGleanDiscardingInitialPings(testCase: self, tag: "EventMetricTypeTests")
    }

    override func tearDown() {
        lastPingJson = nil
        expectation = nil
        tearDownStubs()
    }

    func testEventSavesToStorage() {
        // Note: We specify both `Keys` and `Extras` here to ease testing.
        // In user code only _one_ will be specified and the other will be its `NoExtra` variant,
        // thus only allowing either the old API or the new one.
        let metric = EventMetricType<ClickKeys, ClickExtras>(
            category: "ui",
            name: "click",
            sendInPings: ["store1"],
            lifetime: .ping,
            disabled: false,
            allowedExtraKeys: ["object_id", "other"]
        )

        XCTAssertFalse(metric.testHasValue())

        // Newer API
        metric.record(ClickExtras(objectId: "buttonA", other: "foo"))
        // Some extra keys can be left undefined.
        metric.record(ClickExtras(objectId: "buttonA"))

        /* SKIPPED: resetting system clock to return fixed time value */

        // Old API, this is available only because we manually implemented the enum.
        // Generated code will have only one of the APIs available.
        metric.record(extra: [.objectId: "buttonB", .other: "bar"])

        XCTAssert(metric.testHasValue())
        let events = try! metric.testGetValue()
        XCTAssertEqual(3, events.count)

        XCTAssertEqual("ui", events[0].category)
        XCTAssertEqual("click", events[0].name)
        XCTAssertEqual("buttonA", events[0].extra?["object_id"])
        XCTAssertEqual("foo", events[0].extra?["other"])

        XCTAssertEqual("ui", events[1].category)
        XCTAssertEqual("click", events[1].name)
        XCTAssertEqual("buttonA", events[1].extra?["object_id"])
        XCTAssertEqual(nil, events[1].extra?["other"])

        XCTAssertEqual("ui", events[2].category)
        XCTAssertEqual("click", events[2].name)
        XCTAssertEqual("buttonB", events[2].extra?["object_id"])
        XCTAssertEqual("bar", events[2].extra?["other"])

        XCTAssertLessThanOrEqual(events[0].timestamp, events[1].timestamp, "The sequence of events must be preserved")
    }

    func testEventRecordedWithEmptyCategory() {
        let metric = EventMetricType<ClickKeys, NoExtras>(
            category: "",
            name: "click",
            sendInPings: ["store1"],
            lifetime: .ping,
            disabled: false,
            allowedExtraKeys: ["object_id"]
        )

        XCTAssertFalse(metric.testHasValue())

        metric.record(extra: [.objectId: "buttonA"])

        /* SKIPPED: resetting system clock to return fixed time value */

        metric.record(extra: [.objectId: "buttonB"])

        XCTAssert(metric.testHasValue())
        let events = try! metric.testGetValue()
        XCTAssertEqual(2, events.count)

        XCTAssertEqual("click", events[0].identifier)
        XCTAssertEqual("click", events[1].identifier)

        XCTAssertLessThanOrEqual(events[0].timestamp, events[1].timestamp, "The sequence of events must be preserved")
    }

    func testEventNotRecordedWhenDisabled() {
        let metric = EventMetricType<ClickKeys, NoExtras>(
            category: "ui",
            name: "click",
            sendInPings: ["store1"],
            lifetime: .ping,
            disabled: true
        )

        // Attempt to store the event.
        metric.record()

        // Check that nothing was recorded.
        XCTAssertFalse(metric.testHasValue(), "Events must not be recorded if they are disabled")
    }

    func testCounterGetValueThrowsExceptionIfNothingIsStored() {
        let metric = EventMetricType<ClickKeys, NoExtras>(
            category: "ui",
            name: "click",
            sendInPings: ["store1"],
            lifetime: .ping,
            disabled: false
        )

        XCTAssertThrowsError(try metric.testGetValue()) { error in
            XCTAssertEqual(error as! String, "Missing value")
        }
    }

    func testEventSavesToSecondaryPings() {
        let metric = EventMetricType<ClickKeys, NoExtras>(
            category: "ui",
            name: "click",
            sendInPings: ["store1", "store2"],
            lifetime: .ping,
            disabled: false,
            allowedExtraKeys: ["object_id"]
        )

        XCTAssertFalse(metric.testHasValue())

        metric.record(extra: [.objectId: "buttonA"])

        /* SKIPPED: resetting system clock to return fixed time value */

        metric.record(extra: [.objectId: "buttonB"])

        XCTAssert(metric.testHasValue("store2"))
        let events = try! metric.testGetValue("store2")
        XCTAssertEqual(2, events.count)

        XCTAssertEqual("ui", events[0].category)
        XCTAssertEqual("click", events[0].name)

        XCTAssertEqual("ui", events[1].category)
        XCTAssertEqual("click", events[1].name)

        XCTAssertLessThanOrEqual(events[0].timestamp, events[1].timestamp, "The sequence of events must be preserved")
    }

    func testEventNotRecordWhenUploadDisabled() {
        let metric = EventMetricType<TestNameKeys, NoExtras>(
            category: "ui",
            name: "click",
            sendInPings: ["store1", "store2"],
            lifetime: .ping,
            disabled: false,
            allowedExtraKeys: ["test_name"]
        )

        Glean.shared.setUploadEnabled(true)
        metric.record(extra: [.testName: "event1"])
        let snapshot1 = try! metric.testGetValue()
        XCTAssertEqual(1, snapshot1.count)

        Glean.shared.setUploadEnabled(false)
        metric.record(extra: [.testName: "event2"])
        XCTAssertFalse(metric.testHasValue())

        Glean.shared.setUploadEnabled(true)
        metric.record(extra: [.testName: "event3"])
        let snapshot3 = try! metric.testGetValue()
        XCTAssertEqual(1, snapshot3.count)
    }

    func testFlushQueuedEventsOnStartup() {
        setupHttpResponseStub()
        expectation = expectation(description: "Completed upload")

        let event = EventMetricType<SomeExtraKeys, NoExtras>(
            category: "telemetry",
            name: "test_event",
            sendInPings: ["events"],
            lifetime: .ping,
            disabled: false,
            allowedExtraKeys: ["some_extra"]
        )

        event.record(extra: [.someExtra: "bar"])

        Glean.shared.resetGlean(clearStores: false)

        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "Test timed out waiting for upload: \(error!)")
        }

        let events = lastPingJson?["events"] as? [Any]
        XCTAssertNotNil(events)
        XCTAssertEqual(1, events?.count)
    }

    private func getExtraValue(from event: Any?, for key: String) -> String {
        let event = event! as! [String: Any]
        let extras = event["extra"] as! [String: Any]
        return extras[key] as! String
    }

    func testFlushQueuedEventsOnStartupDroppingPreinitEvents() {
        setupHttpResponseStub()
        expectation = expectation(description: "Completed upload")

        let event = EventMetricType<SomeExtraKeys, NoExtras>(
            category: "telemetry",
            name: "test_event",
            sendInPings: ["events"],
            lifetime: .ping,
            disabled: false,
            allowedExtraKeys: ["some_extra"]
        )

        event.record(extra: [.someExtra: "run1"])
        XCTAssertEqual(1, try! event.testGetValue().count)

        Dispatchers.shared.setTaskQueueing(enabled: true)
        event.record(extra: [.someExtra: "pre-init"])

        Glean.shared.resetGlean(clearStores: false)

        event.record(extra: [.someExtra: "post-init"])

        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "Test timed out waiting for upload: \(error!)")
        }

        let events = lastPingJson?["events"] as? [Any]
        XCTAssertNotNil(events)
        XCTAssertEqual(1, events?.count)
        XCTAssertEqual("run1", getExtraValue(from: events![0], for: "some_extra"))

        setupHttpResponseStub()
        expectation = expectation(description: "Completed upload")

        Glean.shared.submitPingByName(pingName: "events")

        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error, "Test timed out waiting for upload: \(error!)")
        }

        let events2 = lastPingJson?["events"] as? [Any]
        XCTAssertNotNil(events2)
        XCTAssertEqual(2, events2?.count)
        XCTAssertEqual("pre-init", getExtraValue(from: events2![0], for: "some_extra"))
        XCTAssertEqual("post-init", getExtraValue(from: events2![1], for: "some_extra"))
    }

    func testEventLongExtraRecordsError() {
        let metric = EventMetricType<TestNameKeys, NoExtras>(
            category: "ui",
            name: "click",
            sendInPings: ["store1", "store2"],
            lifetime: .ping,
            disabled: false,
            allowedExtraKeys: ["test_name"]
        )

        metric.record(extra: [.testName: String(repeating: "0123456789", count: 11)])
        XCTAssertEqual(1, metric.testGetNumRecordedErrors(.invalidOverflow))
    }
}
