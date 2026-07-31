# Firestore schema — Programming with Eng. Hossam

## Collections

### `admins/{uid}`
- `uid` string
- `email` string
- `name` string
- `role` string (`admin` \| `owner` \| `editor`)
- `createdAt` timestamp

First admin may be created from `/admin/setup` (bootstrap). Additional admins: Auth user in Console + this document. Existing admins can also write new `admins/{uid}` docs per security rules.

### `config/bootstrap`
- `adminCreated` bool
- `createdAt` timestamp
- `createdBy` string (uid)

Set when the first admin is created; blocks public bootstrap afterward.

### `students/{id}` (canonical)
| Field | Type |
|-------|------|
| registrationId | string |
| fullName | string |
| phone | string |
| school | string |
| grade | string |
| city | string |
| parentPhone | string? |
| sessionId | string |
| registeredAt | timestamp |
| attendanceStatus | `pending` \| `attended` |
| attendanceDate | timestamp? |
| certificateIssued | bool |
| certificateIssuedAt | timestamp? |
| certificateDownloaded | bool |
| certificateDownloadedAt | timestamp? |
| reviewSubmitted | bool |
| reviewSubmittedAt | timestamp? |
| rating | number? |
| review | string? |
| journeyStatus | string |
| lastUpdated | timestamp |
| createdBy | string |

### `sessions/{id}`
Title (AR/EN), city, venue, date, time labels, totalSeats, remainingSeats, registrationOpen.

### `reviews/{id}`
rating, comment, suggestions, name?, registrationId?, studentId?, status (`pending`|`approved`|`hidden`), createdAt.

### `certificates/{id}`
studentId, registrationId, issuedAt, downloadCount, pdfPath?

### `settings/{id}`
Site-wide config (contact, feature flags).

### `analytics/{id}`
Aggregated counters / daily snapshots (written by Cloud Functions later).

### `notificationOutbox/{id}`
Queued notification jobs for future FCM/email workers.

## Indexes (suggested)
- students: sessionId ASC, registeredAt DESC
- students: attendanceStatus ASC, sessionId ASC
- reviews: status ASC, createdAt DESC
