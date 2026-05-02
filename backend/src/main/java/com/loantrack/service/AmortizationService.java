package com.loantrack.service;

import com.loantrack.entity.Loan;
import com.loantrack.entity.PaymentSchedule;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Core amortization engine.
 * Calculates monthly payment using the standard annuity formula:
 *   M = P * [r(1+r)^n] / [(1+r)^n - 1]
 * where P = principal, r = monthly rate, n = number of periods.
 */
@Service
public class AmortizationService {

    private static final MathContext MC = new MathContext(10, RoundingMode.HALF_UP);
    private static final int SCALE = 2;

    /**
     * Calculates the fixed monthly payment for a loan.
     */
    public BigDecimal calculateMonthlyPayment(BigDecimal principal, BigDecimal annualRate, int termMonths) {
        if (annualRate.compareTo(BigDecimal.ZERO) == 0) {
            return principal.divide(BigDecimal.valueOf(termMonths), SCALE, RoundingMode.HALF_UP);
        }

        BigDecimal monthlyRate = annualRate.divide(BigDecimal.valueOf(12), MC);
        BigDecimal onePlusR = BigDecimal.ONE.add(monthlyRate);
        BigDecimal onePlusRtoN = onePlusR.pow(termMonths, MC);

        BigDecimal numerator = monthlyRate.multiply(onePlusRtoN, MC);
        BigDecimal denominator = onePlusRtoN.subtract(BigDecimal.ONE);

        return principal.multiply(numerator.divide(denominator, MC))
                .setScale(SCALE, RoundingMode.HALF_UP);
    }

    /**
     * Generates the full amortization schedule for a loan.
     */
    public List<PaymentSchedule> generateSchedule(Loan loan) {
        List<PaymentSchedule> schedule = new ArrayList<>();

        BigDecimal balance = loan.getPrincipalAmount();
        BigDecimal monthlyRate = loan.getInterestRate().divide(BigDecimal.valueOf(12), MC);
        BigDecimal monthlyPayment = loan.getMonthlyPayment();
        LocalDate dueDate = loan.getStartDate().plusMonths(1);

        for (int i = 1; i <= loan.getTermMonths(); i++) {
            BigDecimal interest = balance.multiply(monthlyRate, MC).setScale(SCALE, RoundingMode.HALF_UP);
            BigDecimal principal;
            BigDecimal payment = monthlyPayment;

            // Last payment: pay off remaining balance exactly
            if (i == loan.getTermMonths()) {
                principal = balance;
                payment = balance.add(interest);
            } else {
                principal = payment.subtract(interest).setScale(SCALE, RoundingMode.HALF_UP);
            }

            BigDecimal beginBalance = balance;
            BigDecimal endBalance = balance.subtract(principal).setScale(SCALE, RoundingMode.HALF_UP);
            if (endBalance.compareTo(BigDecimal.ZERO) < 0) {
                endBalance = BigDecimal.ZERO;
            }

            schedule.add(PaymentSchedule.builder()
                    .loan(loan)
                    .paymentNumber(i)
                    .dueDate(dueDate)
                    .scheduledAmount(payment.setScale(SCALE, RoundingMode.HALF_UP))
                    .principalPortion(principal.setScale(SCALE, RoundingMode.HALF_UP))
                    .interestPortion(interest)
                    .beginningBalance(beginBalance.setScale(SCALE, RoundingMode.HALF_UP))
                    .endingBalance(endBalance)
                    .status(PaymentSchedule.ScheduleStatus.PENDING)
                    .build());

            balance = endBalance;
            dueDate = dueDate.plusMonths(1);
        }

        return schedule;
    }
}
