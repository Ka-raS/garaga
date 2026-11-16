package com.karas.garaga.model;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.Objects;

public final class StaffInfo7 implements Serializable {
    @Serial
    private static final long serialVersionUID = 2026_11_02_001L;

    private final long id;
    private final String fullname;
    private final String phoneNumber;
    private final String email;
    private final LocalDate birthDate;

    public StaffInfo7(long id, String fullname, String phoneNumber, String email, LocalDate birthDate) {
        this.id = id;
        this.fullname = Objects.requireNonNull(fullname, "fullname");
        this.phoneNumber = Objects.requireNonNull(phoneNumber, "phoneNumber");
        this.email = Objects.requireNonNull(email, "email");
        this.birthDate = Objects.requireNonNull(birthDate, "birthDate");
    }

    public long id() {
        return id;
    }

    public String fullname() {
        return fullname;
    }

    public String phoneNumber() {
        return phoneNumber;
    }

    public String email() {
        return email;
    }

    public LocalDate birthDate() {
        return birthDate;
    }
}
