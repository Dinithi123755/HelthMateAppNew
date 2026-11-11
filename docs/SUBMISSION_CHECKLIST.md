# HealthMate assessment checklist

The app is one part of the coursework. Marks are awarded by the assessor, not guaranteed by implementing this checklist. The brief's section totals and final marking table differ, so confirm the official rubric with the lecturer.

## App review

- Run the app on an Android device/emulator and understand every screen.
- Demonstrate adding, editing and deleting real entries and filtering by date.
- Explain that multiple entries on one date are summed.
- Show persistence after force-closing and reopening the app.
- Demonstrate validation, empty results and deletion cancellation.
- Show the SQLite schema and parameterized CRUD methods.
- Explain Provider, ChangeNotifier, the ViewModel and repository boundary.
- Show the labelled sample records used for testing.

## PDF technical report

Create a student-authored report with your name, student ID and module details. Source notes are in TECHNICAL_GUIDE.md; adapt and verify them rather than submitting them unchanged as a final report.

Include cover, contents, overview, features, architecture diagram and layer explanation, state management, database/table diagram and field descriptions, selected database/CRUD snippets with explanations, package choices, wireframes, screenshots and navigation/design decisions, meaningful test cases with actual results, issues/fixes, Git evidence, conclusion and Harvard references.

Formatting required by the brief: Times New Roman; main headings 16 pt, subheadings 14 pt, body 11 pt. Include page numbers, legible screenshots, figure/table captions and consistent spacing. Export the finished report as PDF.

## Release APK

- Build using `flutter build apk --release`.
- Install and verify the resulting release APK, not only a debug build.
- Upload `build/app/outputs/flutter-apk/app-release.apk` to your Google Drive.
- Set sharing to **Anyone with the link — Viewer**.
- Put the verified download link in Appendix B.

## Public repository

- Create a public GitHub/GitLab/Bitbucket repository under your own account.
- Check that no credentials, keystores, personal health data or build caches are committed.
- Push source and real development commits; never fabricate an earlier development history.
- Set your own Git identity for future changes. The initial generated implementation commits use a development identity.
- Add the public repository URL in Appendix C.

## Your narrated demonstration

Record your own voice explaining the app. Keep the final video at or below **25 MB**. Suggested sequence:

1. Introduce HealthMate and describe the offline manual journal.
2. Add a record, demonstrate validation and explain the fields/units.
3. Show dashboard totals.
4. Open History, search a date and edit a record.
5. Cancel a delete, then confirm deletion of a test record.
6. Explain how entries on the same date are summed.
7. Explain architecture and show SQLite CRUD and test results briefly.
8. Restart the app and show saved data.

Upload to Google Drive with **Anyone with the link — Viewer** permission. Add the URL in Appendix A. Do not claim synthetic demo records are personal health measurements.

## Additional evidence and integrity

Appendix D can contain screenshots, actual test results, Git log and database evidence. Record device/OS details and test dates. Do not mark unperformed manual checks as passed.

The brief requires acknowledgement of AI contributions, including planning. Include an accurate **Acknowledgement of AI Contribution** statement explaining the assistance used for requirements, code, tests and documentation, along with your own review, modifications and understanding. Prepare to explain the work during the viva.

Cloud uploads, public repository publication, a narrated video and a final student-personalized PDF are not automatically completed by having this local project.
