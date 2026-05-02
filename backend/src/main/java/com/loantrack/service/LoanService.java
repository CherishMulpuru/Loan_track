package com.loantrack.service;

import com.loantrack.dto.LoanDtos.*;
import com.loantrack.entity.Loan;
import com.loantrack.entity.PaymentSchedule;
import com.loantrack.entity.User;
import com.loantrack.repository.LoanRepository;
import com.loantrack.repository.PaymentScheduleRepository;
import com.loantrack.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LoanService {

    private final LoanRepository loanRepository;
    private final PaymentScheduleRepository scheduleRepository;
    private final UserRepository userRepository;
    private final AmortizationService amortizationService;

    @Transactional
    public LoanResponse createLoan(String userEmail, CreateLoanRequest request) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        String loanNumber = generateUniqueLoanNumber();
        LocalDate endDate = request.getStartDate().plusMonths(request.getTermMonths());

        // Calculate monthly payment using amortization formula
        var monthlyPayment = amortizationService.calculateMonthlyPayment(
                request.getPrincipalAmount(),
                request.getInterestRate(),
                request.getTermMonths());

        Loan loan = Loan.builder()
                .user(user)
                .loanNumber(loanNumber)
                .principalAmount(request.getPrincipalAmount())
                .interestRate(request.getInterestRate())
                .termMonths(request.getTermMonths())
                .startDate(request.getStartDate())
                .endDate(endDate)
                .loanType(request.getLoanType())
                .status(Loan.LoanStatus.ACTIVE)
                .monthlyPayment(monthlyPayment)
                .outstandingBalance(request.getPrincipalAmount())
                .build();

        loan = loanRepository.save(loan);

        // Generate and persist amortization schedule
        List<PaymentSchedule> schedule = amortizationService.generateSchedule(loan);
        scheduleRepository.saveAll(schedule);

        return toResponse(loan);
    }

    @Transactional(readOnly = true)
    public List<LoanSummary> getUserLoans(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        return loanRepository.findByUserId(user.getId())
                .stream()
                .map(this::toSummary)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public LoanResponse getLoanById(String userEmail, Long loanId) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        Loan loan = loanRepository.findByIdAndUserId(loanId, user.getId())
                .orElseThrow(() -> new IllegalArgumentException("Loan not found: " + loanId));

        return toResponse(loan);
    }

    private String generateUniqueLoanNumber() {
        String num;
        do {
            num = "LT-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        } while (loanRepository.existsByLoanNumber(num));
        return num;
    }

    private LoanResponse toResponse(Loan l) {
        return LoanResponse.builder()
                .id(l.getId())
                .loanNumber(l.getLoanNumber())
                .principalAmount(l.getPrincipalAmount())
                .interestRate(l.getInterestRate())
                .termMonths(l.getTermMonths())
                .startDate(l.getStartDate())
                .endDate(l.getEndDate())
                .loanType(l.getLoanType())
                .status(l.getStatus())
                .monthlyPayment(l.getMonthlyPayment())
                .outstandingBalance(l.getOutstandingBalance())
                .createdAt(l.getCreatedAt())
                .build();
    }

    private LoanSummary toSummary(Loan l) {
        return LoanSummary.builder()
                .id(l.getId())
                .loanNumber(l.getLoanNumber())
                .loanType(l.getLoanType())
                .status(l.getStatus())
                .outstandingBalance(l.getOutstandingBalance())
                .monthlyPayment(l.getMonthlyPayment())
                .endDate(l.getEndDate())
                .build();
    }
}
