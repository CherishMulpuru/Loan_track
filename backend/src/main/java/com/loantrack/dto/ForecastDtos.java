package com.loantrack.dto;

import com.loantrack.entity.Loan;
import com.loantrack.entity.PaymentSchedule;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class ForecastDtos {

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class ForecastRequest {
        @NotNull @Min(1) @Max(24)
        private Integer months;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class ForecastEntry {
        private LocalDate dueDate;
        private String loanNumber;
        private Loan.LoanType loanType;
        private BigDecimal amount;
        private PaymentSchedule.ScheduleStatus status;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class ForecastResponse {
        private List<ForecastEntry> entries;
        private BigDecimal totalDue;
        private Integer months;
        private LocalDate from;
        private LocalDate to;
    }
}

