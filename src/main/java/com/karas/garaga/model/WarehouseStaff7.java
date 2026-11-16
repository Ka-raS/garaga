package com.karas.garaga.model;

import java.io.Serial;
import java.util.Objects;

public final class WarehouseStaff7 extends Member7 {
    @Serial
    private static final long serialVersionUID = 2026_11_02_001L;

    private final StaffInfo7 info;

    public WarehouseStaff7(long id, String username, StaffInfo7 info) {
        super(id, username);
        this.info = Objects.requireNonNull(info, "info");
    }

    public StaffInfo7 info() {
        return info;
    }
}
