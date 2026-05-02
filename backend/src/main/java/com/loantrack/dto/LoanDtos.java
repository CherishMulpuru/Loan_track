package com.loantrack.dto;

import com.loantrack.entity.Loan;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.FutureOrPresent;
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
import java.time.LocalDateTime;

public class LoanDtos {

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class CreateLoanRequest {
        @NotNull @DecimalMin("1000.00")
        private BigDecimal principalAmount;
        @NotNull @DecimalMin("0.001") @DecimalMax("1.0")
        private BigDecimal interestRate;
        @NotNull @Min(1) @Max(360)
        private Integer termMonths;
        @NotNull @FutureOrPresent
        private LocalDate startDate;
        @NotNull
        private Loan.LoanType loanType;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class LoanResponse {
        private Long id;
        private String loanNumber;
        private BigDecimal principalAmount;
        private BigDecimal interestRate;
        private Integer termMonths;
        private LocalDate startDate;
        private LocalDate endDate;
        private Loan.LoanType loanType;
        private Loan.LoanStatus status;
        private BigDecimal monthlyPayment;
        private BigDecimal outstandingBalance;
        private LocalDateTime createdAt;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class LoanSummary {
        private Long id;
        private String loanNumber;
        private Loan.LoanType loanType;
        private Loan.LoanStatus status;
        private BigDecimal outstandingBalance;
        private BigDecimal monthlyPayment;
        private LocalDate endDate;
    }
}

