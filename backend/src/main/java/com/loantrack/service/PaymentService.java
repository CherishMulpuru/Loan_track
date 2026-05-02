package com.loantrack.service;

import com.loantrack.dto.PaymentDtos.*;
import com.loantrack.entity.*;
import com.loantrack.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final LoanRepository loanRepository;
    private final PaymentScheduleRepository scheduleRepository;
    private final UserRepository userRepository;

    @Transactional
    public PaymentResponse makePayment(String userEmail, Long loanId, MakePaymentRequest request) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        Loan loan = loanRepository.findByIdAndUserId(loanId, user.getId())
                .orElseThrow(() -> new IllegalArgumentException("Loan not found: " + loanId));

        if (loan.getStatus() != Loan.LoanStatus.ACTIVE) {
            throw new IllegalStateException("Cannot make payment on a non-active loan");
        }

        PaymentSchedule schedule = null;
        if (request.getScheduleId() != null) {
            schedule = scheduleRepository.findById(request.getScheduleId())
                    .orElseThrow(() -> new IllegalArgumentException("Schedule entry not found"));
            schedule.setStatus(PaymentSchedule.ScheduleStatus.PAID);
            scheduleRepository.save(schedule);
        }

        // Update outstanding balance
        var newBalance = loan.getOutstandingBalance().subtract(request.getAmount());
        if (newBalance.compareTo(java.math.BigDecimal.ZERO) <= 0) {
            newBalance = java.math.BigDecimal.ZERO;
            loan.setStatus(Loan.LoanStatus.PAID_OFF);
        }
        loan.setOutstandingBalance(newBalance);
        loanRepository.save(loan);

        String confirmation = generateConfirmation();

        Payment payment = Payment.builder()
                .loan(loan)
                .schedule(schedule)
                .amount(request.getAmount())
                .paymentDate(java.time.LocalDate.now())
                .paymentMethod(request.getPaymentMethod())
                .confirmationNumber(confirmation)
                .note(request.getNote())
                .build();

        payment = paymentRepository.save(payment);
        return toResponse(payment);
    }

    @Transactional(readOnly = true)
    public List<PaymentResponse> getPaymentHistory(String userEmail, Long loanId) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        loanRepository.findByIdAndUserId(loanId, user.getId())
                .orElseThrow(() -> new IllegalArgumentException("Loan not found: " + loanId));

        return paymentRepository.findByLoanIdOrderByPaymentDateDesc(loanId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ScheduleEntryResponse> getAmortizationSchedule(String userEmail, Long loanId) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        loanRepository.findByIdAndUserId(loanId, user.getId())
                .orElseThrow(() -> new IllegalArgumentException("Loan not found: " + loanId));

        return scheduleRepository.findByLoanIdOrderByPaymentNumber(loanId)
                .stream().map(this::toScheduleResponse).collect(Collectors.toList());
    }

    private String generateConfirmation() {
        String conf;
        do {
            conf = "CNF-" + UUID.randomUUID().toString().substring(0, 10).toUpperCase();
        } while (paymentRepository.existsByConfirmationNumber(conf));
        return conf;
    }

    private PaymentResponse toResponse(Payment p) {
        return PaymentResponse.builder()
                .id(p.getId())
                .loanId(p.getLoan().getId())
                .amount(p.getAmount())
                .paymentDate(p.getPaymentDate())
                .paymentMethod(p.getPaymentMethod())
                .confirmationNumber(p.getConfirmationNumber())
                .note(p.getNote())
                .createdAt(p.getCreatedAt())
                .build();
    }

    private ScheduleEntryResponse toScheduleResponse(PaymentSchedule ps) {
        return ScheduleEntryResponse.builder()
                .id(ps.getId())
                .paymentNumber(ps.getPaymentNumber())
                .dueDate(ps.getDueDate())
                .scheduledAmount(ps.getScheduledAmount())
                .principalPortion(ps.getPrincipalPortion())
                .interestPortion(ps.getInterestPortion())
                .beginningBalance(ps.getBeginningBalance())
                .endingBalance(ps.getEndingBalance())
                .status(ps.getStatus())
                .build();
    }
}
