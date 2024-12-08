# NextToGoRacing
A SwiftUI list of upcoming races fetched from Neds

## Features

- **View Races**: See a time-ordered list of races, sorted by advertised start time in ascending order.
- **Filter Races**: Filter the list by:
  - Horse racing
  - Harness racing
  - Greyhound racing
- **Live Countdown**: View race details including:
  - Meeting name
  - Race number
  - Advertised start time (as a countdown).
- **Auto-Refresh**: The race list automatically updates to always show the next 5 upcoming races.
- **Dark Mode** and **Accessibility** supported

## Screenshots

| Racing List | Filter | No internet |
| - | - | - |
| - | - | - |

## Installation

### Prerequisites
- macOS 12 or later
- Xcode 15 or later
- iOS 17+ simulator or device

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/zhiying-fan/NextToGoRacing.git
   cd NextToGoRacing
   ```
2. Open the project in Xcode:
   ```bash
   open NextToGoRacing.xcodeproj
   ```
3. Run the app:
   - Select an iOS 17+ simulator.
   - Press `Cmd + R` to run.

## DesignKit

### Overview
`DesignKit` is a local Swift Package used for maintaining consistency in design. It includes:
- **Colors**: Predefined color palette for the app.
- **Icons**: Reusable image assets for common UI elements.
- **Spacing**: Standardized spacing constants for layouts.
- **Typography**: Text styles for heading, title, and subtitle.

### Example Usage
```swift
Text("Ongoing")
    .font(DesignKit.Font.title)
    .foregroundStyle(DesignKit.Color.orange)
    .padding(DesignKit.Spacing.spacing04)
```

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern:
- **Model**: Represents the data fetched from the API.
- **ViewModel**: Handles business logic, API integration, and data transformation for the views.
- **View**: Declares the UI using SwiftUI, binding directly to the ViewModel.

### Key Components
- **RacingService**: Fetches race data from the API using `URLSession` and Swift Concurrency.
- **RacingViewModel**: Manages state for the race list, filtering logic.
- **RacingView**: Displays the list of upcoming races.

## Testing
- **Unit Tests**:
  - Test core business logic like filtering and different view states.
  - Located under `NextToGoRacingTests`.
- **UI Tests**:
  - Verify UI elements on racing screen and filter component.
  - Located under `NextToGoRacingUITests`.

Run all tests with:
```bash
Cmd + U
```

## Project Management  

Development of this app was managed using GitHub Projects, following agile methodologies to ensure iterative progress and continuous delivery of features.  

You can view the GitHub Project board [here](https://github.com/users/zhiying-fan/projects/1).  

## Future Enhancements
- Add data persistence for saving filter settings.
- Implement push notifications for race updates.
- Support multiple languages.

## Contact
For any questions or suggestions, feel free to open an issue.
