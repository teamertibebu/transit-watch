# Transit Watch

A mobile-first transit reliability platform that helps riders understand how
reliably their local transit system operates in practice.

Transit Watch uses GTFS (General Transit Feed Specification) and GTFS Realtime,
open standards that define common formats for public transit schedules, routes,
stops, geographic information, and real-time service updates.

## Applications

- `transit-watch-api/` — Phoenix API, transit-feed ingestion, PostgreSQL database,
  and reliability analytics
- `transit-watch-mobile/` — React Native / Expo rider mobile application

## Status

Early development. MARTA is the first supported transit agency. The initial goal
is to ingest MARTA's GTFS schedule and real-time data, store historical
observations, and expose rider-focused reliability information in the mobile app.

## Disclaimer

Transit Watch is an independent project and is not affiliated with, endorsed by,
or operated by MARTA or any other transit agency.