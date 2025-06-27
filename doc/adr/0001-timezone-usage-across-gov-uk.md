# 1. Timezone usage across GOV.UK

Date: 2025-06-27

## Status

Accepted

## Context

Within the landscape of GOV.UK, we have 3 main categories of deployables: Publishing Apps, API Services, Frontend Apps. 

Timestamps are being passed between these apps and services. We need a consistent decision in handling timezones so we do not end up displaying the wrong date during British Summer Time where are we one hour out of sync with UTC.

## Decision

The decision is for all `Publishing Apps` and `Frontend Apps` to default to `London` timezone (which will switch to BST during summer, and UTC during winter); and for all `API Services` to default to UTC. Reasons and some exceptions to the rule are listed below.

This means all apps need to parse Date and Timestamp with timezone parsing. More on this in `Consequences` section.

### Reasonings

- In most cases, we use London as the timezone.
We make an exception for APIs, where we mostly want to provide UTC dates. A major reason for not migrating APIs to London timezone is because migrating major services like `Publishing API` may have consequences that we have yet to fully analyse.  
- We also make an exception for travel advice publisher which is a `Publishing App` which operates in UTC. `Travel Advice Publisher` has users in lots of different local timezones. If we can improve the app to display in appropriate timezones we may be able to migrate it to use default London as other publishing apps do.

### Exceptions

All `Publishing Apps` and `Frontend Apps` are in `London` timezone except*: 

| App | Timezone | Reason                                                                                                |
|---|---|-------------------------------------------------------------------------------------------------------|
| Travel Advice Publisher | UTC | Publishers are publishing for many different timezones in which London timestamps may cause confusion |

All `API Services` are in `UTC` timezone except*: 

| API             | Timezone | Reason                |
|-----------------|----------|-----------------------|
| Email Alert API | London   | Has not been migrated |


*A full audit has yet to be conducted to ensure all our applications and APIs adhere to the above.

## Consequences

With the discrepancy that Publishing Apps and Frontends operate in `London` timezones, but APIs operate in `UTC`, we run the risk of displaying wrong information to Publishers and the Public if we are parsing timestamps without their timezones. 

Take the following Example scenario: 

- Publishing App schedules article to publish at midnight BST, e.g. `01-07-2025 00:00 BST` which is equivalent to the day before in UTC `30-06-2025 23:00 UTC`
- This is sent to Publishing API and subsequently Search API
- Publishing time set in Publishing API and Search API as `30-06-2025 23:00 UTC`
- Frontend needs to parse the Date to display as Publication date. 
  - If the Date is simply parsed as `Date.parse(publication_date)` we get `30-06-2025` which is the **wrong** date. 
  - We **must** parse in the zone before extracting the date. E.g. `Time.zone.parse(publication_date).to_date` to get the correct date `01-07-2025`

## Actions yet to take

- Do a full audit of which Timezone each Service or App operate in to identify exceptions to the rule
- Implement a linter guard to ensure we are not trapped in situations such as the one detailed above under `Consequences`. e.g. Error or Warn on all plain `Date.parse` or `Chronic` date parsing without timezone configured.