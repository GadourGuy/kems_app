# KDSE Event Management System (KEMS)

## 📖 About the Project
The KDSE Event Management System (KEMS) is a comprehensive Flutter application designed to digitize and streamline the entire lifecycle of campus events for KDSE residents. 

Historically, coordinating college activities, gaining administrative approvals, and tracking student participation has required fragmented communication. KEMS centralizes this process into a single platform that bridges the gap between regular Students, Club/Community Leads, and KDSE Administration. From the initial event proposal to the final post-event report, KEMS ensures administrative compliance, boosts student engagement, and automates manual tasks.

### ✨ Core Capabilities
* **Role-Based Access Control (RBAC):** Tailored dashboards and secure routing specifically designed for Students, Club Leads, and Admins.
* **Digital Event Proposals:** Club Leads can seamlessly submit detailed event proposals, including required PDF documentation, directly through the app.
* **Admin Approval Workflow:** A dedicated administrative queue to review, approve, or reject event proposals with specific feedback, ensuring only valid events take place on campus.
* **Integrated Campus Calendar:** A centralized, interactive calendar allowing students to discover upcoming approved events, view venues, and stay informed.
* **Streamlined Volunteering:** Students can actively participate by applying for open volunteer slots with a single click.
* **Automated Post-Event Operations:** Enforces a strict 14-day standardized reporting deadline for completed events and automates the generation of PDF certificates to officially recognize the contributions of organizers and volunteers.

---

## 🏗️ Project Structure
To maintain a scalable and modular codebase, this repository follows a **Feature-Driven Architecture**. Instead of grouping files by type (e.g., putting all UI together), we isolate each major epic into its own self-contained module.

```text
lib/
├── main.dart                 # Application entry point and Firebase initialization
├── core/                     # Shared utilities and resources across the app
│   ├── constants/            # Global styling, colors, themes, and API endpoints
│   ├── errors/               # Custom exception handling and error classes
│   ├── services/             # Core services (e.g., Auth wrapper, local storage)
│   ├── utils/                # Helper functions (e.g., date formatters, validators)
│   └── widgets/              # Reusable generic UI components (buttons, dialogs)
│
└── features/                 # Core business modules mapped to Jira Epics
    ├── authentication/       # Login, registration, and session state management
    ├── profile_management/   # User profile viewing and detail updates
    ├── role_management/      # Admin dashboard and user permission controls
    ├── event_proposal/       # Proposal forms, PDF upload logic, and admin review queue
    ├── calendar/             # Event fetching, interactive calendar UI, and volunteer sign-ups
    └── post_event/           # 14-day reporting workflow and automated PDF certificates
