# AgriAssist — Extension Officer & Admin Analytics Dashboard API Specification

This document provides the complete technical specification for the **Extension Officer & Admin Analytics Dashboard API** (`analytics` app). It is designed to help frontend developers (Flutter / Web) build interactive data visualizations, charts, stat cards, and reporting modules.

---

## 1. System Overview & Target Audience

The **Admin Analytics Dashboard** aggregates real-time data from farmer interactions across Nepal—specifically soil test inputs, regional crop predictions, fertilizer demands, and soil acidity alerts.

* **Target Audience:** Agricultural Extension Officers, Soil Scientists, and Agricultural Department Administrators.
* **Authentication:** Required (JWT Bearer Token).
* **Access Control:** Restricted to Staff Users (`is_staff = True`). If a regular farmer attempts to access these endpoints, the server returns `HTTP 403 Forbidden`.

```text
                               Authorization: Bearer <staff_jwt_token>
                                                 │
                                                 ▼
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   Django Analytics Engine                                      │
├───────────────────────────────┬───────────────────────────────┬────────────────────────────────┤
│      User Profile Aggregation │    Crop History Aggregation   │ Fertilizer History Aggregation │
└───────────────┬───────────────┴───────────────┬───────────────┴────────────────┬───────────────┘
                │                               │                                │
                ▼                               ▼                                ▼
  • Farmer Counts by City         • Crop Demands by Season        • Fertilizer Demand by City
  • Geographic Distribution       • Top Recommended Crops         • Soil Acidity Hotspots (pH<5.5)
```

---

## 2. API Endpoints Specification Matrix

| Method | Endpoint Path | Description | Recommended Frontend Widget |
|---|---|---|---|
| `GET` | `/api/analytics/kpis/` | System-wide high-level metrics & soil health KPIs | Stat Cards / Metric Badges |
| `GET` | `/api/analytics/fertilizer-demand/` | Regional fertilizer demand breakdown by City | Grouped / Stacked Bar Chart |
| `GET` | `/api/analytics/soil-acidity-hotspots/` | Soil acidity risk levels ($\text{pH} < 5.5$) by City | Ranked Risk Table / Heatmap |
| `GET` | `/api/analytics/crop-distribution/` | Recommended crop distribution by Season & City | Pie / Donut Chart |
| `GET` | `/api/analytics/usage-trends/` | Daily / monthly query volume trends over time | Smooth Line / Area Chart |

---

## 3. Detailed Endpoint Specs & JSON Payloads

### Module 1: High-Level System KPIs (`GET /api/analytics/kpis/`)

Provides a quick overview of platform scale and national soil acidity levels.

* **Endpoint:** `GET /api/analytics/kpis/`
* **Headers:** `Authorization: Bearer <staff_jwt_token>`
* **Response Status:** `200 OK`
* **Response JSON Payload:**
```json
{
  "status": "success",
  "kpis": {
    "total_farmers": 1420,
    "total_crop_predictions": 5340,
    "total_fertilizer_predictions": 4890,
    "total_acidic_soil_alerts": 1280,
    "acidic_soil_percentage": 26.18
  }
}
```
* **Frontend Widget Guidance:** Render 4-5 prominent top-level Stat Cards (e.g. Total Farmers, Crop Predictions, Acidic Soil Alert Count with red highlight).

---

### Module 2: Regional Fertilizer Demand (`GET /api/analytics/fertilizer-demand/`)

Aggregates fertilizer demand counts (DAP, Urea, MOP, Lime, etc.) grouped by City for chemical inventory planning.

* **Endpoint:** `GET /api/analytics/fertilizer-demand/`
* **Headers:** `Authorization: Bearer <staff_jwt_token>`
* **Response Status:** `200 OK`
* **Response JSON Payload:**
```json
{
  "status": "success",
  "regional_demand": [
    {
      "city": "Pokhara",
      "total_queries": 1160,
      "fertilizers": {
        "DAP": 420,
        "Urea": 310,
        "Lime / Gypsum": 280,
        "MOP": 150
      }
    },
    {
      "city": "Chitwan",
      "total_queries": 1240,
      "fertilizers": {
        "Urea": 550,
        "DAP": 480,
        "20-20-0": 210
      }
    },
    {
      "city": "Kathmandu",
      "total_queries": 890,
      "fertilizers": {
        "Urea": 390,
        "DAP": 320,
        "17-17-17": 180
      }
    }
  ]
}
```
* **Frontend Widget Guidance:** Render a **Grouped Horizontal Bar Chart** or **Dropdown-filtered Bar Chart** where users can select a city to see its specific chemical demand.

---

### Module 3: Soil Acidity Hotspots Analytics (`GET /api/analytics/soil-acidity-hotspots/`)

Tracks acidic soil prevalence ($\text{pH} < 5.5$) by region to guide lime subsidy programs.

* **Endpoint:** `GET /api/analytics/soil-acidity-hotspots/`
* **Headers:** `Authorization: Bearer <staff_jwt_token>`
* **Response Status:** `200 OK`
* **Response JSON Payload:**
```json
{
  "status": "success",
  "hotspots": [
    {
      "city": "Pokhara",
      "average_ph": 5.12,
      "total_tests": 850,
      "acidic_tests_count": 590,
      "acidic_percentage": 69.41,
      "acidity_risk_level": "CRITICAL"
    },
    {
      "city": "Lalitpur",
      "average_ph": 5.38,
      "total_tests": 420,
      "acidic_tests_count": 210,
      "acidic_percentage": 50.0,
      "acidity_risk_level": "HIGH"
    },
    {
      "city": "Chitwan",
      "average_ph": 6.35,
      "total_tests": 1100,
      "acidic_tests_count": 120,
      "acidic_percentage": 10.91,
      "acidity_risk_level": "LOW"
    }
  ]
}
```
* **Frontend Widget Guidance:** Render a **Color-coded Table** or **Map Heatmap**. Highlight `CRITICAL` (Red), `HIGH` (Orange), and `LOW` (Green).

---

### Module 4: Crop Cultivation Distribution (`GET /api/analytics/crop-distribution/`)

Provides seasonal breakdown of recommended crops to track agricultural diversity.

* **Endpoint:** `GET /api/analytics/crop-distribution/`
* **Headers:** `Authorization: Bearer <staff_jwt_token>`
* **Response Status:** `200 OK`
* **Response JSON Payload:**
```json
{
  "status": "success",
  "crop_distribution": [
    {
      "season": "Monsoon",
      "total_recommendations": 2310,
      "top_crops": [
        { "crop": "rice", "count": 1420, "percentage": 61.47 },
        { "crop": "maize", "count": 890, "percentage": 38.53 }
      ]
    },
    {
      "season": "Winter",
      "total_recommendations": 1170,
      "top_crops": [
        { "crop": "chickpea", "count": 650, "percentage": 55.56 },
        { "crop": "lentil", "count": 520, "percentage": 44.44 }
      ]
    }
  ]
}
```
* **Frontend Widget Guidance:** Render a **Donut / Pie Chart** with season tabs (Monsoon, Winter, Summer, Pre-Monsoon).

---

### Module 5: Platform Usage Trends (`GET /api/analytics/usage-trends/`)

Time-series query counts to track application adoption over time.

* **Endpoint:** `GET /api/analytics/usage-trends/`
* **Headers:** `Authorization: Bearer <staff_jwt_token>`
* **Response Status:** `200 OK`
* **Response JSON Payload:**
```json
{
  "status": "success",
  "daily_trends": [
    { "date": "2026-08-03", "crop_queries": 110, "fertilizer_queries": 95 },
    { "date": "2026-08-04", "crop_queries": 132, "fertilizer_queries": 115 },
    { "date": "2026-08-05", "crop_queries": 125, "fertilizer_queries": 108 },
    { "date": "2026-08-06", "crop_queries": 145, "fertilizer_queries": 120 },
    { "date": "2026-08-07", "crop_queries": 182, "fertilizer_queries": 165 }
  ]
}
```
* **Frontend Widget Guidance:** Render a **Dual-Line Chart** (Line 1: Crop Queries, Line 2: Fertilizer Queries) over time.

---

## 4. Error Handling Matrix for Frontend Developers

| HTTP Code | Error Response JSON | Root Cause | Frontend Handling Action |
|---|---|---|---|
| `401` | `{"detail": "Authentication credentials were not provided."}` | Missing or expired JWT token | Redirect to Login Screen |
| `403` | `{"detail": "You do not have permission to perform this action."}` | User is a regular farmer (`is_staff=False`) | Display "Staff Access Only" error banner |
| `500` | `{"detail": "Internal server error"}` | Backend processing issue | Show retry button |
