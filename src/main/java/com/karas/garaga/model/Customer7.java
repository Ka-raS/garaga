package com.karas.garaga.model;

import java.io.Serial;
import java.util.Objects;

public final class Customer7 extends Member7 {
    @Serial
    private static final long serialVersionUID = 2026_11_02_001L;

    private final String fullname;
    private final String phoneNumber;

    public Customer7(long id, String username, String fullname, String phoneNumber) {
        super(id, username);
        this.fullname = Objects.requireNonNull(fullname, "fullname");
        this.phoneNumber = Objects.requireNonNull(phoneNumber, "phoneNumber");
    }

    public String fullname() {
        return fullname;
    }

    public String phoneNumber() {
        return phoneNumber;
    }
}
