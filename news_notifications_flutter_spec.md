# AgriAssist — Agriculture News, Subscriptions & In-App Notifications API Specification (Flutter Integration Guide)

This document provides the complete API specification and integration guide for the **Agriculture News, Topic Subscription, and In-App Notification System** (`news` app). It is designed to guide Flutter mobile developers on implementing news feeds, category subscriptions, unread notification badges, and periodic polling.

---

## 1. System Architecture & Role Overview

```text
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    ADMIN (Extension Officer)                                   │
│  1. Creates News Article (Status: DRAFT or PUBLISHED)                                         │
│  2. Assigns 1 Category (e.g., "Pest & Disease", "Weather", "Market Prices")                    │
│  3. Clicks "Publish" ───► Triggers Server Notification Service                                 │
└───────────────────────────────────────────────┬────────────────────────────────────────────────┘
                                                │ Bulk Creates Notifications
                                                ▼
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      FARMER (Flutter App)                                      │
│  1. Subscribes to Categories of interest (e.g. "Pest & Disease")                                │
│  2. Periodically polls /api/notifications/unread-count/ every 30–60 seconds                    │
│  3. Displays Bell Badge Count (e.g. "3")                                                       │
│  4. Opens Notification ───► Navigates directly to News Article Detail Screen                   │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
```

* **Roles:**
  * **Farmer (`is_staff = False`):** Can view published news, manage their own category subscriptions, view their notification list, and mark notifications as read.
  * **Admin / Staff (`is_staff = True`):** Can create, update, delete, and publish news articles.

---

## 2. Periodic Polling Workflow for Flutter Mobile

The backend provides ultra-lightweight REST endpoints optimized for periodic polling.

### Recommended Flutter Lifecycle Implementation:
1. **On App Launch / Resume:**
   * Immediately call `GET /api/notifications/unread-count/`.
   * If `unread_count > 0`, fetch notification list via `GET /api/notifications/`.
2. **While App is Active (Foreground):**
   * Set a `Timer.periodic` to call `GET /api/notifications/unread-count/` every **30 to 60 seconds**.
   * If the returned `unread_count` differs from local state, fetch `GET /api/notifications/` to update the list.
3. **When App Goes to Background:**
   * Pause the periodic timer to save battery and data usage.
4. **When App Returns to Foreground:**
   * Immediately fetch `GET /api/notifications/unread-count/`.

---

## 3. API Endpoints Reference Matrix

| Feature Module | HTTP Method | Endpoint Route | Auth Required | Target Role |
|---|---|---|:---:|:---:|
| **Categories** | `GET` | `/api/news/categories/` | Yes | All Users |
| **Farmer News Feed** | `GET` | `/api/news/` | Yes | Farmers (Published Only) |
| **Farmer News Detail** | `GET` | `/api/news/<id>/` | Yes | Farmers (Published Only) |
| **Subscribe Topic** | `POST` | `/api/subscriptions/` | Yes | Farmers |
| **List Subscriptions** | `GET` | `/api/subscriptions/` | Yes | Farmers |
| **Unsubscribe Topic** | `DELETE` | `/api/subscriptions/<id>/` | Yes | Farmers |
| **Notification List** | `GET` | `/api/notifications/` | Yes | Farmers |
| **Unread Count** | `GET` | `/api/notifications/unread-count/` | Yes | Farmers |
| **Mark Single Read** | `PATCH` | `/api/notifications/<id>/read/` | Yes | Farmers |
| **Mark All Read** | `PATCH` | `/api/notifications/read-all/` | Yes | Farmers |
| **Admin Create News** | `POST` | `/api/admin/news/` | Yes (Staff) | Admins Only |
| **Admin News List** | `GET` | `/api/admin/news/` | Yes (Staff) | Admins (Draft + Published) |
| **Admin Update News** | `PATCH` | `/api/admin/news/<id>/` | Yes (Staff) | Admins Only |
| **Admin Delete News** | `DELETE` | `/api/admin/news/<id>/` | Yes (Staff) | Admins Only |
| **Admin Publish News** | `POST` | `/api/admin/news/<id>/publish/` | Yes (Staff) | Admins Only |

---

## 4. Detailed Endpoint Specifications & Payloads

### 4.1 News Categories (`GET /api/news/categories/`)
Returns all active news categories for topic subscription screens.

* **Headers:** `Authorization: Bearer <access_token>`
* **Response (`200 OK`):**
```json
{
  "status": "success",
  "count": 5,
  "categories": [
    { "id": 1, "name": "Weather Alerts", "description": "Severe weather notices and rainfall forecasts" },
    { "id": 2, "name": "Crop Management", "description": "Seasonal planting and harvesting guidelines" },
    { "id": 3, "name": "Fertilizer", "description": "Fertilizer availability and dosage advisories" },
    { "id": 4, "name": "Pest & Disease", "description": "Pest outbreak alerts and treatment steps" },
    { "id": 5, "name": "Government Schemes", "description": "Nepal government subsidies and farming schemes" }
  ]
}
```

---

### 4.2 Farmer News Feed (`GET /api/news/`)
Lists **PUBLISHED** news articles for the mobile feed. (Drafts are excluded automatically).

* **Query Parameters:** `?category=4` (optional category filter) | `?search=maize` (optional title search)
* **Response (`200 OK`):**
```json
{
  "status": "success",
  "count": 2,
  "results": [
    {
      "id": 12,
      "title": "Armyworm Outbreak Alert in Chitwan Maize Fields",
      "summary": "Fall armyworm detected in Chitwan region. Immediate pesticide application recommended.",
      "image_url": "http://127.0.0.1:8000/media/news/armyworm.jpg",
      "category": { "id": 4, "name": "Pest & Disease" },
      "published_at": "2026-08-09T10:30:00+05:45",
      "created_at": "2026-08-09T09:00:00+05:45"
    }
  ]
}
```

---

### 4.3 Farmer News Detail View (`GET /api/news/<id>/`)
Returns the complete article with full content body.

* **Response (`200 OK`):**
```json
{
  "status": "success",
  "article": {
    "id": 12,
    "title": "Armyworm Outbreak Alert in Chitwan Maize Fields",
    "summary": "Fall armyworm detected in Chitwan region.",
    "content": "Full markdown or rich text article explaining infestation symptoms, recommended chemical treatments (Emamectin benzoate 5% SG at 0.4g/L water), and preventive steps...",
    "image_url": "http://127.0.0.1:8000/media/news/armyworm.jpg",
    "category": { "id": 4, "name": "Pest & Disease" },
    "created_by": "Officer Admin",
    "published_at": "2026-08-09T10:30:00+05:45"
  }
}
```

---

### 4.4 Topic Subscriptions (`POST` / `GET` / `DELETE /api/subscriptions/`)

* **Subscribe to Category (`POST /api/subscriptions/`):**
  * **Request Body:** `{ "category_id": 4 }`
  * **Response (`201 Created`):**
    ```json
    {
      "status": "success",
      "subscription": { "id": 8, "category": { "id": 4, "name": "Pest & Disease" }, "created_at": "2026-08-09T11:00:00+05:45" }
    }
    ```
  * **Duplicate Handling:** If already subscribed, returns `400 Bad Request` (`"You are already subscribed to this category."`).

* **List Active Farmer Subscriptions (`GET /api/subscriptions/`):**
  * **Response (`200 OK`):** Returns array of categories the current logged-in farmer is subscribed to.

* **Unsubscribe (`DELETE /api/subscriptions/<id>/`):**
  * **Response (`200 OK`):** `{"status": "success", "message": "Successfully unsubscribed."}`
  * *(Note: Unsubscribing stops future notifications; past notifications remain intact).*

---

### 4.5 In-App Notifications (`GET` / `PATCH /api/notifications/`)

* **1. Fetch Unread Count (`GET /api/notifications/unread-count/`):**
  * **Fast Endpoint Response (`200 OK`):**
    ```json
    {
      "unread_count": 3
    }
    ```

* **2. Fetch Notification List (`GET /api/notifications/`):**
  * **Response (`200 OK`):**
    ```json
    {
      "status": "success",
      "count": 3,
      "notifications": [
        {
          "id": 45,
          "title": "New Advisory in Pest & Disease",
          "message": "Armyworm Outbreak Alert in Chitwan Maize Fields",
          "is_read": false,
          "created_at": "2026-08-09T10:30:00+05:45",
          "read_at": null,
          "news_id": 12,
          "news_category": "Pest & Disease"
        }
      ]
    }
    ```

* **3. Mark Single Notification as Read (`PATCH /api/notifications/<id>/read/`):**
  * **Response (`200 OK`):** Returns updated notification with `is_read = true` and `read_at = "2026-08-09T12:00:00+05:45"`.

* **4. Mark All Notifications as Read (`PATCH /api/notifications/read-all/`):**
  * **Response (`200 OK`):** `{"status": "success", "message": "All notifications marked as read."}`

---

## 5. Navigation & Deep-Linking Contract for Flutter

When a farmer taps on a notification item in Flutter:

1. Call `PATCH /api/notifications/<notification_id>/read/` to mark it as read.
2. Read the `news_id` field from the notification payload.
3. Push the **News Article Detail Screen** passing `news_id`:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => NewsDetailScreen(newsId: notification.newsId)),
   );
   ```
