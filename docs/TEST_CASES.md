# Core-feature test cases

Executed on 18 October 2026 with Flutter 3.47.4 / Dart 3.13.3. The automated host suite passed all 15 tests after removing unused sample functionality.

| ID | Scenario and input | Expected result | Actual result | Status |
|---|---|---|---|---|
| TC01 | Add, edit and delete an SQLite record | Values persist; delete removes row | Assertions passed | PASS |
| TC02 | Negative, excessive, all-zero and future input | Reject invalid entries | Assertions passed | PASS |
| TC04 | Close and reopen a file database | Saved record survives | Assertions passed | PASS |
| TC05 | Direct negative insert bypassing UI | SQLite constraint rejects it | Assertions passed | PASS |
| TC06 | Two entries today plus one yesterday | Dashboard sums only today's entries | Assertions passed | PASS |
| TC07 | Three dates; choose one then clear | One selected-day record, then all three | Assertions passed | PASS |
| TC08 | Storage failure, followed by retry | Error reported; retry succeeds | Assertions passed | PASS |
| TC09 | Empty, decimal, text and negative numeric input | Rejected; valid whole numbers accepted | Assertions passed | PASS |
| TC10 | Device date changes from 31 December to 1 January | Dashboard uses the new day | Assertions passed | PASS |
| TC11 | Form validation, add/edit, cancel delete, confirm delete | UI saves and removes the intended record | Assertions passed | PASS |
| TC12 | 360x800 logical screen, 1.3 text scaling | No overflow navigating Dashboard/History | Assertions passed | PASS |
| TC13 (3 tests) | Upgrade database versions 1, 2 and 3 to version 4 | Personal records and IDs preserved; sample rows and column removed | Assertions passed | PASS |
| TC14 | Switch light/dark mode and navigate to form | Theme applies across screens and switches back | Assertions passed | PASS |

Run `flutter test --reporter expanded`. SQLite tests use the real SQLite engine through FFI. UI previews use a test repository and are not Android device screenshots. See docs/verification for command logs. The optional device-test scripts and preview generator have been removed. Device screenshots and manual checks can be recorded directly from the emulator. iOS is not verified on this host.


