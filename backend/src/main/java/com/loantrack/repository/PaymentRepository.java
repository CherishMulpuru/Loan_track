package com.loantrack.repository;

import com.loantrack.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {

    List<Payment> findByLoanIdOrderByPaymentDateDesc(Long loanId);

    @Query("SELECT SUM(p.amount) FROM Payment p WHERE p.loan.id = :loanId")
    BigDecimal sumPaymentsByLoanId(@Param("loanId") Long loanId);

    boolean existsByConfirmationNumber(String confirmationNumber);
}
