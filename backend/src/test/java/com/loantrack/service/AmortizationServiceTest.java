package com.loantrack.service;

import com.loantrack.entity.Loan;
import com.loantrack.entity.PaymentSchedule;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.*;

@DisplayName("AmortizationService")
class AmortizationServiceTest {

    private AmortizationService service;

    @BeforeEach
    void setUp() {
        service = new AmortizationService();
    }

    @Test
    @DisplayName("calculates monthly payment correctly for standard loan")
    void calculateMonthlyPayment_standardLoan() {
        // $10,000 at 5% for 36 months
        BigDecimal monthly = service.calculateMonthlyPayment(
                new BigDecimal("10000.00"),
                new BigDecimal("0.05"),
                36);

        // Standard formula result ~$299.71
        assertThat(monthly).isBetween(new BigDecimal("299.00"), new BigDecimal("300.50"));
    }

    @Test
    @DisplayName("calculates monthly payment for 0% interest rate")
    void calculateMonthlyPayment_zeroInterest() {
        BigDecimal monthly = service.calculateMonthlyPayment(
                new BigDecimal("12000.00"),
                BigDecimal.ZERO,
                12);

        assertThat(monthly).isEqualByComparingTo(new BigDecimal("1000.00"));
    }

    @Test
    @DisplayName("generates correct number of schedule entries")
    void generateSchedule_correctEntryCount() {
        Loan loan = buildTestLoan(new BigDecimal("10000"), new BigDecimal("0.05"), 12);
        List<PaymentSchedule> schedule = service.generateSchedule(loan);

        assertThat(schedule).hasSize(12);
    }

    @Test
    @DisplayName("first payment has correct principal/interest split")
    void generateSchedule_firstEntryCorrect() {
        Loan loan = buildTestLoan(new BigDecimal("10000"), new BigDecimal("0.06"), 12);
        List<PaymentSchedule> schedule = service.generateSchedule(loan);

        PaymentSchedule first = schedule.get(0);
        // Monthly interest: 10000 * 0.06/12 = 50.00
        assertThat(first.getInterestPortion()).isEqualByComparingTo(new BigDecimal("50.00"));
        assertThat(first.getPaymentNumber()).isEqualTo(1);
        assertThat(first.getStatus()).isEqualTo(PaymentSchedule.ScheduleStatus.PENDING);
    }

    @Test
    @DisplayName("final payment ending balance is zero")
    void generateSchedule_finalBalanceIsZero() {
        Loan loan = buildTestLoan(new BigDecimal("5000"), new BigDecimal("0.04"), 24);
        List<PaymentSchedule> schedule = service.generateSchedule(loan);

        PaymentSchedule last = schedule.get(schedule.size() - 1);
        assertThat(last.getEndingBalance()).isEqualByComparingTo(BigDecimal.ZERO);
    }

    @Test
    @DisplayName("beginning balance of entry N equals ending balance of entry N-1")
    void generateSchedule_balancesChain() {
        Loan loan = buildTestLoan(new BigDecimal("20000"), new BigDecimal("0.07"), 60);
        List<PaymentSchedule> schedule = service.generateSchedule(loan);

        for (int i = 1; i < schedule.size(); i++) {
            assertThat(schedule.get(i).getBeginningBalance())
                    .isEqualByComparingTo(schedule.get(i - 1).getEndingBalance());
        }
    }

    private Loan buildTestLoan(BigDecimal principal, BigDecimal rate, int months) {
        BigDecimal monthly = service.calculateMonthlyPayment(principal, rate, months);
        return Loan.builder()
                .principalAmount(principal)
                .interestRate(rate)
                .termMonths(months)
                .startDate(LocalDate.of(2024, 1, 1))
                .endDate(LocalDate.of(2024, 1, 1).plusMonths(months))
                .monthlyPayment(monthly)
                .outstandingBalance(principal)
                .status(Loan.LoanStatus.ACTIVE)
                .loanType(Loan.LoanType.PERSONAL)
                .build();
    }
}
