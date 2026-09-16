# Data Model

Two custom (`Z`) transparent tables, modelled on the standard SAP
Sales & Distribution tables `VBAK` (order header) and `VBAP` (order item).

Custom tables are used instead of the real `VBAK`/`VBAP` so the project
runs on any system — including a trial system, which has no SD data.

```
ZSO_HEADER  (1) ──────< (N)  ZSO_ITEM
   VBELN                        VBELN
                                POSNR
```

## ZSO_HEADER — Sales Order Header

| Field  | Type      | Key | Description                       |
|--------|-----------|-----|-----------------------------------|
| MANDT  | CLNT 3    | X   | Client (added automatically)      |
| VBELN  | CHAR 10   | X   | Sales order number                |
| KUNNR  | CHAR 10   |     | Customer number                   |
| ERDAT  | DATS 8    |     | Created on                        |
| STATUS | CHAR 1    |     | `O` = Open, `C` = Completed       |
| NETWR  | CURR 15.2 |     | Net value (currency ref = WAERK)  |
| WAERK  | CUKY 5    |     | Currency key                      |

## ZSO_ITEM — Sales Order Item

| Field  | Type      | Key | Description                       |
|--------|-----------|-----|-----------------------------------|
| MANDT  | CLNT 3    | X   | Client                            |
| VBELN  | CHAR 10   | X   | Sales order number                |
| POSNR  | NUMC 6    | X   | Item number (000010, 000020, …)   |
| MATNR  | CHAR 18   |     | Material number                   |
| ARKTX  | CHAR 40   |     | Material description              |
| KWMENG | QUAN 13.3 |     | Order quantity (unit ref = MEINS) |
| MEINS  | UNIT 3    |     | Base unit of measure              |
| NETWR  | CURR 15.2 |     | Item net value (ref = WAERK)      |
| WAERK  | CUKY 5    |     | Currency key                      |

## Notes on the DDIC types

Two details here are ABAP-specific and worth knowing for an interview:

- **`CURR` needs a reference field.** A currency amount is meaningless
  without a currency, so the Data Dictionary forces every `CURR` field to
  point at a `CUKY` field. Here `NETWR` references `WAERK`.
- **`QUAN` needs a unit reference** for the same reason — a quantity of
  "10" needs a unit. `KWMENG` references `MEINS`.
- **`MANDT`** is the client field. SAP is multi-tenant at the database
  level: every client-dependent table carries `MANDT` as its first key
  field, and Open SQL adds `WHERE MANDT = sy-mandt` automatically so you
  never see another client's data.
