# Offerion (Flutter)

This is a customer-facing Flutter application built to interact with a vendor-management system.

I am moving this repository from my old account (`Shreyas-u`) to `ShreyasUnnibhavi`.

**Project Status:** Archived / Partially Complete.
I have stopped working on this project, so the build is currently in a partial state.

## Overview

The app is designed to fetch and display resources/offers uploaded by vendors. It relies on a separate backend (Vendor App) to provide the data. Since I do not have control over the vendor side API in this repo, the app focuses on the frontend architecture and customer-side logic.

## Features

* **Authentication:** User login using OTP verification.
* **Profile:** Users can view and update their profile information.
* **Data Fetching:** The app is set up to pull resource lists via REST APIs from the vendor backend.

## Tech Stack

* **Framework:** Flutter
* **Language:** Dart
* **Architecture:** API-based data consumption

## Setup

If you want to run the UI locally:

1.  Clone the repo:
    ```bash
    git clone [https://github.com/ShreyasUnnibhavi/Flutter-Offerion-project.git](https://github.com/ShreyasUnnibhavi/Flutter-Offerion-project.git)
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run:
    ```bash
    flutter run
    ```

*Note: Some screens might be empty or show errors if the backend APIs are not reachable.*
