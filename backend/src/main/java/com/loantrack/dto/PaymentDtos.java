package com.loantrack.dto;

import com.loantrack.entity.Payment;
import com.loantrack.entity.PaymentSchedule;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class PaymentDtos {

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class MakePaymentRequest {
        @NotNull @DecimalMin("0.01")
        private BigDecimal amount;
        @NotNull
        private Payment.PaymentMethod paymentMethod;
        private Long scheduleId;
        private String note;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class PaymentResponse {
        private Long id;
        private Long loanId;
        private BigDecimal amount;
        private LocalDate paymentDate;
        private Payment.PaymentMethod paymentMethod;
        private String confirmationNumber;
        private String note;
        private LocalDateTime createdAt;
    }

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class ScheduleEntryResponse {
        private Long id;
        private Integer paymentNumber;
        private java.time.LocalDate dueDate;
        private BigDecimal scheduledAmount;
        private BigDecimal principalPortion;
        private BigDecimal interestPortion;
        private BigDecimal beginningBalance;
        private BigDecimal endingBalance;
        private PaymentSchedule.ScheduleStatus status;
    }
}

