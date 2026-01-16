# GenUI Widget Roadmap

This document outlines the plan for expanding the library of GenUI components available to the Robin AI assistant.

## 1. Charts
Visualizing data is a key capability for a personal assistant.
*   **Libraries**: `fl_chart` (highly recommended for Flutter).
*   **Components**:
    *   `LineChart`: Trends over time (health data, stocks, productivity).
    *   `BarChart`: Categorical comparisons (expenses, task completion).
    *   `ScatterChart`: Correlation data.
    *   `PieChart`: Proportions (budget breakdown).
*   **Props**:
    *   `data`: Array of points `[{x, y}, ...]`.
    *   `labels`: Axis labels.
    *   `colors`: Theme integration.

## 2. Message Templates
Rich formatting for communications.
*   **EmailCard**:
    *   **Props**: `subject`, `sender`, `snippet`, `timestamp`.
    *   **Actions**: "Reply", "Archive".
*   **SmsCard**:
    *   **Props**: `sender`, `body`.
    *   **Actions**: "Reply", "Mark as Read".
*   **Integration**: These will hook into the device's URL schemes (`mailto:`, `sms:`) or internal navigation.

## 3. Calendar Events
Displaying schedule and time-blocks.
*   **EventCard**:
    *   **Props**: `title`, `startTime`, `endTime`, `location`, `attendees`.
    *   **Visuals**: Color-coded vertical strip for calendar color.
*   **DayView**:
    *   A mini-list of `EventCard`s for a specific date.
*   **Recurring Events**:
    *   Complex prop structure: `recurrenceRule` (RRULE format or simplified JSON).

## 4. Reminders
Actionable tasks with state.
*   **ReminderTile**:
    *   **Props**: `text`, `isCompleted`, `priority` (high/med/low), `dueDate`.
    *   **Actions**: Checkbox to toggle completion (bi-directional sync needed).
*   **Recurring Reminders**:
    *   Logic for "Next due date".
*   **System Integration**: Hooks to iOS Reminders / Android Tasks.

## 5. Rich Action Buttons (Interactive)
Enhancing all cards with interactivity.
*   **Standard Action Schema**:
    *   `label`: Button text.
    *   `actionType`: `url` | `internal_route` | `function_call`.
    *   `payload`: Data for the action.
*   **Example**: A "Deploy" button on a Status Card that triggers a backend hook.
