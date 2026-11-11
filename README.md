# HealthMate

HealthMate is a Flutter mobile app for recording daily steps, calories burned and water intake. Records are stored locally using SQLite and can be viewed without an internet connection.

## Features

- Dashboard showing today's date and total steps, calories and water intake.
- Add and edit records with an activity date and whole-number values.
- History with date filtering and a delete confirmation.
- Input validation for invalid values and future dates.
- Light and dark mode using the sun/moon button in the header.

Multiple records on the same date are added together in the dashboard totals. Records are entered manually; the app does not read phone sensors. The theme selection lasts for the current session and resets to light mode when the app restarts.

