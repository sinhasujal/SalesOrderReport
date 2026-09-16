# Sales Order Report

A small ABAP training project: a classic report that reads sales order
headers and items from the database, filters them from a selection
screen, and displays the result in an ALV grid.

It is deliberately simple. The goal is to demonstrate the core ABAP
building blocks — Data Dictionary, Internal Tables, Work Areas, Open SQL,
Modularization, basic OO ABAP and ABAP Unit — rather than to build
something large.

![abaplint](https://github.com/sinhasujal/SalesOrderReport/actions/workflows/abaplint.yml/badge.svg)

---

## Two variants

The same report, built twice for the two worlds of ABAP:

| Folder | Targets | Run it with |
|---|---|---|
| `src/` | **Classic on-premise ABAP** - ECC, S/4HANA | `SE38` / `SE11` / `SE24` |
| `src-cloud/` | **ABAP Cloud** - SAP BTP ABAP Environment | Eclipse ADT, F9 |

The fundamentals are identical - internal tables, work areas, Open SQL,
modularization, classes. What differs is the UI and data-access layer:
ABAP Cloud has no SAP GUI, so there is no selection screen and no ALV
grid, and data is read through a CDS view rather than by joining tables
directly. See [docs/abap-cloud.md](docs/abap-cloud.md) for the full
comparison.

---

## What it does

`ZSO_REPORT` shows sales order line items with their header data:

```
Selection screen
  Sales order   [ 0000000001 ] to [ 0000000003 ]
  Customer      [ CUST001    ]
  Created on    [ 01.09.2026 ] to [ 30.09.2026 ]
  [X] Open orders only

        ↓

ALV grid
  Order        Customer  Created     St  Item    Material   Description              Qty   Net value  Crcy
  0000000001   CUST001   01.09.2026  O   000010  MAT-1001   Laptop Stand - Aluminium  10   25,000.00  INR
  0000000001   CUST001   01.09.2026  O   000020  MAT-1002   USB-C Docking Station      5   20,000.00  INR
  0000000003   CUST001   10.09.2026  O   000010  MAT-3001   27 inch Monitor            6   78,000.00  INR
```

---

## Objects in this project

| Object | Type | Purpose |
|---|---|---|
| `ZSO_HEADER` | Transparent table | Sales order header — modelled on `VBAK` |
| `ZSO_ITEM` | Transparent table | Sales order item — modelled on `VBAP` |
| `ZCL_SO_REPORT` | Class | Data retrieval (the `SELECT`) and calculations |
| `ZSO_REPORT` | Executable report | Selection screen + ALV display |
| `ZSO_DATA_GEN` | Executable report | Creates demo data to run the report against |
| `ltcl_so_report` | ABAP Unit test class | Tests the calculation methods |

Custom `Z` tables are used rather than the real `VBAK`/`VBAP` so the
project runs on any system, including a trial system with no SD data.
The field names are kept identical to the SAP originals.

---

## ABAP concepts demonstrated

| Concept | Where to look |
|---|---|
| **Data Dictionary** | `zso_header.tabl.xml`, `zso_item.tabl.xml` — tables, data types, `CURR`/`QUAN` reference fields |
| **Selection screen** | `zso_report.prog.abap` — `SELECT-OPTIONS`, `PARAMETERS`, screen blocks |
| **Screen validation** | `zso_report.prog.abap` → `AT SELECTION-SCREEN` / `FORM validate_selection` — rejects a reversed or future date range |
| **Authorization check** | `zso_report.prog.abap` → `FORM check_authority` — `AUTHORITY-CHECK` on `S_TABU_DIS` before any data is read |
| **Open SQL** | `zcl_so_report.clas.abap` → `get_orders( )` — `INNER JOIN`, `IN` against ranges, `INTO TABLE` |
| **Internal table** | `gt_output` in the report; `lt_header` / `lt_item` in the data generator |
| **Work area** | `ls_output` in `calculate_total( )`; `ls_header` / `ls_item` in the generator |
| **Modularization** | `FORM get_data` / `FORM display_data` called with `PERFORM` |
| **Basic OO ABAP** | `ZCL_SO_REPORT` — class with public methods, private constant, `CREATE OBJECT` |
| **Unit testing** | `zcl_so_report.clas.testclasses.abap` — 4 tests using `CL_ABAP_UNIT_ASSERT` |
| **ALV output** | `FORM display_data` — `CL_SALV_TABLE` factory, toolbar, striped rows |

---

## How to run it

See [docs/how-to-run.md](docs/how-to-run.md) for the full steps.

Short version:

1. Import the project with [abapGit](https://abapgit.org) into a `Z`
   package, or create the objects manually in `SE11` / `SE38` / `SE24`.
2. Activate both tables.
3. Run `ZSO_DATA_GEN` once to create demo data.
4. Run `ZSO_REPORT`.

---

## Code quality

The ABAP is checked by [abaplint](https://abaplint.org) on every push
(see [.github/workflows/abaplint.yml](.github/workflows/abaplint.yml)),
with syntax checking and unknown-type checking enabled.

To run the same check locally:

```bash
npx @abaplint/cli@latest
```

Current status: **0 issues across 10 files.**

---

## Data model

```
ZSO_HEADER  (1) ──────< (N)  ZSO_ITEM
   VBELN                        VBELN
                                POSNR
```

Full field list in [docs/data-model.md](docs/data-model.md).

---

## Author

**Sujal Sinha** — B.Tech Computer Science & Engineering
[linkedin.com/in/sujalsinha](https://linkedin.com/in/sujalsinha)

Built as a self-study project while learning SAP ABAP.
