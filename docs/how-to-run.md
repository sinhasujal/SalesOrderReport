# How to run this project

You need access to an SAP system. Two options below.

---

## Option A — Import with abapGit (fastest)

[abapGit](https://abapgit.org) is a Git client that runs *inside* SAP.

1. Install abapGit: create a report `ZABAPGIT` in `SE38`, paste in
   [zabapgit.abap](https://raw.githubusercontent.com/abapGit/build/main/zabapgit.abap),
   activate, and run it.
2. In `SE21` (or `SE80`) create a package, e.g. `ZSALES_ORDER`.
3. In abapGit: **+ Online** → repository URL → target package → **Clone**.
4. Click **Pull** to bring the objects in.
5. In `SE11`, activate `ZSO_HEADER` and `ZSO_ITEM`.
6. Run `ZSO_DATA_GEN` (`SE38`) once.
7. Run `ZSO_REPORT`.

---

## Option B — Create the objects manually

Slower, but you learn the transactions — which is the point if you are
studying for an ABAP role.

### 1. The tables (`SE11`)

For each of `ZSO_HEADER` and `ZSO_ITEM`:

- `SE11` → **Database table** → enter the name → **Create**
- Short description, **Delivery Class** `A`, **Data Browser/Table View
  Maint.** = *Display/Maintenance Allowed*
- **Fields** tab → enter the fields from
  [data-model.md](data-model.md). Tick **Key** and **Initial Values**
  for `MANDT`, `VBELN` (and `POSNR` in the item table).
- For `NETWR`, go to the **Currency/Quantity Fields** tab and set
  Reference table = the table itself, Reference field = `WAERK`.
  Do the same for `KWMENG` → `MEINS`.
- **Technical settings** (the hat icon): Data class `APPL0`,
  Size category `0`.
- **Activate** (Ctrl+F3).

### 2. The class (`SE24`)

- `SE24` → `ZCL_SO_REPORT` → **Create** → Class
- Easiest path: activate an empty class first, then switch to the
  **source-code-based** editor (the *Source Code-Based* button) and
  paste the whole of `zcl_so_report.clas.abap` over it.
- For the tests: **Goto → Class-local Types → Test Classes**, and paste
  `zcl_so_report.clas.testclasses.abap`.
- **Activate**.

### 3. The reports (`SE38`)

- `SE38` → `ZSO_DATA_GEN` → **Create** → Type *Executable Program* →
  paste `zso_data_gen.prog.abap` → **Activate**.
- Same for `ZSO_REPORT` with `zso_report.prog.abap`.
- For `ZSO_REPORT`, set the selection texts:
  **Goto → Text Elements → Selection Texts**, tick *Dictionary ref.* or
  type the labels from `zso_report.prog.xml`.

### 4. Run

- `SE38` → `ZSO_DATA_GEN` → Execute (F8). It writes 3 orders / 4 items.
- `SE38` → `ZSO_REPORT` → Execute (F8).

---

## Running the unit tests

In `SE24` with `ZCL_SO_REPORT` open, or in Eclipse/ADT:

- **SE80/SE24:** menu **Class → Unit Test** (or `Ctrl+Shift+F10`)
- **ADT (Eclipse):** right-click the class → **Run As → ABAP Unit Test**

All four tests should pass. They test `calculate_total( )` and
`count_orders( )` and need no data in the database.

---

## Note on SAP BTP ABAP Environment (trial)

The BTP trial runs **ABAP Cloud**, a restricted language version. Two
things in this project will *not* work there as written:

- `TABLES` and classic `SELECT-OPTIONS` are not released in ABAP Cloud.
- `CL_SALV_TABLE` output to a SAP GUI screen — there is no SAP GUI.

On BTP, the equivalent is a **CDS view** plus either a console
application (`IF_OO_ADT_CLASSRUN`) or a Fiori app via RAP. The class
`ZCL_SO_REPORT` and its unit tests port over with almost no change —
which is exactly why the `SELECT` was put in a class rather than
directly in the report.

This project targets **classic on-premise ABAP** (`SE38`/`SE11`/`SE24`),
which is what most ABAP maintenance and support projects still use.
