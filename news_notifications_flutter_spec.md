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

### 4.1 News Categories (`GET /api/news/categories/` - `news_categories_list`)
Returns all active news categories for topic subscription.

* **Headers:** `Authorization: Bearer <access_token>`
* **Parameters:** None
* **Response (`200 OK`):** Returns JSON Array of `NewsCategory` objects (`[NewsCategory{...}]`).
```json
[
  {
    "id": 1,
    "name": "Weather Alerts",
    "description": "Severe weather notices and rainfall forecasts",
    "created_at": "2026-08-09T08:00:00+05:45",
    "updated_at": "2026-08-09T08:00:00+05:45"
  },
  {
    "id": 2,
    "name": "Crop Management",
    "description": "Seasonal planting and harvesting guidelines",
    "created_at": "2026-08-09T08:00:00+05:45",
    "updated_at": "2026-08-09T08:00:00+05:45"
  },
  {
    "id": 3,
    "name": "Fertilizer",
    "description": "Fertilizer availability and dosage advisories",
    "created_at": "2026-08-09T08:00:00+05:45",
    "updated_at": "2026-08-09T08:00:00+05:45"
  },
  {
    "id": 4,
    "name": "Pest & Disease",
    "description": "Pest outbreak alerts and treatment steps",
    "created_at": "2026-08-09T08:00:00+05:45",
    "updated_at": "2026-08-09T08:00:00+05:45"
  },
  {
    "id": 5,
    "name": "Government Schemes",
    "description": "Nepal government subsidies and farming schemes",
    "created_at": "2026-08-09T08:00:00+05:45",
    "updated_at": "2026-08-09T08:00:00+05:45"
  }
]
```

---

### 4.2 Farmer News Feed (`GET /api/news/` - `news_list`)
Lists **PUBLISHED** news articles for the mobile feed. Drafts are excluded automatically.

* **Auth Required:** Yes
* **Query Parameters:**
  * `?search=maize` (optional search term across title/summary/content)
  * `?category=4` (optional category ID filter)
  * `?category__name=Pest & Disease` (optional category name filter)
* **Response (`200 OK`):** Returns JSON Array of `News` objects (`[News{...}]`).
```json
[
  {
    "id": 12,
    "title": "Armyworm Outbreak Alert in Chitwan Maize Fields",
    "summary": "Fall armyworm detected in Chitwan region. Immediate pesticide application recommended.",
    "content": "Full advisory content details...",
    "image": "http://127.0.0.1:8000/media/news/armyworm.jpg",
    "category": {
      "id": 4,
      "name": "Pest & Disease",
      "description": "Pest outbreak alerts and treatment steps",
      "created_at": "2026-08-09T09:00:00+05:45",
      "updated_at": "2026-08-09T09:00:00+05:45"
    },
    "category_id": 4,
    "status": "PUBLISHED",
    "created_by_username": "officer_admin",
    "published_at": "2026-08-09T10:30:00+05:45",
    "created_at": "2026-08-09T09:00:00+05:45",
    "updated_at": "2026-08-09T10:30:00+05:45"
  }
]
```

---

### 4.3 Farmer News Detail View (`GET /api/news/<id>/` - `news_read`)
Returns complete details of a published news article.

* **Auth Required:** Yes
* **Path Parameters:** `id` (integer/string, required) - Unique ID of the published article.
* **Response (`200 OK`):**
```json
{
  "id": 12,
  "title": "Armyworm Outbreak Alert in Chitwan Maize Fields",
  "summary": "Fall armyworm detected in Chitwan region.",
  "content": "Full markdown or rich text article explaining infestation symptoms, recommended chemical treatments (Emamectin benzoate 5% SG at 0.4g/L water), and preventive steps...",
  "image": "http://127.0.0.1:8000/media/news/armyworm.jpg",
  "category": {
    "id": 4,
    "name": "Pest & Disease",
    "description": "Pest outbreak alerts and treatment steps",
    "created_at": "2026-08-09T09:00:00+05:45",
    "updated_at": "2026-08-09T09:00:00+05:45"
  },
  "category_id": 4,
  "status": "PUBLISHED",
  "created_by_username": "officer_admin",
  "published_at": "2026-08-09T10:30:00+05:45",
  "created_at": "2026-08-09T09:00:00+05:45",
  "updated_at": "2026-08-09T10:30:00+05:45"
}
```
* **Error Response (`404 Not Found`):** Returned if the article ID does not exist or is in `DRAFT` state for non-staff users.

---

### 4.4 Topic Subscriptions (`POST` / `GET` / `DELETE /api/subscriptions/`)

* **Subscribe to Category (`POST /api/subscriptions/` - `subscriptions_create`):**
  * **Auth Required:** Yes
  * **Description:** Subscribe authenticated farmer to a news category by `category_id`.
  * **Request Body (`application/json`):**
    ```json
    {
      "category_id": 4
    }
    ```
  * **Response (`201 Created`):** Returns created `Subscription` object.
    ```json
    {
      "id": 8,
      "category": {
        "id": 4,
        "name": "Pest & Disease",
        "description": "Pest outbreak alerts and treatment steps",
        "created_at": "2026-08-09T08:00:00+05:45",
        "updated_at": "2026-08-09T08:00:00+05:45"
      },
      "category_id": 4,
      "created_at": "2026-08-09T11:00:00+05:45"
    }
    ```
  * **Error Response (`400 Bad Request`):** Duplicate Subscription Error (e.g. `{"detail": "You are already subscribed to this category."}`).

* **List Active Farmer Subscriptions (`GET /api/subscriptions/` - `subscriptions_list`):**
  * **Auth Required:** Yes
  * **Parameters:** None
  * **Response (`200 OK`):** Returns JSON Array of `Subscription` objects (`[Subscription{...}]`).
    ```json
    [
      {
        "id": 8,
        "category": {
          "id": 4,
          "name": "Pest & Disease",
          "description": "Pest outbreak alerts and treatment steps",
          "created_at": "2026-08-09T08:00:00+05:45",
          "updated_at": "2026-08-09T08:00:00+05:45"
        },
        "category_id": 4,
        "created_at": "2026-08-09T11:00:00+05:45"
      }
    ]
    ```

* **Unsubscribe (`DELETE /api/subscriptions/<id>/` - `subscriptions_delete`):**
  * **Auth Required:** Yes
  * **Description:** Unsubscribe authenticated farmer from a news category by subscription ID.
  * **Path Parameters:** `id` (integer/string, required) - Unique ID of the active subscription.
  * **Response (`200 OK` or `204 No Content`):** Successfully unsubscribed.
    ```json
    {
      "status": "success",
      "message": "Successfully unsubscribed."
    }
    ```
  * **Error Response (`404 Not Found`):** Returned if the subscription `id` does not exist or does not belong to the user.
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

### 4.6 Admin News Management Endpoints (`/api/admin/news/`)

> [!IMPORTANT]
> **Admin Authentication & Token Requirement**:
> Access to all `/api/admin/news/*` endpoints requires Admin / Staff authentication.
> Administrators must log in via `AdminLoginScreen` (`POST /api/token/`) to receive an admin JWT access token.
> Every request to `/api/admin/*` MUST include the header:
> `Authorization: Bearer <admin_token>`

* **Create News Article (`POST /api/admin/news/` - `admin_news_create`):**
  * **Auth Required:** Yes (`Authorization: Bearer <admin_token>`)
  * **Description:** Create a news article as `DRAFT` or `PUBLISHED`.
  * **Request Body (`application/json`):**
    ```json
    {
      "title": "Fall Armyworm Outbreak Warning",
      "summary": "High risk of Armyworm invasion in eastern maize fields",
      "content": "Detailed pesticide recommendations and alert guidelines...",
      "category_id": 4,
      "status": "DRAFT"
    }
    ```
  * **Request Schema Parameters:**
    * `title` (string, required, length: 1–255): Title of article.
    * `summary` (string, required, min length: 1): Short summary preview.
    * `content` (string, required, min length: 1): Full article markdown/body.
    * `category_id` (integer, required): ID of news category.
    * `status` (string, optional, enum: `["DRAFT", "PUBLISHED"]`): Draft state or published.
  * **Response (`201 Created`):**
    ```json
    {
      "id": 15,
      "title": "Fall Armyworm Outbreak Warning",
      "summary": "High risk of Armyworm invasion in eastern maize fields",
      "content": "Detailed pesticide recommendations and alert guidelines...",
      "image": null,
      "category": {
        "id": 4,
        "name": "Pest & Disease",
        "description": "Pest outbreak alerts and treatment steps",
        "created_at": "2026-08-09T10:00:00+05:45",
        "updated_at": "2026-08-09T10:00:00+05:45"
      },
      "category_id": 4,
      "status": "DRAFT",
      "created_by_username": "officer_admin",
      "published_at": null,
      "created_at": "2026-08-09T18:56:15+05:45",
      "updated_at": "2026-08-09T18:56:15+05:45"
    }
    ```
  * **Error Response (`403 Forbidden`):** Returned if the authenticated user is not staff / admin.

* **List Admin News Articles (`GET /api/admin/news/` - `admin_news_list`):**
  * **Auth Required:** Yes (Staff / Extension Officer)
  * **Description:** Retrieve all news articles across the system, including both `DRAFT` and `PUBLISHED` states.
  * **Parameters:** None.
  * **Response (`200 OK`):** Returns a JSON Array of `News` objects.
    ```json
    [
      {
        "id": 15,
        "title": "Fall Armyworm Outbreak Warning",
        "summary": "High risk of Armyworm invasion in eastern maize fields",
        "content": "Detailed pesticide recommendations...",
        "image": null,
        "category": {
          "id": 4,
          "name": "Pest & Disease",
          "description": "Pest outbreak alerts and treatment steps",
          "created_at": "2026-08-09T10:00:00+05:45",
          "updated_at": "2026-08-09T10:00:00+05:45"
        },
        "category_id": 4,
        "status": "DRAFT",
        "created_by_username": "officer_admin",
        "published_at": null,
        "created_at": "2026-08-09T18:56:15+05:45",
        "updated_at": "2026-08-09T18:56:15+05:45"
      },
      {
        "id": 12,
        "title": "Armyworm Outbreak Alert in Chitwan Maize Fields",
        "summary": "Fall armyworm detected in Chitwan region.",
        "content": "Full advisory body text...",
        "image": "http://127.0.0.1:8000/media/news/armyworm.jpg",
        "category": {
          "id": 4,
          "name": "Pest & Disease",
          "description": "Pest outbreak alerts and treatment steps",
          "created_at": "2026-08-09T09:00:00+05:45",
          "updated_at": "2026-08-09T09:00:00+05:45"
        },
        "category_id": 4,
        "status": "PUBLISHED",
        "created_by_username": "officer_admin",
        "published_at": "2026-08-09T10:30:00+05:45",
        "created_at": "2026-08-09T09:00:00+05:45",
        "updated_at": "2026-08-09T10:30:00+05:45"
      }
    ]
    ```
  * **Error Response (`403 Forbidden`):** Returned if the authenticated user is not staff / admin.

* **Get Specific Admin News Details (`GET /api/admin/news/<id>/` - `admin_news_read`):**
  * **Auth Required:** Yes (Staff / Extension Officer)
  * **Description:** Retrieve detailed information of a specific news article (in either `DRAFT` or `PUBLISHED` state) by its unique integer `id`.
  * **Path Parameters:** `id` (integer, required) - Unique ID of the article.
  * **Response (`200 OK`):** Returns the single `News` object.
    ```json
    {
      "id": 15,
      "title": "Fall Armyworm Outbreak Warning",
      "summary": "High risk of Armyworm invasion in eastern maize fields",
      "content": "Detailed pesticide recommendations...",
      "image": null,
      "category": {
        "id": 4,
        "name": "Pest & Disease",
        "description": "Pest outbreak alerts and treatment steps",
        "created_at": "2026-08-09T10:00:00+05:45",
        "updated_at": "2026-08-09T10:00:00+05:45"
      },
      "category_id": 4,
      "status": "DRAFT",
      "created_by_username": "officer_admin",
      "published_at": null,
      "created_at": "2026-08-09T18:56:15+05:45",
      "updated_at": "2026-08-09T18:56:15+05:45"
    }
    ```
  * **Error Response (`403 Forbidden`):** Returned if the authenticated user is not staff / admin.

* **Update News Article (`PUT /api/admin/news/<id>/` - `admin_news_update` | `PATCH /api/admin/news/<id>/` - `admin_news_partial_update`):**
  * **Auth Required:** Yes (Staff / Extension Officer)
  * **Description:** Update fields of an existing news article by its unique integer `id`. Supports full overwrite (`PUT`) or partial update of select fields (`PATCH`).
  * **Path Parameters:** `id` (integer, required) - Unique article ID.
  * **Partial Request Body Example (`PATCH`):**
    ```json
    {
      "status": "PUBLISHED"
    }
    ```
  * **Full Request Body Example (`PUT`):**
    ```json
    {
      "title": "Updated Armyworm Outbreak Notice",
      "summary": "Revised treatment dosages and emergency hotline details",
      "content": "Full revised article body...",
      "category_id": 4,
      "status": "PUBLISHED"
    }
    ```
  * **Request Schema Parameters:**
    * `title` (string, optional for PATCH, max 255 chars): Updated title.
    * `summary` (string, optional for PATCH): Updated summary preview.
    * `content` (string, optional for PATCH): Updated full markdown body.
    * `category_id` (integer, optional for PATCH): Updated category ID.
    * `status` (string, optional, enum: `["DRAFT", "PUBLISHED"]`): Updated status.
  * **Response (`200 OK`):** Returns the updated `News` object.
    ```json
    {
      "id": 15,
      "title": "Updated Armyworm Outbreak Notice",
      "summary": "Revised treatment dosages and emergency hotline details",
      "content": "Full revised article body...",
      "image": null,
      "category": {
        "id": 4,
        "name": "Pest & Disease",
        "description": "Pest outbreak alerts and treatment steps",
        "created_at": "2026-08-09T10:00:00+05:45",
        "updated_at": "2026-08-09T10:00:00+05:45"
      },
      "category_id": 4,
      "status": "PUBLISHED",
      "created_by_username": "officer_admin",
      "published_at": "2026-08-09T20:11:00+05:45",
      "created_at": "2026-08-09T18:56:15+05:45",
      "updated_at": "2026-08-09T20:11:00+05:45"
    }
    ```
  * **Error Response (`403 Forbidden`):** Returned if the authenticated user is not staff / admin.

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
