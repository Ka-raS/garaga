package com.karas.garaga.model;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Objects;

public final class ImportPartDetail7 implements Serializable {
    @Serial
    private static final long serialVersionUID = 2026_11_02_001L;

    private final int quantity;
    private final BigDecimal importedUnitPrice;
    private final String notes;
    private final SparePart7 part;

    public ImportPartDetail7(int quantity, BigDecimal importedUnitPrice, String notes, SparePart7 part) {
        this.quantity = quantity;
        this.importedUnitPrice = Objects.requireNonNull(importedUnitPrice, "importedUnitPrice");
        this.notes = notes;
        this.part = Objects.requireNonNull(part, "part");
    }

    public int quantity() {
        return quantity;
    }

    public BigDecimal importedUnitPrice() {
        return importedUnitPrice;
    }

    public String notes() {
        return notes;
    }

    public SparePart7 part() {
        return part;
    }

    public BigDecimal amount() {
        return importedUnitPrice.multiply(BigDecimal.valueOf(quantity));
    }
}
