# The ABAP Cloud variant

`src/` targets **classic on-premise ABAP** (`SE38` / `SE11` / `SE24`).
`src-cloud/` targets **ABAP Cloud** — the SAP BTP ABAP Environment, which
is what the free trial gives you.

Both do the same thing. They differ because ABAP Cloud removes the parts
of classic ABAP that assume a SAP GUI is attached.

## What changes, and why

| Classic (`src/`) | ABAP Cloud (`src-cloud/`) | Why |
|---|---|---|
| Table defined in `SE11`, stored as abapGit XML | Table defined in source DDL (`.tabl.asddls`) | ABAP Cloud has no `SE11`; everything is source-based in Eclipse |
| `SELECT` joins the two tables directly | `SELECT` reads the CDS view `ZI_SalesOrderItem` | CDS views are the data-access layer in ABAP Cloud |
| `SELECT-OPTIONS` / `PARAMETERS` selection screen | Method parameters | Selection screens are a SAP GUI feature and are not released |
| `CL_SALV_TABLE` ALV grid | `IF_OO_ADT_CLASSRUN` console output | There is no SAP GUI to draw a grid on |
| `REPORT` / `START-OF-SELECTION` | A class run with F9 | Executable reports are not released in ABAP Cloud |
| `WRITE` list output | `out->write( )` | Same reason |

What does **not** change is the shape of the logic: fetch into an
internal table, filter it, loop it with a work area, sum a column. That
is the point — the ABAP fundamentals transfer, the UI layer does not.

## Objects

| Object | File | Purpose |
|---|---|---|
| `ZSO_HEADER` | `zso_header.tabl.asddls` | Order header table |
| `ZSO_ITEM` | `zso_item.tabl.asddls` | Order item table |
| `ZI_SalesOrderItem` | `zi_salesorderitem.ddls.asddls` | CDS view joining the two |
| `ZCL_SO_DATA_GEN_CLOUD` | `zcl_so_data_gen_cloud.clas.abap` | Creates demo rows |
| `ZCL_SO_REPORT_CLOUD` | `zcl_so_report_cloud.clas.abap` | Reads and prints the report |

## Running it

Once your ABAP Cloud Project is connected in Eclipse:

1. **Create a package.** Right-click your project → **New → ABAP Package**.
   Name it `ZSALES_ORDER`, and when prompted create a new transport request.
2. **Create the two tables.** Right-click the package → **New → Other ABAP
   Repository Object → Database Table**. Name it `ZSO_HEADER`, then replace
   the generated source with the contents of `zso_header.tabl.asddls`.
   **Activate** (`Ctrl+F3`). Repeat for `ZSO_ITEM`.
3. **Create the CDS view.** **New → Other → Core Data Services → Data
   Definition**. Name it `ZI_SalesOrderItem`, choose the *Define View
   Entity* template, paste in `zi_salesorderitem.ddls.asddls`, activate.
4. **Create the two classes.** **New → ABAP Class** for each, paste the
   source, activate.
5. **Run `ZCL_SO_DATA_GEN_CLOUD`** with **F9**. The console should report
   3 header rows and 4 item rows.
6. **Run `ZCL_SO_REPORT_CLOUD`** with **F9**.

Expected console output:

```
Sales Order Report - open orders
================================
<table of 3 rows>
Rows        : 3
Total value : 123000.00 INR
```

Three rows, not four: order `0000000002` has status `C` (completed) and
is filtered out by `iv_only_open`.

## Order matters

Activation fails if you create things out of order. The CDS view cannot
activate before the tables exist, and the classes cannot activate before
the CDS view exists. Tables → view → classes.

## Verification status

The classic variant in `src/` is checked by abaplint in CI.

The cloud variant is **not** covered by that check: abaplint does not
parse CDS and table DDL source, and `IF_OO_ADT_CLASSRUN` is not in its
standard-object stubs. Activation in ADT is the verification for these
objects — if they activate, they are correct.
