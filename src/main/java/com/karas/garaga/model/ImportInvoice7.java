package com.karas.garaga.model;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Objects;

public final class ImportInvoice7 implements Serializable {
    @Serial
    private static final long serialVersionUID = 2026_11_02_001L;

    private long id;
    private final Instant importedAt;
    private final String notes;
    private final ArrayList<ImportPartDetail7> importParts;
    private final WarehouseStaff7 warehouseStaff;
    private final Supplier7 supplier;

    public ImportInvoice7(Instant importedAt, String notes, ArrayList<ImportPartDetail7> importParts,
                          WarehouseStaff7 warehouseStaff, Supplier7 supplier) {
        this.id = -1;
        this.importedAt = Objects.requireNonNull(importedAt, "importedAt");
        this.notes = notes;
        this.importParts = Objects.requireNonNull(importParts, "importParts");
        this.warehouseStaff = Objects.requireNonNull(warehouseStaff, "warehouseStaff");
        this.supplier = Objects.requireNonNull(supplier, "supplier");
    }

    public long id() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public Instant importedAt() {
        return importedAt;
    }

    public String notes() {
        return notes;
    }

    public ArrayList<ImportPartDetail7> importParts() {
        return importParts;
    }

    public WarehouseStaff7 warehouseStaff() {
        return warehouseStaff;
    }

    public Supplier7 supplier() {
        return supplier;
    }

    public BigDecimal total() {
        return importParts.stream().map(ImportPartDetail7::amount).reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
