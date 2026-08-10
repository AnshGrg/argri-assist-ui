# AgriAssist — Extension Officer & Admin Pages Layout Setup

This document provides the complete UI layout, wireframe structure, widget breakdown, and endpoint mappings for the **Extension Officer & Admin Analytics Dashboard**.

To ensure a clean, intuitive, and professional interface, the Admin Dashboard is structured into **3 Dedicated Pages (or 3 Primary Dashboard Tabs)**.

---

# Page 1: System Overview & National KPIs (`/admin/dashboard`)

This is the main landing screen when an Agricultural Extension Officer or Administrator logs in.

### Page Wireframe

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│  AgriAssist Admin Dashboard                        [ Date Filter ]  [ Officer: Admin ] │
├────────────────────────────────────────────────────────────────────────────────────────┤
│  [ Total Farmers ]   [ Crop Queries ]   [ Fertilizer Queries ]  [ Acidic Soil Alerts ] │
│        1,420              5,340                 4,890               1,280 (26.1%)      │
├────────────────────────────────────────────────────────┬───────────────────────────────┤
│  Platform Query Activity over Time                     │  Top Active Cities            │
│  (Dual-Line Chart: Crop vs Fertilizer Queries)         │  1. Pokhara (1,160 queries)   │
│                                                        │  2. Chitwan (1,240 queries)   │
│                                                        │  3. Kathmandu (890 queries)   │
└────────────────────────────────────────────────────────┴───────────────────────────────┘
```

### Component & Endpoint Mapping

| Component Section                   | Recommended UI Widget | Associated API Endpoint              | Key Data Rendered                                                                                         |
| ----------------------------------- | --------------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------- |
| **Top KPI Stat Cards**        | Metric Cards / Badges | `GET /api/analytics/kpis/`         | Total Farmers, Crop Queries, Fertilizer Queries, Acidic Soil Alert Count (Highlighted Red), Acidic Soil % |
| **System Usage Trends**       | Dual-Line Chart       | `GET /api/analytics/usage-trends/` | Daily / Monthly query volume comparison over time                                                         |
| **City Activity Leaderboard** | Ranked Table          | `GET /api/analytics/kpis/`         | Ranking of cities by farmer engagement and recommendation query volume                                    |

---

# Page 2: Regional Soil Health & Fertilizer Demand (`/admin/soil-health`)

This page provides soil scientists and policy officers with chemical demand and soil degradation metrics across Nepal.

### Page Wireframe

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│  Regional Soil Health & Fertilizer Demand                                              │
├────────────────────────────────────────────────────────┬───────────────────────────────┤
│  National Soil pH Spectrum                             │  NPK Deficiency Rates (%)     │
│  (Donut Chart: Extremely Acidic / Neutral / Alkaline)  │  • Nitrogen Deficiency: 42%   │
│                                                        │  • Phosphorus Deficiency: 38% │
│                                                        │  • Potassium Deficiency: 21%  │
├────────────────────────────────────────────────────────┴───────────────────────────────┤
│  Soil Acidity Hotspots & Liming Risk Table                                            │
│  City       Avg pH    Total Tests   Acidic Tests   Risk Level   Action Required        │
│  Pokhara     5.12        850            590         CRITICAL    Subsidy Lime 200kg/ha  │
│  Lalitpur    5.38        420            210         HIGH        Subsidy Lime 150kg/ha  │
│  Chitwan     6.35       1100            120         LOW         Normal Monitoring      │
├────────────────────────────────────────────────────────────────────────────────────────┤
│  Regional Fertilizer Demand by City                                                    │
│  (Grouped Bar Chart: DAP vs Urea vs Lime vs MOP per City)                              │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Component & Endpoint Mapping

| Component Section                    | Recommended UI Widget | Associated API Endpoint                       | Key Data Rendered                                                                                                      |
| ------------------------------------ | --------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Soil pH Spectrum**           | Donut Chart           | `GET /api/analytics/soil-acidity-hotspots/` | Tiers: Extremely Acidic ($<5.0$), Moderately Acidic ($5.0-6.0$), Neutral ($6.0-7.5$), Alkaline ($>7.5$)        |
| **NPK Deficiency Badges**      | Percentage Badges     | `GET /api/analytics/kpis/`                  | Nitrogen ($N$), Phosphorus ($P$), Potassium ($K$) deficiency rates                                               |
| **Liming Risk Hotspots Table** | Color-Coded Table     | `GET /api/analytics/soil-acidity-hotspots/` | Cities sorted by acidity risk level (`CRITICAL` Red, `HIGH` Orange, `LOW` Green) with recommended liming dosages |
| **Regional Fertilizer Demand** | Grouped Bar Chart     | `GET /api/analytics/fertilizer-demand/`     | Chemical fertilizer demand counts (DAP, Urea, MOP, Lime, 20-20-0) per city                                             |

---

# Page 3: Crop Cultivation & Satellite Climate Intelligence (`/admin/crop-intelligence`)

This page tracks crop shifting trends and live NASA satellite weather data across regions.

### Page Wireframe

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│  Crop Cultivation & Satellite Climate Intelligence                                     │
├────────────────────────────────────────────────────────┬───────────────────────────────┤
│  Top 10 Most Recommended Crops                         │  Seasonal Crop Distribution   │
│  1. Rice      (1,420 queries | 98.4% confidence)       │  (Pie Chart: Monsoon, Winter, │
│  2. Maize     (  890 queries | 96.1% confidence)       │   Summer, Pre-Monsoon)        │
│  3. Chickpea  (  650 queries | 94.8% confidence)       │                               │
├────────────────────────────────────────────────────────┴───────────────────────────────┤
│  Regional NASA Satellite Climate Averages                                              │
│  • Pokhara:   Avg Temp: 24.8°C | Avg Humidity: 82.1% | Avg Rainfall: 245.5mm           │
│  • Chitwan:   Avg Temp: 28.2°C | Avg Humidity: 74.5% | Avg Rainfall: 180.0mm           │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Component & Endpoint Mapping

| Component Section                      | Recommended UI Widget | Associated API Endpoint                   | Key Data Rendered                                                                   |
| -------------------------------------- | --------------------- | ----------------------------------------- | ----------------------------------------------------------------------------------- |
| **Top Recommended Crops**        | Leaderboard Table     | `GET /api/analytics/crop-distribution/` | Top 10 crops ranked by total query count and average model confidence %             |
| **Seasonal Crop Breakdown**      | Pie / Donut Chart     | `GET /api/analytics/crop-distribution/` | Crop recommendations grouped by season (Monsoon, Winter, Summer, Pre-Monsoon)       |
| **NASA Satellite Climate Cards** | Summary Cards         | `GET /api/analytics/crop-distribution/` | Regional weather averages (Temperature, Humidity, Rainfall) fetched from NASA POWER |

---

# Summary Table

| Page Title                          | Route                        | Core Focus                    | Primary UI Components                                               |
| ----------------------------------- | ---------------------------- | ----------------------------- | ------------------------------------------------------------------- |
| **Page 1: System Overview**   | `/admin/dashboard`         | Platform Scale & Activity     | Stat Cards, Dual-Line Usage Chart, City Activity Table              |
| **Page 2: Soil & Fertilizer** | `/admin/soil-health`       | Chemical Demand & Acidic Soil | pH Donut Chart, NPK Badges, Liming Risk Table, Fertilizer Bar Chart |
| **Page 3: Crop & Weather**    | `/admin/crop-intelligence` | Crop Trends & Climate         | Crop Leaderboard Table, Seasonal Pie Chart, Satellite Climate Cards |
